%% VOR_SineFit.m
% Input:
% data      - dat structure with channels
%   'htvel'
%   'hhvel'
%   'hepos'
%   'vepos'
%   'stim pul'
% params.segStarts    - time window start times
% params.segEnds     - time wndow stop times
% sinefreq  - frequency of stimulus for each segment
% labels    - label for each segment
% timepts   - time label for each segment (optional)
% params.saccadeThresh  - velocity threshold
%
% Output: R.data structure with data and header
%
% Modified 1/20/14 to remove vertical eye calculations


function R = VOR_SineFit(data, sinefreq, labels, timepts, params)
%% === Create R data Array and other parameters ======================== %%

set(groot, 'DefaultFigureVisible', 'off');
sp1 = figure(); clf;
sp2 = figure(); clf;
row = 0;

% Set up cell structure to hold all R.data
fprintf('\n\nGenerating Segment Figures...')

header = {'timept'  'start' 'end'   'eyeHgain' 'eyeHphase'...
    'headamp' 'headangle' 'drumamp' 'drumangle' 'eyeHamp' 'eyeHangle'...
    'saccadeFrac' 'rsquare' 'pval' 'variance','nGoodCycles'};

nSegs = length(params.segStarts);
nCols = length(header);

R.data = NaN(nSegs,nCols);
R.header = header;
R.labels = labels;

if ~exist('timepts','var')
    timepts = mean([params.segStarts params.segEnds],2);
end
R.data(:,strcmpi(header,'timept')) = timepts;

% Other parameters
if ~isfield(params, 'saccadeThresh')
    params.saccadeThresh = .55;
end

if ~isfield(params, 'do_individual')
    params.do_individual = 1;
end

samplerate = data(1).samplerate;
presaccadeN = round(params.saccadePre*samplerate);
postsaccadeN = round(params.saccadePost*samplerate);

% Shared y-axis per column: percentiles, data pools, axes handles
pL = 99.5; pR = 99; pAB = 95;  %pL for block traces, pR for cycles, and pAB for two left columns of subplot2
yL_all = []; yR_all = []; yAB_all = []; yC_max = 0;
axL = gobjects(0); axR = gobjects(0); axA = gobjects(0); axB = gobjects(0); axC = gobjects(0);

