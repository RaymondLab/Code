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


function [R, sac_amps, sac_amps_light, sac_amps_dark] = VOR_SineFit_SEM(data, sinefreq, labels, timepts, params, sac_amps, sac_amps_light, sac_amps_dark)
%% === Create R data Array and other parameters ======================== %%

%set(groot, 'DefaultFigureVisible', 'off');
%sp1 = figure(); clf;
%sp2 = figure(); clf;
%histo = figure(); clf;
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
figure(1); clf;

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
    headVel = datchandata(dataseg,'hhvel');
    drumVel = datchandata(dataseg,'htvel');
    eyeVel = datchandata(dataseg,'hevel');
    %veltau = 5;
    %eyeVel = movingslopeCausal(datchandata(data,'hepos'),round(samplerate*veltau)*samplerate);
    eyePos = datchandata(dataseg,'hepos');

    % define vector of time
    segLength = length(headVel);
    segTime = (1:segLength)/samplerate;
    cycleLength = round(samplerate/freq);
    cycleTime = (1:cycleLength)/samplerate;


    %% === DISTRIBUTION ischange ============================== %%
    % calculate the distribution of saccades by using the isChange function
    % to find places where the data deviates largely from the mean. then,
    % use the S1 vector to find the slopes of all of the areas that quickly
    % deviated from the mean. Finally, FIND SOME WAY TO STORE LENGTH OF THESE
    % DEVIATIONS, THEN MULTIPLY BY THE SLOPE TO FIND AMPLITUDE

    % use isChange to find change points
    %[TF, seg_means_proc] = ischange(eyeVel_proc_des, 'linear');
    [TF, seg_means] = ischange(eyePos, 'mean');

    % make vectors with all of the amplitudes
    %sac_amps_proc = zeros(1,length(seg_means_proc) - 1);
    %sac_amps = zeros(1,length(seg_means) - 1);

    %for i = 2:length(seg_means_proc)
    %    sac_amps_proc(i-1) = (seg_means_proc(i) - seg_means_proc(i-1));
    %end

    amps_this_seg = []
    for i = 2:length(seg_means)
        if TF(i) == 1
          amp_temp = abs((seg_means(i) - seg_means(i-1)));
          if amp_temp  > 0
            sac_amps(length(sac_amps)+1) = amp_temp;
            amps_this_seg(length(amps_this_seg)+1) = amp_temp;
            if mod(count, 2) == 0
                sac_amps_light(length(sac_amps_light)+1) = amp_temp;
            else
                sac_amps_dark(length(sac_amps_dark)+1) = amp_temp;
            end
          end
        end
    end

    % want to use velocities * sample time to figure out average size of saccades

    fig_title = ['segment', string(count)];
    addHistogram(amps_this_seg, count, join(fig_title));
    %addLinePlot(amps_this_seg, count);



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



    %% === DISTRIBUTION findChangePts ========================= %%
    % calculate the distribution of saccades by using the isChange function
    % to find places where the data deviates largely from the mean. then,
    % use the S1 vector to find the slopes of all of the areas that quickly
    % deviated from the mean. Finally, FIND SOME WAY TO STORE LENGTH OF THESE
    % DEVIATIONS, THEN MULTIPLY BY THE SLOPE TO FIND AMPLITUDE

    % use findChangePts to find change points

    % multiply by the length of each change (for delta pos) or differentiate that vector (?)

    % create a histogram of the velocities/amplitudes

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
        referece_angle = headVel_angle;
        idealEyeVel = drumVel-headVel;
    % Drum/OKR Stimulus
    elseif drumVel_amp > 3
        reference_amp = drumVel_amp;
        referece_angle = drumVel_angle;
        idealEyeVel = drumVel;
    % No Motor Stimulus
    else
        reference_amp = 1;
        referece_angle = 0;
        idealEyeVel = zeros(1,segLength);
    end

    % eye calculations relative to drum/chair
    eyeVel_rel_gain = eyeVel_amp/reference_amp;
    eyeVel_rel_phase = (eyeVel_phase - referece_angle);
    eyeVel_rel_phase = mod(eyeVel_rel_phase,360) - 180;
    eyeVel_des_cycleFit = sin(2*pi*freq*cycleTime + deg2rad(eyeVel_rel_phase+180))*eyeVel_amp;
    warning on

    %% === Calculate Average and More ================================== %%

    startpt = max(1,round(mod(-referece_angle,360)/360 * samplerate/freq));

    [eyeVel_des_mat, eyeVel_des_cycleMean] = VOR_breakTrace(cycleLength, startpt, eyeVel_des);
    [~, headVel_cycleMean]                 = VOR_breakTrace(cycleLength, startpt, headVel);
    [~, drumVel_cycleMean]                 = VOR_breakTrace(cycleLength, startpt, drumVel);
    [omit_mat, ~]                          = VOR_breakTrace(cycleLength, startpt, double(omitCenters));
    [~, idealEye_cycleMean]                = VOR_breakTrace(cycleLength, startpt, idealEyeVel);

    % Calculate Extras
    badCycles = any(omit_mat,2);
    goodCount = sum(~badCycles);
    eyeVel_des_Sem       = nanstd(eyeVel_des_mat)./sqrt(sum(~isnan(eyeVel_des_mat)));

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
    ylimits = double([floor(min(plotStim)*1.1) ceil(max(plotStim)*1.1)]);

    % check for bad or missing stim
    if ylimits(1) == 0
        ylimits(1) = -.1;
    end

    %set(groot, 'CurrentFigure', histo);
    subplot(1, 1, 1);
    % create a histogram of the velocities/amplitudes
    %histogram(sac_amps_proc);


    if 0

        set(groot, 'CurrentFigure', sp1);
        subplot(params.sp_Dim(1), params.sp_Dim(2), (1:8) + row);

        % Plot proc or raw
        if params.cleanPlot
            plot(segTime(1:length(eyeVel_proc)), eyeVel_proc, 'k', 'LineWidth', .3); hold on
            plot(segTime(1:length(eyeVel_proc_des)), eyeVel_proc_des, 'b', 'LineWidth', .3);
            plot(segTime, vars*b,'r', 'LineWidth', .25);
        else
            plot(segTime(1:length(eyeVel_raw)), eyeVel, 'k', 'LineWidth', .3); hold on
            plot(segTime(1:length(eyeVel_raw_des)), eyeVel_raw_des, 'b', 'LineWidth', .3);
            plot(segTime, vars*b,'r', 'LineWidth', .5);
        end

        % Old de-saccade: Plot Thresh lines
        if params.newSac == 0
            plot(segTime, fit1 + rawThres1(1), ':r', 'LineWidth', .25);
            plot(segTime, fit1 + rawThres1(2), ':r', 'LineWidth', .25);
        end

        % Cosmetics
        xlim([0 max(segTime)]);
        ylim([-150 150])
        title(datatype)

        % Only add xlabel on final segment
        if count == nSegs
            xlabel('Time (s)');
        end

        % Text displaying absolute time of segment start
        text(0, max(ylim)*1.15, ['@ ' num2str(round(params.segStarts(count), 2)), 's'], 'FontSize', 7)

        % Manual y axis b/c matlab is literal garbage
        yticks([min(ylim) 0 max(ylim)])
        yticklabels({})
        text(0-max(xlim)*.02, .9*max(ylim), num2str(max(ylim)), 'FontSize', 7) % top
        text(0-max(xlim)*.02, 0, num2str(0), 'FontSize', 7) % 0
        text(0-max(xlim)*.02, .9*min(ylim), num2str(min(ylim)), 'FontSize', 7) % bottom

        % Manual x axis  b/c matlab is literal garbage
        xticks([0 round(max(xlim)/2, 1) max(xlim)])
        xticklabels({})
        text(max(xlim)*.99, min(ylim)*1.1, num2str(round(max(xlim))), 'FontSize', 7)
        text(max(xlim)/2, min(ylim)*1.1, num2str(round(max(xlim)/2)), 'FontSize', 7)
        drawnow;

        % --- Subplot-1: Cycle and Fit ---------------------------------- %
        subplot(params.sp_Dim(1), params.sp_Dim(2), (9:10) + row);

        % plot
        plot(cycleTime, smooth(eyeVel_good_cycleMean, 50),'b'); hold on
        plot(cycleTime, smooth(eyeVel_des_cycleMean, 50), 'g');
        plot(cycleTime, eyeVel_des_cycleFit, 'r');
        plot(cycleTime, plotStim, 'k');
        hline(0,'--k');

        % Cosmetics
        box off
        ylim(ylimits);
        xlim([0 max(cycleTime)]);

        if count == 1
            text(0-max(xlim)*.06, 0, 'deg/s', 'FontSize', 8, 'Rotation', 90)
        end

        if count == nSegs
            xlabel('Time (s)');
        end

        % Add quick reference text
        text(max(cycleTime)*1.05, ylimits(2), ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))],'FontSize',7);
        text(max(cycleTime)*1.05, ylimits(2)-5, ['Rel Gain: ' num2str(eyeVel_rel_gain)], 'Fontsize', 7);
        text(max(cycleTime)*1.05, ylimits(2)-10, ['Eye Amp: ', num2str(eyeVel_amp,3)],'FontSize',7);
        text(max(cycleTime)*1.05, ylimits(2)-15, ['Rel. Phase: ', num2str(eyeVel_rel_phase,3)],'FontSize',7);
        text(max(cycleTime)*1.05, ylimits(2)-20, ['Stim: ', stimType],'FontSize',7);

        % Manual y axis b/c matlab is literal garbage
        yticks([min(ylim) 0 max(ylim)])
        yticklabels({})
        text(0-max(xlim)*.05, .9*max(ylim), num2str(max(ylim)), 'FontSize', 7)
        text(0-max(xlim)*.05, 0, num2str(0), 'FontSize', 7)
        text(0-max(xlim)*.05, .9*min(ylim), num2str(min(ylim)), 'FontSize', 7)

        % Manual x axis b/c matlab is literal garbage
        xticks([0 round(max(xlim)/2, 1) max(xlim)])
        xticklabels({})
        text(max(xlim)*.99, min(ylim)*1.1, num2str(max(xlim)), 'FontSize', 7)
        text(max(xlim)/2, min(ylim)*1.1, num2str(max(xlim)/2), 'FontSize', 7)
        drawnow;
    end

    %% === Subplot-2: Mean Trace Visualization ========================= %%

    if 0

        % Prep
        set(groot, 'CurrentFigure', sp2);

        % Skip segments with 0 good cycles
        if any(~badCycles)

            % Figure A) Plot Full-Good Cycles & Mean Trace
            subplot(params.sp_Dim(1), params.sp_Dim(2), (1:3) + row);
            plot(cycleTime, eyeVel_des_mat(~badCycles,:)', 'b', 'LineWidth', .3); hold on;
            plot(cycleTime, eyeVel_good_cycleMean, 'k', 'LineWidth', 2);
            hline(0, ':k')

            % Cosmetics
            xlim([0 max(cycleTime)]);
            ylim([-50 50])
            yticks([min(ylim) 0 max(ylim)])
            yticklabels({})
            text(0-max(xlim)*.02, .9*max(ylim), num2str(max(ylim)), 'FontSize', 7) % top
            text(0-max(xlim)*.02, 0, num2str(0), 'FontSize', 7) % 0
            text(0-max(xlim)*.02, .9*min(ylim), num2str(min(ylim)), 'FontSize', 7) % bottom
            xticks([])
            xticklabels([])
            ylabel([num2str(goodCount), ' / ', num2str(length(badCycles))])
            box off

            % Figure B) Error Bars + Mean Trace
            subplot(params.sp_Dim(1), params.sp_Dim(2), (4:6) + row);
            plot(cycleTime, eyeVel_good_cycleMean, 'k', 'LineWidth', 1); hold on
            plot(cycleTime, eyeVel_good_cycleMean + eyeVel_good_cycleStd, ':k', 'LineWidth', .3);
            plot(cycleTime, eyeVel_good_cycleMean - eyeVel_good_cycleStd, ':k', 'LineWidth', .3);
            plot(cycleTime, eyeVel_des_cycleFit,'r', 'LineWidth', .3);
            hline(0, ':k')

            % find (+) peaks for Fit and Mean
            [maxVal, maxLoc] = max(eyeVel_des_cycleFit);
            maxLoc = maxLoc/length(eyeVel_des_cycleFit);
            line([maxLoc maxLoc], [0 maxVal], 'color', 'r', 'LineWidth', .3);
            %scatter(maxLoc, maxVal, 'r', 'filled', 'SizeData', .2)

            [maxVal, maxLoc] = max(eyeVel_good_cycleMean);
            maxLoc = maxLoc/length(eyeVel_good_cycleMean);
            line([maxLoc maxLoc], [0 maxVal], 'color', 'k', 'LineWidth', .3);
            %scatter(maxLoc, maxVal, 'k', 'filled', 'SizeData', .2)


            % find (-) peaks for Fit and Mean
            [minVal, minLoc] = min(eyeVel_des_cycleFit);
            minLoc = minLoc/length(eyeVel_des_cycleFit);
            line([minLoc minLoc], [0 minVal], 'color', 'r', 'LineWidth', .3);
            %scatter(minLoc, minVal, 'r', 'filled', 'SizeData', .2)

            [minVal, minLoc] = min(eyeVel_good_cycleMean);
            minLoc = minLoc/length(eyeVel_good_cycleMean);
            line([minLoc minLoc], [0 minVal], 'color', 'k', 'LineWidth', .3);
            %scatter(minLoc, minVal, 'k', 'filled', 'SizeData', .2)

            % Cosmetics
            title(datatype)
            xlim([0 max(cycleTime)]);
            ylim([-50 50])
            xticklabels([])

            yticks([])
            yticklabels([])
            box off

            % Figure C) Power Spectrum of Traces
            subplot(params.sp_Dim(1), params.sp_Dim(2), (7:9) + row);

            L = length(eyeVel(startpt:end));
            Y = fft(eyeVel(startpt:end));
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2+1));
            P1(2:end-1) = 2*P1(2:end-1);
            f = samplerate*(0:(L/2))/L;
            plot(f,P1, 'k')
            title([num2str(freq), 'Hz'])

            % Cosmetics
            xlim([0 15])
            ylim([0 30])
            xticks([1:15])
            set(gca, 'TickDir', 'out')
            xticklabels([])
            yticks([])
            yticklabels([])
            box off

            % Text
            text(10, max(ylim), ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))],'FontSize',7);
            text(10, max(ylim)-5, ['Rel Gain: ' num2str(eyeVel_rel_gain)], 'Fontsize', 7);
            text(10, max(ylim)-10, ['Eye Amp: ', num2str(eyeVel_amp,3)],'FontSize',7);
            text(10, max(ylim)-15, ['Rel. Phase: ', num2str(eyeVel_rel_phase,3)],'FontSize',7);
            text(10, max(ylim)-20, ['Stim: ', stimType],'FontSize',7);
        end

    end

    % Update Row information
    row = row + params.sp_Dim(2);

