%% VOR_SineFit.m
% Input:
% data      - dat structure with channels
%   'htvel'
%   'hhvel'
%   'hepos'
%   'vepos'
%   'stim pul'
% tstart    - time window start times
% tstop     - time wndow stop times
% sinefreq  - frequency of stimulus for each segment
% labels    - label for each segment
% timepts   - time label for each segment (optional)
% velthres  - velocity threshold
%
% Output: R.data structure with data and header
%
% Modified 1/20/14 to remove vertical eye calculations


function R = VOR_SineFit(data, tstart, tstop, sinefreq, labels, timepts, velthres, ploton, saccadeWindow, params)
%% === Create R data Array and other parameters ======================== %%

sp = figure(1);
set(sp, 'visible', 'off')

% Set up cell structure to hold all R.data

fprintf('\n\nGenerating Segment Figures...')

header = {'timept'  'start' 'end'   'eyeHgain' 'eyeHphase'...
    'headamp' 'headangle' 'drumamp' 'drumangle' 'eyeHamp' 'eyeHangle'...
    'saccadeFrac' 'rsquare' 'pval' 'variance','nGoodCycles'};

nSegs = length(tstart);
nCols = length(header);

R.data = NaN(nSegs,nCols);
R.header = header;
R.labels = labels;

if ~exist('timepts','var')
    timepts = mean([tstart tstop],2);
end
R.data(:,strcmpi(header,'timept')) = timepts;

% Other parameters
if ~exist('velthres','var')
    velthres = .55;
end

if ~exist('ploton','var')
    ploton = 1;
end

samplerate = data(1).samplerate;
presaccadeN = round(saccadeWindow(1)*samplerate);
postsaccadeN = round(saccadeWindow(2)*samplerate);

% Gather Screensize information for figure placement
screensize = get( groot, 'Screensize' );
leftPos = 5;
botPos = 50;

%% === Cycle through each segment ====================================== %%
for count = 1:nSegs
    
    %% === Prep Data =================================================== %%
    
    % Skip segments where frequency or start time is NaN
    if isnan(sinefreq(count)) || isnan(tstart(count))
        continue
    end

    % Get the current label and frequency
    datatype = labels{count};
    freq = sinefreq(count);

    % fill data matrix with file information
    R.data(count,strcmpi(header,'start')) = tstart(count);
    R.data(count,strcmpi(header,'end')) = tstop(count);

    % Segment data to current time segment
    dataseg = datseg(data, [tstart(count) tstop(count)]);

    % Import Eye, Chair, and Drum velocity
    headvel = datchandata(dataseg,'hhvel');
    eyevelH = datchandata(dataseg,'hevel');
    drumvel = datchandata(dataseg,'htvel');

    % Filter eye velocity to maintain consistency with eye coil
%     N = 3;      % Filter order
%     fc = 100;   % Cutoff frequency
%     [b,a] = butter(N, fc/samplerate);
%     eyevelH = filter(b,a,eyevelH);

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
    % First pass remove baseline eye mvmt
    keep = abs(eyevelH) < 5*std(abs(eyevelH)) + mean(abs(eyevelH));        % First pass remove saccades
    b = regress(eyevelH(keep), vars(keep,:));  % Initial fit
    fit1 = vars *b;
    eyevelHtemp = eyevelH - vars*b;            % Subtract fitted sine

    % Find saccades in eye movement and blank out an interval on either side
    [eyevelH_des_temp, omitCenters, rawThres1] = desaccadeVelNew(eyevelHtemp, presaccadeN, postsaccadeN, velthres);
    omitH = isnan(eyevelH_des_temp);
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
    [b,~,~,~,~] = regress(headvel, vars);
    headH_amp = sqrt(b(1)^2+b(2)^2);
    headH_angle = rad2deg(atan2(b(2), b(1)));

    % --- DRUM VELOCITY ---------------------------------------------------
    [b,~,~,~,~] = regress(drumvel, vars);
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
    if ploton
        % temp subplot solution
         %figure(sp);
%         set(sp, 'visible', 'off')
        subplot(params.sp_Dim(1), params.sp_Dim(2), params.figure_loc{params.temp_placement});
        params.temp_placement = params.temp_placement + 1;
        
        % Smooth Visuals
        if params.do_filter
            [bb,aa] = butter(2,[params.BPFilterLow, params.BPFilterHigh]/(samplerate/2),'bandpass');
            eyevelH_Filtered = filter(eyevelH,bb,aa);
            eyevelH_des1_Filered = filter(eyevelH_des1, bb, bb);
            
            N = 3;      % Filter order
            fc = [.5 10];   % Cutoff frequency
            [b,a] = butter(N, fc/samplerate, 'bandpass');
            eyevelH_F = filter(b,a,eyevelH);
            
            figure()
            subplot(2,1,1)
            plot(eyevelH_F)
            subplot(2,1,2)
            plot(eyevelH)
            
        end
        
        
        % Plot 