%% === Cycle through each segment ====================================== %%
for count = 1:nSegs
    
    %% === Prep Data =================================================== %%
    
    % Skip segments where frequency or start time is NaN
    if isnan(sinefreq(count)) || isnan(params.segStarts(count))
        continue
    end

    % Get the current label and frequency
    datatype = labels{count};
    freq = sinefreq(count);

    % Segment data to current time segment
    dataseg = datseg(data, [params.segStarts(count) params.segEnds(count)]);

    % Import Eye, Chair, and Drum velocity
    headVel = datchandata(dataseg,'hhvel')*-1;
    drumVel = datchandata(dataseg,'htvel');
    eyeVel  = datchandata(dataseg,'hevel');
    eyePos  = datchandata(dataseg,'hepos');

    % define vector of time
    segLength = length(headVel);
    segTime = (1:segLength)/samplerate; 
    cycleLength = round(samplerate/freq);
    cycleTime = (1:cycleLength)/samplerate;

    %% === Desaccade/Process =========================================== %%
    
    % Find Initial Fit --> Not really needed, hope to remove eventually
    y1 = sin(2*pi*freq*segTime(:));
    y2 = cos(2*pi*freq*segTime(:));
    constant = ones(segLength,1);
    vars = [y1 y2 constant];
    keep = abs(eyeVel) < 5*std(abs(eyeVel)) + mean(abs(eyeVel));
    b = regress(eyeVel(keep), vars(keep,:));
    fit1 = vars *b;
    
    % OLD VERSION
    if params.newSac == 0
        eyevelHtemp = eyeVel - vars*b;
        [eyevelH_des_temp, omitCenters, rawThres1] = desaccadeVelNew(eyevelHtemp, presaccadeN, postsaccadeN, params.saccadeThresh);
        omitH = isnan(eyevelH_des_temp);
        
    % NEW VERSION
    elseif params.newSac == 1
        [omitH, omitCenters, eyePos_filt, eyeVel_proc] = desaccadeVel3(eyePos, samplerate, presaccadeN, postsaccadeN, freq, params, fit1);
        
        % Store Processed Trace
        eyeVel_proc_des = eyeVel_proc;
        eyeVel_proc_des(omitH) = NaN;
    end
    
    % Store Raw Trace
    eyeVel_raw = eyeVel;
    eyeVel_raw_des = eyeVel_raw;
    eyeVel_raw_des(omitH) = NaN;
    
    % Store Analysis Choice (either raw or proc)
    if params.cleanAnalysis
        eyeVel = eyeVel_proc;
        eyeVel_des = eyeVel_proc_des;
    else
        eyeVel = eyeVel_raw;
        eyeVel_des = eyeVel_raw_des;
    end
    

    % remove pieces of the trace that are too small  
    
    % 1's are nan locations (artifacts)
    [nanLocs_all, ~] = find(isnan(eyeVel_des));

    % Find length of all 'good' (non-nan) chunks of data
    goodChunk_len = nanLocs_all(2:end) - nanLocs_all(1:end-1);
    goodChunk_len(goodChunk_len == 1) = [];

    % find start times of all 'good' chunks
    nanEnds_relative = find((nanLocs_all(2:end) - nanLocs_all(1:end-1)) -1);
    nanEnds_absolute = nanLocs_all(nanEnds_relative);
    goodChunk_starts = nanEnds_absolute + 1;

    % remove good chunks that are not too small
    goodChunk_starts(goodChunk_len >= params.minGoodChunk_len) = [];
    goodChunk_len(goodChunk_len >= params.minGoodChunk_len) = [];

    % All good chunks that are smaller than specified length are nan-ed
    for ii = 1:length(goodChunk_starts)
        
        eyeVel_des(goodChunk_starts(ii):goodChunk_starts(ii)+goodChunk_len(ii)) = NaN;

        if params.cleanPlot
            eyeVel_proc_des(goodChunk_starts(ii):goodChunk_starts(ii)+goodChunk_len(ii)) = NaN;
        else
            eyeVel_raw_des(goodChunk_starts(ii):goodChunk_starts(ii)+goodChunk_len(ii)) = NaN;
        end    
    end

    %% === Calculate Fits ============================================== %%
    % fit data using a linear regression (data specified by 'keep_'index)
    % b=coefficients, bint=95% confidence intervals, r=residual, rint=interval
    % stats include 1)R-square, 2)F statistics, 3)p value 4)error variance
    
    % No constant term bc sine centered at 0
    warning('off','stats:regress:NoConst') 

    % headVel
    b = regress(headVel, vars);
    headVel_amp = sqrt(b(1)^2+b(2)^2);
    headVel_angle = rad2deg(atan2(b(2), b(1)));

    % drumVel
    b = regress(drumVel, vars);
    drumVel_amp = sqrt(b(1)^2+b(2)^2);
    drumVel_angle = rad2deg(atan2(b(2), b(1)));
    
    % eyeVel (desaccaded)
    [b,~,~,~,stat] = regress(eyeVel(~omitH), vars(~omitH,:));
    eyeVel_amp = sqrt(b(1)^2+b(2)^2);
    eyeVel_phase = rad2deg(atan2(b(2), b(1)));

    % calculate eye gain as VOR or OKR based on head signal
    % Chair/VOR Stimulus
    if headVel_amp > 3
        reference_amp = headVel_amp;
        reference_angle = headVel_angle;
        idealEyeVel = drumVel-headVel;
    % Drum/OKR Stimulus
    elseif drumVel_amp > 3
        reference_amp = drumVel_amp;
        reference_angle = drumVel_angle;
        idealEyeVel = drumVel;
    % No Motor Stimulus
    else
        reference_amp = 1;
        reference_angle = 0;
        idealEyeVel = zeros(1,segLength);
    end

    % eye calculations relative to drum/chair
    eyeVel_rel_gain = eyeVel_amp/reference_amp;
    eyeVel_rel_phase = (eyeVel_phase - reference_angle);
    eyeVel_rel_phase = mod(eyeVel_rel_phase,360) - 180;
    eyeVel_des_cycleFit = sin(2*pi*freq*cycleTime + deg2rad(eyeVel_rel_phase+180))*eyeVel_amp;
    warning on
    
    %% === Calculate Average and More ================================== %%

    startpt = max(1,round(mod(-reference_angle,360)/360 * samplerate/freq));
    
    [eyeVel_des_mat, eyeVel_des_cycleMean] = VOR_breakTrace(cycleLength, startpt, eyeVel_des);
    [~, headVel_cycleMean]                 = VOR_breakTrace(cycleLength, startpt, headVel);
    [~, drumVel_cycleMean]                 = VOR_breakTrace(cycleLength, startpt, drumVel);
    [omit_mat, ~]                          = VOR_breakTrace(cycleLength, startpt, double(omitCenters));
    [~, idealEye_cycleMean]                = VOR_breakTrace(cycleLength, startpt, idealEyeVel);

    % Calculate Extras
    badCycles       = any(omit_mat,2);
    goodCount       = sum(~badCycles);
    eyeVel_des_Sem  = nanstd(eyeVel_des_mat)./sqrt(sum(~isnan(eyeVel_des_mat)));
    
    if goodCount > 0
        eyeVel_good_cycleMean = nanmean(eyeVel_des_mat(~badCycles,:), 1);
        eyeVel_good_cycleStd  = nanstd(eyeVel_des_mat(~badCycles,:));
    else
        eyeVel_good_cycleMean = zeros(size(eyeVel_des_mat(1,:)));
        eyeVel_good_cycleStd  = zeros(size(eyeVel_des_mat(1,:)));
    end
    
    %% === Write to R.data ============================================= %%
    R.data(count,strcmpi(header,'start'))       = params.segStarts(count);
    R.data(count,strcmpi(header,'end'))         = params.segEnds(count);
    R.data(count,strcmpi(header,'headamp'))     = headVel_amp;
    R.data(count,strcmpi(header,'headangle'))   = headVel_angle;   
    R.data(count,strcmpi(header,'drumamp'))     = drumVel_amp;
    R.data(count,strcmpi(header,'drumangle'))   = drumVel_angle;    
    R.data(count,strcmp(header,'eyeHamp'))      = eyeVel_amp;
    R.data(count,strcmp(header,'eyeHangle'))    = eyeVel_phase;
    R.data(count,strcmp(header,'eyeHgain'))     = eyeVel_rel_gain;
    R.data(count,strcmp(header,'eyeHphase'))    = eyeVel_rel_phase;
    R.data(count,strcmp(header,'rsquare'))      = stat(1);
    R.data(count,strcmp(header,'pval'))         = stat(3);
    R.data(count,strcmp(header,'variance'))     = sqrt(stat(4)); % STD of error - more is worse
    R.data(count,strcmp(header,'saccadeFrac'))  = mean(omitH);
    R.data(count,strcmp(header,'nGoodCycles'))  = goodCount;
    
    R.eyeVel_good_cycleMean{count}  = eyeVel_good_cycleMean;
    R.eyeVel_des_cycleMean{count}   = eyeVel_des_cycleMean;
    R.eyeVel_des_cycleFit{count}    = eyeVel_des_cycleFit;
    R.eyeVel_des_Sem{count}         = eyeVel_des_Sem;
    R.headVel_cycleMean{count}      = headVel_cycleMean;
    R.drumVel_cycleMean{count}      = drumVel_cycleMean;
    R.cycleTime{count}              = cycleTime;
    R.freq{count}                   = freq;
    R.samplerate{count}             = samplerate;
    R.idealEye_cycleMean{count}     = idealEye_cycleMean;
    R.saccadeFrac{count}            = mean(omitH);
    
    %% === Subplot-1: Segment and Fit ================================== %%
    
    % Choose Stim
    if contains(R.labels{count}, 'OKR')
        plotStim = drumVel_cycleMean;
        stimType = 'Drum';
    else
        plotStim = headVel_cycleMean;
        stimType = 'Chair';
    end
    
    if params.do_subplot1

        set(groot, 'CurrentFigure', sp1);
        subplot(params.sp_Dim(1), params.sp_Dim(2), (1:8) + row);
        axL(end+1) = gca;

        % Plot proc or raw
        if params.cleanPlot
            plot(segTime(1:length(eyeVel_proc)), eyeVel_proc, 'k', 'LineWidth', .2); hold on
            plot(segTime(1:length(eyeVel_proc_des)), eyeVel_proc_des, 'b', 'LineWidth', .2);
            plot(segTime, vars*b,'r', 'LineWidth', .05);
        else
            plot(segTime(1:length(eyeVel_raw)), eyeVel, 'k', 'LineWidth', .2); hold on
            plot(segTime(1:length(eyeVel_raw_des)), eyeVel_raw_des, 'b', 'LineWidth', .2);
            plot(segTime, vars*b,'r', 'LineWidth', .3);
        end
        if params.cleanPlot, yL_all = [yL_all; eyeVel_proc_des(:)]; else, yL_all = [yL_all; eyeVel_raw_des(:)]; end

        % Old de-saccade: Plot Thresh lines
        if params.newSac == 0
            plot(segTime, fit1 + rawThres1(1), ':r', 'LineWidth', .2);
            plot(segTime, fit1 + rawThres1(2), ':r', 'LineWidth', .2);
        end
        
        % Cosmetics
        xlim([0 max(segTime)]);
        title(datatype)

        % Only add xlabel on final segment
        if count == nSegs
            xlabel('Time (s)');
        end

        % Text displaying absolute time of segment start
        text(0, 1.15, ['@ ' num2str(round(params.segStarts(count), 2)), 's'], 'Units','normalized', 'FontSize', 7)

        % X ticks at 0, mid, max
        setXTicks3(gca);
        drawnow;
        
        % --- Subplot-1: Cycle and Fit ---------------------------------- %
        subplot(params.sp_Dim(1), params.sp_Dim(2), (9:10) + row);
        axR(end+1) = gca;

        % plot
        plot(cycleTime, smooth(eyeVel_good_cycleMean, 50),'b'); hold on
        plot(cycleTime, smooth(eyeVel_des_cycleMean, 50), 'g');
        plot(cycleTime, eyeVel_des_cycleFit, 'r');
        plot(cycleTime, plotStim, 'k');
        hline(0,':k');
        %sp1.Children.Children(end).MarkerSize = 1;
        yR_all = [yR_all; eyeVel_good_cycleMean(:); eyeVel_des_cycleMean(:); eyeVel_des_cycleFit(:); plotStim(:)];

        % Cosmetics
        box off
        xlim([0 max(cycleTime)]);

        if count == 1
            text(-.06, .5, 'deg/s', 'Units','normalized', 'FontSize', 8, 'Rotation', 90)
        end

        if count == nSegs
            xlabel('Time (s)');
        end

        % Add quick reference text
        text(1.1, .8, ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))], 'Units','normalized', 'FontSize',7);
        text(1.1, .7, ['Rel Gain: ' num2str(eyeVel_rel_gain)], 'Units','normalized', 'FontSize',7);
        text(1.1, .6, ['Eye Amp: ', num2str(eyeVel_amp,3)], 'Units','normalized', 'FontSize',7);
        text(1.1, .5, ['Rel. Phase: ', num2str(eyeVel_rel_phase,3)], 'Units','normalized', 'FontSize',7);
        text(1.1, .4, ['Stim: ', stimType], 'Units','normalized', 'FontSize',7);
        text(1.1, .3, ['r^2: ', num2str(stat(1))], 'Units','normalized', 'FontSize',7);
        text(1.1, .2, ['sacFrac: ', num2str(mean(omitH))], 'Units','normalized', 'FontSize',7);

        % X ticks at 0, mid, max
        setXTicks3(gca);
        drawnow;
    end
    
    %% === Subplot-2: Mean Trace Visualization ========================= %%
    
    if params.do_subplot2
        
        % Prep
        set(groot, 'CurrentFigure', sp2);

        % Skip segments with 0 good cycles
        if any(~badCycles)

            % Figure A) Plot Full-Good Cycles & Mean Trace
            subplot(params.sp_Dim(1), params.sp_Dim(2), (1:3) + row);
            axA(end+1) = gca;
            plot(cycleTime, eyeVel_des_mat(~badCycles,:)', 'b', 'LineWidth', .2); hold on;
            plot(cycleTime, eyeVel_good_cycleMean, 'k', 'LineWidth', 1);
            hline(0, ':k')
            yAB_all = [yAB_all; reshape(eyeVel_des_mat(~badCycles,:),[],1); eyeVel_des_cycleFit(:); ...
                eyeVel_good_cycleMean(:)+eyeVel_good_cycleStd(:); eyeVel_good_cycleMean(:)-eyeVel_good_cycleStd(:)];

            % Cosmetics
            xlim([0 max(cycleTime)]);
            setXTicks3(gca);
            ylabel([num2str(goodCount), ' / ', num2str(length(badCycles))])
            box off

            % Figure B) Error Bars + Mean Trace
            subplot(params.sp_Dim(1), params.sp_Dim(2), (4:6) + row);
            axB(end+1) = gca;
            plot(cycleTime, eyeVel_good_cycleMean, 'k', 'LineWidth', 1); hold on
            plot(cycleTime, eyeVel_good_cycleMean + eyeVel_good_cycleStd, ':k', 'LineWidth', .2);
            plot(cycleTime, eyeVel_good_cycleMean - eyeVel_good_cycleStd, ':k', 'LineWidth', .2);
            plot(cycleTime, eyeVel_des_cycleFit,'r', 'LineWidth', .2);
            hline(0, ':k')

            % find (+) peaks for Fit and Mean
            [maxVal, maxLoc] = max(eyeVel_des_cycleFit);
            maxLoc = maxLoc/length(eyeVel_des_cycleFit);
            line([maxLoc maxLoc], [0 maxVal], 'color', 'r', 'LineWidth', .2);
            %scatter(maxLoc, maxVal, 'r', 'filled', 'SizeData', .2)

            [maxVal, maxLoc] = max(eyeVel_good_cycleMean);
            maxLoc = maxLoc/length(eyeVel_good_cycleMean);
            line([maxLoc maxLoc], [0 maxVal], 'color', 'k', 'LineWidth', .2);
            %scatter(maxLoc, maxVal, 'k', 'filled', 'SizeData', .2)


            % find (-) peaks for Fit and Mean
            [minVal, minLoc] = min(eyeVel_des_cycleFit);
            minLoc = minLoc/length(eyeVel_des_cycleFit);
            line([minLoc minLoc], [0 minVal], 'color', 'r', 'LineWidth', .2);
            %scatter(minLoc, minVal, 'r', 'filled', 'SizeData', .2)

            [minVal, minLoc] = min(eyeVel_good_cycleMean);
            minLoc = minLoc/length(eyeVel_good_cycleMean);
            line([minLoc minLoc], [0 minVal], 'color', 'k', 'LineWidth', .2);
            %scatter(minLoc, minVal, 'k', 'filled', 'SizeData', .2)

            % Cosmetics
            title(datatype)
            xlim([0 max(cycleTime)]);
            setXTicks3(gca);
            box off

            % Figure C) Power Spectrum of Traces
            subplot(params.sp_Dim(1), params.sp_Dim(2), (7:9) + row);
            axC(end+1) = gca;

            L = length(eyeVel(startpt:end));
            Y = fft(eyeVel(startpt:end));
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2+1));
            P1(2:end-1) = 2*P1(2:end-1);
            f = samplerate*(0:(L/2))/L;
            plot(f,P1, 'k')
            title([num2str(freq), 'Hz'])
            yC_max = max(yC_max, max(P1));

            % Cosmetics
            xlim([0 15])
            xticks(0:15)
            xticklabels({'0' '' '' '' '' '5' '' '' '' '' '10' '' '' '' '' '15'})
            set(gca, 'TickDir', 'out')
            box off

            % Text
            text(.79, 1,   ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))], 'Units','normalized', 'FontSize',7);
            text(.79, .83, ['Rel Gain: ' num2str(eyeVel_rel_gain)], 'Units','normalized', 'FontSize',7);
            text(.79, .67, ['Eye Amp: ', num2str(eyeVel_amp,3)], 'Units','normalized', 'FontSize',7);
            text(.79, .5,  ['Rel. Phase: ', num2str(eyeVel_rel_phase,3)], 'Units','normalized', 'FontSize',7);
            text(.79, .33, ['Stim: ', stimType], 'Units','normalized', 'FontSize',7);
        end

    end
    
    % Update Row information
    row = row + params.sp_Dim(2);