end


%% === Save Figures ==================================================== %%
if 0
    sp1.PaperSize = [params.sp_Dim(2)*1.8 params.sp_Dim(1)*1.45];
    sp1.PaperPosition = [-2 -sp1.PaperSize(2)*.125 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
    sp2.PaperSize = [params.sp_Dim(2)*1.8 params.sp_Dim(1)*1.45];
    sp2.PaperPosition = [-2 -sp1.PaperSize(2)*.125 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
    histo.PaperSize = [params.sp_Dim(2)*1.8 params.sp_Dim(1)*1.45];
    histo.PaperPosition = [-2 -sp1.PaperSize(2)*.125 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];

    fprintf('\nSaving Subplot 1...')
    tic; print(sp1, fullfile(params.folder, [params.file '_subplot.pdf']),'-dpdf', '-r250'); toc
    fprintf('\nSaving Histogram...')
    tic; print(histo, fullfile(params.folder, [params.file '_histogram.pdf']),'-dpdf', '-r250'); toc
    fprintf('Saving Subplot 2...')
    tic; print(sp2, fullfile(params.folder, [params.file '_subplot2.pdf']),'-dpdf', '-r250'); toc
end

function [h] = addHistogram(amps, segNum, t)
    hold on;
    h = histogram(amps, 'DisplayStyle', 'stairs');
    title('distribution by segment');
    %h.Normalization = 'probability';
    h.BinLimits = [0.0, 10.0];
    h.BinWidth = 0.0200;
    h.EdgeColor = chooseColor(segNum);

    hold on;
    %calculate Mean
    mu = median(amps);
    line([mu, mu], ylim, 'LineWidth', 2, 'Color', chooseColor(segNum));

% not used
function [s] = addLinePlot(amps, segNum)
    hold on;
    edges = zeros(1, 101);
    for i = 0:100
        edges(i+1) = .02 * i;
    end
    [N, e] = histcounts(amps, edges, 'Normalization', 'probability');
    %s = stem(e(1:100), N);
    %s.Color = chooseColor(segNum);
    %s.LineStyle = 'none';
    p = plot(e(1:100), N);
    p.Color = chooseColor(segNum);
    hold on;
    mu = median(amps);
    line([mu, mu], ylim, 'LineWidth', 2, 'Color', chooseColor(segNum));

function [c] = chooseColor(segNum)
    c = 'blue';
    if segNum == 2
        c = 'red';
    elseif segNum == 3
        c = 'green';
    elseif segNum == 4
        c = 'black';
    elseif segNum == 5
        c = 'cyan';
    elseif segNum == 6
        c = 'magenta';
    end