%         tempHandle = figure(count); clf
%         tempHandle.Visible = 'off';
%         set(count, 'visible', 'off');
        plot(time,plot_eyevelH,'k', 'LineWidth', .25); hold on   % SMOOTHED
        plot(time, plot_eyevelH_des,'b', 'LineWidth', .25);      % SMOOTHED
        %plot(time, eyevelH, 'k', 'LineWidth', .25); hold on       % RAW
        %plot(time, eyevelH_des1, 'b', 'LineWidth', .25);          % RAW
        plot(time, vars*b,'r', 'LineWidth', .5)
        plot(time, fit1 + rawThres1(1), ':r', 'LineWidth', .25);
        plot(time, fit1 + rawThres1(2), ':r', 'LineWidth', .25);
        
        % Cosmetics
        xlim([0 length(eyevelH)/1000]);     ylim([-200 200])
        if count == nSegs
            xlabel('Time (s)');    
        end 
%         set(gcf,'Position',[leftPos botPos (screensize(3)-leftPos) 300]);
        title(datatype)
        
        % Manual y axis b/c matlab is literal garbage
        yticks([min(ylim) 0 max(ylim)])
        yticklabels({})
        text(0-max(xlim)*.02, .9*max(ylim), num2str(max(ylim)), 'FontSize', 7) % top
        text(0-max(xlim)*.02, 0, num2str(0), 'FontSize', 7) % 0
        text(0-max(xlim)*.02, .9*min(ylim), num2str(min(ylim)), 'FontSize', 7) % bottom
        
        % Manual x axis
        xticks([0 round(max(xlim)/2, 1) max(xlim)])
        xticklabels({})
        text(max(xlim)*.99, min(ylim)*1.1, num2str(round(max(xlim))), 'FontSize', 7)
        text(max(xlim)/2, min(ylim)*1.1, num2str(round(max(xlim)/2)), 'FontSize', 7)
        drawnow;
        %box off
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
    end
    
    
    eyeVel_All(end,:)    = []; % TODO Is this needed? Can use this partial cycle? 
    eyeVel_AllDes(end,:) = [];
    headVel_All(end,:)   = [];
    omit_All(end,:)      = [];
    DrumVel_All(end,:)  = [];
    
    eyeVel_AllDesMean   = nanmean(eyeVel_AllDes);
    eyeVel_DesSem       = nanstd(eyeVel_AllDes)./sqrt(sum(~isnan(eyeVel_AllDes)));
    headVel_AllMean     = nanmean(headVel_All);
    chairVel_AllMean    = nanmean(DrumVel_All);

    badCycles = any(omit_All,2);
    goodCount = sum(~badCycles);
    
    if goodCount > 0
        eyeVel_GoodCyclesMean = nanmean(eyeVel_All(~badCycles,:), 1);
    else
        eyeVel_GoodCyclesMean = zeros(size(eyeVel_All(1,:)));
    end
    
    R.eyeVel_GoodCyclesMean{count}  = eyeVel_GoodCyclesMean;
    R.eyevelMean{count} = eyeVel_AllDesMean;
    R.eyevelSem{count}  = eyeVel_DesSem;
    R.headMean{count}   = headVel_AllMean;
    R.data(count,strcmp(header,'nGoodCycles')) = goodCount;

    %% === Plot Averages =============================================== %%
    
    if ploton
        
        % Prep
        subplot(params.sp_Dim(1), params.sp_Dim(2), params.figure_loc{params.temp_placement});
        params.temp_placement = params.temp_placement + 1;
        
        % Choose Stim
        if contains(R.labels{count}, 'OKR')
            plotStim = chairVel_AllMean;
            stimType = 'Drum';
        else
            plotStim = headVel_AllMean;
            stimType = 'Chair';
        end
        ylimits = double([floor(min(plotStim)*1.1) ceil(max(plotStim)*1.1)]);

        % plot data
        ttCycle = (1:cycleLength)/samplerate;
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
end
sp.PaperSize = [params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
sp.PaperPosition = [0 0 params.sp_Dim(2)*2 params.sp_Dim(1)*1.75];
fprintf('saving...')
print(sp, '-fillpage',fullfile(params.folder, [params.file '_subplot.pdf']),'-dpdf', '-r300');
fprintf('Done!\n')