end

%% === Shared y-axis limits per column ================================= %%
yL  = [-1 1] * max(10, ceil(prctile(abs(yL_all),  pL)  / 10) * 10);
yR  = [-1 1] * max(10, ceil(prctile(abs(yR_all),  pR)  / 10) * 10);
yAB = [-1 1] * max(10, ceil(prctile(abs(yAB_all), pAB) / 10) * 10);
yC  = [0, max(1, ceil(yC_max * 1.1))];

setSharedYLim(axL, yL,  [yL(1)  0 yL(2)]);
setSharedYLim(axR, yR,  [yR(1)  0 yR(2)]);
setSharedYLim(axA, yAB, [yAB(1) 0 yAB(2)]);
setSharedYLim(axB, yAB, [yAB(1) 0 yAB(2)]);
setSharedYLim(axC, yC,  [0 yC(2)]);

% Add scale bar to only the first time-series panel
if ~isempty(axL)
    set(groot, 'CurrentFigure', sp1); set(sp1, 'CurrentAxes', axL(1));
    scalebar_xunits = 0.5;  % Width of scale bar (in seconds) along x-axis
    scalebar_yunits = 10;   % Height of scale bar (in deg/s) along y-axis
    scalebar_xlabel = [num2str(scalebar_xunits*1000), ' ms'];
    scalebar_ylabel = [num2str(scalebar_yunits), ' deg/s'];
    % Starting y-axis position of scale bar
    scalebar_ystart = 0.83 * yL(1);    % In deg/s
    % Starting/ending x-axis position of horizontal bar
    scalebar_h_xstart = 0.2;    % In seconds
    scalebar_h_xend = scalebar_h_xstart + scalebar_xunits;
    % Starting x-axis position of vertical bar
    scalebar_v_xstart = scalebar_h_xend;
    % Starting/Ending y-axis position of vertical bar
    scalebar_v_yend = scalebar_ystart + scalebar_yunits;
    % Draw white box background for scale bar
    scalebar_box_pos = [scalebar_h_xstart-0.1, ...
        scalebar_ystart-7, ...
        (scalebar_h_xend-scalebar_h_xstart)+0.6, ...
        (scalebar_v_yend-scalebar_ystart)+9];
    rectangle('Position', scalebar_box_pos, ...
        'FaceColor','w', ...
        'EdgeColor','k', ...
        'LineWidth',0.1);
    % Draw the horizontal and vertical lines
    line([scalebar_h_xstart,scalebar_h_xend], [scalebar_ystart,scalebar_ystart], 'Color','k', 'LineWidth',0.25);
    line([scalebar_v_xstart,scalebar_v_xstart], [scalebar_ystart,scalebar_v_yend], 'Color','k', 'LineWidth',0.25);
    % Add the corresponding text for the bars
    text(scalebar_h_xstart+0.5*scalebar_xunits, scalebar_ystart+1, ...
        scalebar_xlabel, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','top', ...
        'FontSize',2);
    text(scalebar_v_xstart+0.05, scalebar_ystart+0.5*scalebar_yunits, ...
        scalebar_ylabel, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','middle', ...
        'FontSize',2);
