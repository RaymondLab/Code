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

sp = figure(1);
sp2 = figure(2);
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

% Gather Screensize information for figure placement
screensize = get( groot, 'Screensize' );
leftPos = 5;
botPos = 50;

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

    % fill data matrix with file information
    R.data(count,strcmpi(header,'start')) = params.segStarts(count);
    R.data(count,strcmpi(header,'end')) = params.segEnds(count);

    % Segment data to current time segment
    dataseg = datseg(data, [params.segStarts(count) params.segEnds(count)]);

    % Import Eye, Chair, and Drum velocity
    headvel = datchandata(dataseg,'hhvel');
    eyevelH = datchandata(dataseg,'hevel');
    drumvel = datchandata(dataseg,'htvel');
    eyepos = datchandata(dataseg,'hepos');

    % define vector of time
    ndatapoints = length(headvel);
    time = (1:ndatapoints)/samplerate;

    %% Set up variables for fitting data using a linear regression of Fourier Series
    y1 = sin(2*pi*freq*time(:));
    y2 = cos(2*pi*freq*time(:));
    constant = ones(ndatapoints,1);
    vars = [y1 y2 constant];
    warning off

    %% === DESACCADE =================================================== %%
    % Find saccades in eye movement and blank out an interval on either side
    
    % First pass remove baseline eye mvmt
    keep = abs(eyevelH) < 5*std(abs(eyevelH)) + mean(abs(eyevelH));        % First pass remove saccades
    b = regress(eyevelH(keep), vars(keep,:));  % Initial fit
    fit1 = vars *b;
    
    % OLD VERSION
    if params.newSac == 0

        eyevelHtemp = eyevelH - vars*b;            % Subtract fitted sine
        
        [eyevelH_des_temp, omitCenters, rawThres1] = desaccadeVelNew(eyevelHtemp, presaccadeN, postsaccadeN, params.saccadeThresh);
        omitH = isnan(eyevelH_des_temp);
        
    % NEW VERSION
    elseif params.newSac == 1
        [omitH, omitCenters, eye_pos_filt, eye_vel_pfilt] = desaccadeVel3(eyepos, samplerate, presaccadeN, postsaccadeN, freq, params, fit1);
    end
    
    % Use cleaned data for analysis?
    if params.cleanAnalysis
        eyevelH = eye_vel_pfilt;
    end
    
    eyevelH_des1 = eyevelH;
    eyevelH_des1(omitH) = NaN;
    R.data(count,strcmp(header,'saccadeFrac')) = mean(omitH);

    %% === FIT SINE FITS BASED ON DESACCADED TRACES ==================== %%
    % fit data using a linear regression (data specified by 'keep_'index)
    % b=coefficients, bint=95% confidence intervals, r=residual, rint=interval
    % stats include 1)R-square, 2)F statistics, 3)p value 4)error variance
    
    % No constant term bc sine centered at 0
    warning('off','stats:regress:NoConst') 

    % --- CHAIR VELOCITY --------------------------------------------------
    b = regress(headvel, vars);
    headH_amp = sqrt(b(1)^2+b(2)^2);
    headH_angle = rad2deg(atan2(b(2), b(1)));

    % --- DRUM VELOCITY ---------------------------------------------------
    b = regress(drumvel, vars);
    drumH_amp = sqrt(b(1)^2+b(2)^2);
    drumH_angle = rad2deg(atan2(b(2), b(1)));

    % calculate eye gain as VOR or OKR based on head signal
    if headH_amp > 3         % Chair signal
        refH_amp = headH_amp;
        refH_angle = headH_angle;
        idealEye = drumvel-headvel;
    elseif drumH_amp > 3      % No chair signal, drum signal
        refH_amp = drumH_amp;
        refH_angle = drumH_angle;
        idealEye = drumvel;
    else                    % No stimulus
        refH_amp = 1;
        refH_angle = 0;
        idealEye = zeros(1,ndatapoints);
    end

    % --- EYE VELOCITY ----------------------------------------------------
    [b,~,~,~,stat] = regress(eyevelH(~omitH), vars(~omitH,:));
    eyevelH_amp = sqrt(b(1)^2+b(2)^2);
    eyevelH_phase = rad2deg(atan2(b(2), b(1)));

    % --- EYE RELATIVE TO CHAIR/DRUM --------------------------------------
    eyevelH_rel_gain = eyevelH_amp/refH_amp;
    eyevelH_rel_phase = (eyevelH_phase - refH_angle);
    eyevelH_rel_phase = mod(eyevelH_rel_phase,360) - 180;
    warning on
    
    % --- Plot full segment, saccades, and fitted sine --------------------
    if params.do_individual
        
        figure(sp)
        subplot(params.sp_Dim(1), params.sp_Dim(2), params.figure_loc{params.temp_placement});
        params.temp_placement = params.temp_placement + 1;
        
        % Filter signal Visual?
        if params.cleanPlot
            eyevel_plot = eye_vel_pfilt;
            eyevel_des_plot = eye_vel_pfilt;
            eyevel_des_plot(omitH) = NaN;
        else
            eyevel_plot = eyevelH;
            eyevel_des_plot = eyevelH;
            eyevel_des_plot(omitH) = NaN;
        end

        
        % Plot 
        plot(time(1:length(eyevel_plot)), eyevel_plot, 'k', 'LineWidth', .3); hold on
        plot(time(1:length(eyevel_des_plot)), eyevel_des_plot, 'b', 'LineWidth', .3); 
        
        
        if params.cleanPlot
            plot(time, vars*b,':r', 'LineWidth', .5);
        else
            plot(time, vars*b,'r', 'LineWidth', .5);
        end
        
        % plot thresh if using old de-saccading method
        if params.newSac == 0
            plot(time, fit1 + rawThres1(1), ':r', 'LineWidth', .25);
            plot(time, fit1 + rawThres1(2), ':r', 'LineWidth', .25);
        end
        
        % Cosmetics
        xlim([0 length(eyevelH)/1000]);     ylim([-150 150])
        if count == nSegs
            xlabel('Time (s)');    
        end 
        title(datatype)
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
        
    end
    
    % --- Write to R.data -------------------------------------------------
    R.data(count,strcmpi(header,'headamp'))     = headH_amp;
    R.data(count,strcmpi(header,'headangle'))   = headH_angle;   
    R.data(count,strcmpi(header,'drumamp'))     = drumH_amp;
    R.data(count,strcmpi(header,'drumangle'))   = drumH_angle;    
    R.data(count,strcmp(header,'eyeHamp'))      = eyevelH_amp;
    R.data(count,strcmp(header,'eyeHangle'))    = eyevelH_phase;
    R.data(count,strcmp(header,'eyeHgain'))     = eyevelH_rel_gain;
    R.data(count,strcmp(header,'eyeHphase'))    = eyevelH_rel_phase;
    R.data(count,strcmp(header,'rsquare'))      = stat(1);
    R.data(count,strcmp(header,'pval'))         = stat(3);
    R.data(count,strcmp(header,'variance'))     = sqrt(stat(4)); % STD of error - more is worse
    
    %% === Calculate Cycle Averages ==================================== %%

    cycleLength = round(samplerate/freq);
    startpt = max(1,round(mod(-refH_angle,360)/360 * samplerate/freq));
    [idealEye_All, ~]   = vec2mat(idealEye(startpt:end), cycleLength, NaN);
    [eyeVel_All, ~]     = vec2mat(eyevelH(startpt:end), cycleLength, NaN);
    [eyeVel_AllDes, ~]  = vec2mat(eyevelH_des1(startpt:end), cycleLength, NaN);
    [headVel_All, ~]    = vec2mat(headvel(startpt:end), cycleLength, NaN);
    [DrumVel_All, ~]   = vec2mat(drumvel(startpt:end), cycleLength, NaN);
    [omit_All, ~]       = vec2mat(double(omitCenters(startpt:end)), cycleLength, NaN);

    % Remove fist cycles of segment? --> Optional and will be removed once
    % Drift issue is solved on the motors in the experimental protocol
    if 1
        eyeVel_All(1:5,:)    = []; % TODO Is this needed? Can use this partial cycle?
        eyeVel_AllDes(1:5,:) = [];
        headVel_All(1:5,:)   = [];
        omit_All(1:5,:)      = [];
        DrumVel_All(1:5,:)  = [];
        idealEye_All(1:5,:) = [];
    end
    
    
    eyeVel_All(end,:)    = []; % TODO Is this needed? Can use this partial cycle? 
    eyeVel_AllDes(end,:) = [];
    headVel_All(end,:)   = [];
    omit_All(end,:)      = [];
    DrumVel_All(end,:)  = [];
    idealEye_All(end,:) = [];
    
    eyeVel_AllDesMean   = nanmean(eyeVel_AllDes, 1);
    eyeVel_DesSem       = nanstd(eyeVel_AllDes)./sqrt(sum(~isnan(eyeVel_AllDes)));
    headVel_AllMean     = nanmean(headVel_All, 1);
    DrumVel_AllMean     = nanmean(DrumVel_All, 1);
    idealEye_AllMean    = nanmean(idealEye_All, 1);

    badCycles = any(omit_All,2);
    goodCount = sum(~badCycles);
    
    if goodCount > 0
        eyeVel_GoodCyclesMean = nanmean(eyeVel_All(~badCycles,:), 1);
    else
        eyeVel_GoodCyclesMean = zeros(size(eyeVel_All(1,:)));
    end
    
    eyeVel_GoodCycles_stdev = nanstd(eyeVel_All(~badCycles,:));
    
    R.eyeVel_GoodCyclesMean{count}  = eyeVel_GoodCyclesMean;
    R.eyevelMean{count} = eyeVel_AllDesMean;
    R.eyevelSem{count}  = eyeVel_DesSem;
    R.headMean{count}   = headVel_AllMean;
    R.data(count,strcmp(header,'nGoodCycles')) = goodCount;
    ttCycle = (1:cycleLength)/samplerate;
    
    %% === Save some variables for later =============================== %%
    switch params.analysis
        case 'Dark Rearing'
            if any(count == [1, 2, 3, 15, 16, 17])
                if count == 1
                    q = 1;
                end
                
                segObj(q).headVel = headVel_AllMean;
                segObj(q).DrumVel = DrumVel_AllMean;
                segObj(q).eyeVelDes = eyeVel_AllDesMean;
                segObj(q).eyeVelDesFit = sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp;
                segObj(q).eyeVelGood = eyeVel_GoodCyclesMean;
                segObj(q).SacFrac = mean(omitH);
                segObj(q).goodCcount = goodCount;
                segObj(q).ttCycle = ttCycle;
                segObj(q).freq = freq;
                segObj(q).sampleRate = samplerate;
                segObj(q).idealEye = idealEye_AllMean;
                
                q = q + 1;
                
                if q == 7
                    save('t0_t30.mat', 'segObj')
                end
            end   
            
        case 'Sriram_OKR'
            if any(count == [2, 3, 4, 15, 16, 17, 59, 60, 61])
                
                if count == 2
                    q = 1;
                end
                
                segObj(q).headVel = headVel_AllMean;
                segObj(q).DrumVel = DrumVel_AllMean;
                segObj(q).eyeVelDes = eyeVel_AllDesMean;
                segObj(q).eyeVelDesFit = sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp;
                segObj(q).eyeVelGood = eyeVel_GoodCyclesMean;
                segObj(q).SacFrac = mean(omitH);
                segObj(q).goodCcount = goodCount;
                segObj(q).ttCycle = ttCycle;
                segObj(q).freq = freq;
                segObj(q).sampleRate = samplerate;
                segObj(q).idealEye = idealEye_AllMean;
                
                q = q + 1;
                
                if q == 10
                    save('t1_t15_t60.mat', 'segObj')
                end
            end
    end

    %% === Plot Average Traces ========================================= %%
    
    if params.do_individual
        
        % Prep
        figure(sp)
        subplot(params.sp_Dim(1), params.sp_Dim(2), params.figure_loc{params.temp_placement});
        params.temp_placement = params.temp_placement + 1;
        
        % Choose Stim
        if contains(R.labels{count}, 'OKR')
            plotStim = DrumVel_AllMean;
            stimType = 'Drum';
        else
            plotStim = headVel_AllMean;
            stimType = 'Chair';
        end
        ylimits = double([floor(min(plotStim)*1.1) ceil(max(plotStim)*1.1)]);

        % plot data
        plot(ttCycle, smooth(eyeVel_GoodCyclesMean, 50),'b'); hold on
        plot(ttCycle, smooth(eyeVel_AllDesMean, 50), 'g');
        plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'r');
        plot(ttCycle, plotStim, 'k');
        plot(ttCycle, zeros(size(ttCycle)),'--k');
        
        % Cosmetics
        box off
        ylim(ylimits);
        xlim([0 max(ttCycle)]);
        
        if count == 1
            text(0-max(xlim)*.06, 0, 'deg/s', 'FontSize', 8, 'Rotation', 90)
        end
        if count == nSegs
            xlabel('Time (s)');    
        end 
        
        % Add Quick reference text
        text(max(ttCycle)*1.05, ylimits(2), ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))],'FontSize',7);
        text(max(ttCycle)*1.05, ylimits(2)-5, ['Rel Gain: ' num2str(eyevelH_rel_gain)], 'Fontsize', 7);
        text(max(ttCycle)*1.05, ylimits(2)-10, ['Eye Amp: ', num2str(eyevelH_amp,3)],'FontSize',7);
        text(max(ttCycle)*1.05, ylimits(2)-15, ['Rel. Phase: ', num2str(eyevelH_rel_phase,3)],'FontSize',7);
        text(max(ttCycle)*1.05, ylimits(2)-20, ['Stim: ', stimType],'FontSize',7);

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
    
    %% === Average Trace sb2 Plotting ================================== %%
    
    % Prep
    figure(sp2)
    meanFit = sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp;
    if any(~badCycles)
        
        % all individual Traces GOOD CYCLES ONLY
        subplot(params.sp_Dim(1), params.sp_Dim(2), (1:3) + row);
        plot(ttCycle, eyeVel_All(~badCycles,:)', 'b', 'LineWidth', .3); hold on;
        plot(ttCycle, eyeVel_GoodCyclesMean, 'k', 'LineWidth', 2);
        hline(0, ':k')
        
        % Cosmetics
        xlim([0 max(ttCycle)]);
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

        
        % Error bears around mean
        subplot(params.sp_Dim(1), params.sp_Dim(2), (4:6) + row);
        plot(ttCycle, eyeVel_GoodCyclesMean, 'k', 'LineWidth', 1); hold on
        plot(ttCycle, eyeVel_GoodCyclesMean + eyeVel_GoodCycles_stdev, ':k', 'LineWidth', .3);
        plot(ttCycle, eyeVel_GoodCyclesMean - eyeVel_GoodCycles_stdev, ':k', 'LineWidth', .3);
        plot(ttCycle, meanFit,'r', 'LineWidth', .3);
        hline(0, ':k')
        
        % find + peaks
        [maxVal, maxLoc] = max(meanFit);
        maxLoc = maxLoc/length(meanFit);
        line([maxLoc maxLoc], [0 maxVal], 'color', 'r', 'lineStyle', '--', 'LineWidth', .3);
        scatter(maxLoc, maxVal, 'r', 'filled', 'SizeData', .2)
        
        [maxVal, maxLoc] = max(eyeVel_GoodCyclesMean);
        maxLoc = maxLoc/length(eyeVel_GoodCyclesMean);
        line([maxLoc maxLoc], [0 maxVal], 'color', 'k', 'lineStyle', '--', 'LineWidth', .3);
        scatter(maxLoc, maxVal, 'k', 'filled', 'SizeData', .2)
        
        
        % find - peaks
        [minVal, minLoc] = min(meanFit);
        minLoc = minLoc/length(meanFit);
        line([minLoc minLoc], [0 minVal], 'color', 'r', 'lineStyle', '--', 'LineWidth', .3);
        scatter(minLoc, minVal, 'r', 'filled', 'SizeData', .2)
        
        [minVal, minLoc] = min(eyeVel_GoodCyclesMean);
        minLoc = minLoc/length(eyeVel_GoodCyclesMean);
        line([minLoc minLoc], [0 minVal], 'color', 'k', 'lineStyle', '--', 'LineWidth', .3);
        scatter(minLoc, minVal, 'k', 'filled', 'SizeData', .2)

        % Cosmetics
        title(datatype)
        xlim([0 max(ttCycle)]);
        ylim([-50 50])
        xticklabels([])
        yticks([])
        yticklabels([])
        box off

        % fft of traces    
        subplot(params.sp_Dim(1), params.sp_Dim(2), (7:9) + row);

        L = length(eyevelH(startpt:end));
        Y = fft(eyevelH(startpt:end));
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = samplerate*(0:(L/2))/L;
        plot(f,P1, 'k') 
        title([num2str(freq), 'Hz'])

        xlim([0 10])
        ylim([0 40])
        xticklabels([])
        yticks([])
        yticklabels([])
        box off

        % Text
        text(10, ylimits(2), ['Good Cycles: ', num2str(goodCount), '/', num2str(length(badCycles))],'FontSize',7);
        text(10, ylimits(2)-5, ['Rel Gain: ' num2str(eyevelH_rel_gain)], 'Fontsize', 7);
        text(10, ylimits(2)-10, ['Eye Amp: ', num2str(eyevelH_amp,3)],'FontSize',7);
        text(10, ylimits(2)-15, ['Rel. Phase: ', num2str(eyevelH_rel_phase,3)],'FontSize',7);
        text(10, ylimits(2)-20, ['Stim: ', stimType],'FontSize',7);
    end
    % other
    row = row + 10;
  
end


%% === Save Figures ==================================================== %%
sp.PaperSize = [params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
sp.PaperPosition = [0 0 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
sp2.PaperSize = [params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
sp2.PaperPosition = [0 0 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
fprintf('saving...')
%print(sp, '-fillpage',fullfile(params.folder, [params.file '_subplot.pdf']),'-dpdf', '-r300');
print(sp2, '-fillpage',fullfile(params.folder, [params.file '_subplot2.pdf']),'-dpdf', '-r300');
fprintf('Done!\n')