end

%% === Save Figures ==================================================== %%
pad = 0.4;   % inches of extra room for titles (top) and tick values (bottom)
H = params.sp_Dim(1)*1.45;
sp1.PaperSize = [params.sp_Dim(2)*1.8, H + 2*pad];
sp1.PaperPosition = [-2, -H*.125 + pad, params.sp_Dim(2)*2, params.sp_Dim(1)*1.75];
sp1.Renderer = 'painters'; sp1.RendererMode = 'manual';

sp2.PaperSize = sp1.PaperSize;
sp2.PaperPosition = sp1.PaperPosition;
sp2.Renderer = 'painters'; sp2.RendererMode = 'manual';

fprintf('\nSaving Subplot 1...')
tic; print(sp1, fullfile(params.folder, [params.file '_subplot.pdf']),'-dpdf'); toc
fprintf('Saving Subplot 2...')
tic; print(sp2, fullfile(params.folder, [params.file '_subplot2.pdf']),'-dpdf'); toc


function setSharedYLim(ax, y, yt)
% One y-range and the same y ticks (with values) for every axes in a column
for k = 1:numel(ax)
    set(ax(k), 'YLim', y, 'YTick', yt, 'YTickLabelMode', 'auto');
    ax(k).XAxis.FontSize = 7;
    ax(k).YAxis.FontSize = 7;
end

function setXTicks3(ax)
% X ticks with values at 0, mid, and max of the current x-range
xt = [0 max(ax.XLim)/2 max(ax.XLim)];
set(ax, 'XTick', xt, 'XTickLabel', arrayfun(@(v) num2str(v, 3), xt, 'UniformOutput', false));

