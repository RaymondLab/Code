%% VORsineFit.m
% Input:
% data      - dat structure with channels
%   'htvel'
%   'hhvel'
%   'hepos'
%   'vepos'
%   'stim pul'
% tstart     - time window start times
% tstop     - time wndow stop times
% sinefreq  - frequency of stimulus for each segment
% labels    - label for each segment
% timepts   - time label for each segment (optional)
% velthres  - velocity threshold
%
% Output: R.data structure with data and header
%
% Modified 1/20/14 to remove vertical eye calculations


function R = VORsineFit_Delta7(data, tstart, tstop, sinefreq, labels, timepts, velthres, ploton, saccadeWindow)
%% Create R data Array and other parameters

% Set up cell structure to hold all R.data
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
    velthres = .7;
end

if ~exist('ploton','var')
    ploton = 1;
end

[~, filename] = fileparts(pwd);
samplerate = data(1).samplerate;
% time to exclude before saccade (s)
presaccade = saccadeWindow(1);   
% time to exclude after saccade (s)
postsaccade = saccadeWindow(2);
% convert back to # of datapoints
presaccadeN = round(presaccade*samplerate);
postsaccadeN = round(postsaccade*samplerate);

% Gather Screensize information for figure placement
screensize = get( groot, 'Screensize' );
leftPos = 5;
botPos = 50;

fprintf('Threshold = %g\n',velthres)
fprintf('Presaccade = %g ms\n',presaccade)
fprintf('Postsaccade = %g ms\n',postsaccade)

%% === Cycle through each segment ====================================== %%
for count = 1:nSegs

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

    % Read in data
    headvel         = datchandata(dataseg,'hhvel');
    eyeposH         = datchandata(dataseg,'hepos');
    if ~isempty(strfind([dataseg.chanlabel],'htvel'))
        drumvel         = datchandata(dataseg,'htvel');
    else
        drumvel = zeros(size(headvel));
    end

    % Calculate the eye velocity signal from the eye position signal
    eyevelH = [diff(eyeposH); 0]*samplerate;

    % Filter eye velocity to maintain consistency with eye coil
    N = 3;      % Filter order
    fc = 100;   % Cutoff frequency
    [b,a] = butter(N, fc/samplerate);
    eyevelH = filter(b,a,eyevelH);

    % define vector of time
    ndatapoints = length(headvel);
    time = (1:ndatapoints)/samplerate;

    %% Set up variables for fitting data using a linear regression of Fourier Series
    y1 = sin(2*pi*freq*time(:));
    y2 = cos(2*pi*freq*time(:));
    constant = ones(ndatapoints,1);
    vars = [y1 y2 constant];
    %     vars = [y1 y2];
    warning off

    %% === DESACCADE =================================================== %%
    % First pass remove baseline eye mvmt
    keep = abs(eyevelH) < 5*std(abs(eyevelH)) + mean(abs(eyevelH));        % First pass remove saccades
    b = regress(eyevelH(keep), vars(keep,:));  % Initial fit
    fit1 = vars *b;
    eyevelHtemp = eyevelH - vars*b;            % Subtract fitted sine
    
%     figure()
%     hold on
%     plot(abs(eyevelH))
%     hline(5*std(abs(eyevelH)) + mean(abs(eyevelH)))

    % Find saccades in eye movement and blank out an interval on either side
    [eyevelH_des_temp, omitCenters, rawThres1] = desaccadeVelNew(eyevelHtemp, presaccadeN, postsaccadeN, velthres);
    %[eyevelH_des_temp, omitCenters] = desaccadeVel(eyevelHtemp, velthres,  presaccadeN, postsaccadeN);
    omitH = isnan(eyevelH_des_temp);
    eyevelH_des1 = eyevelH;
    eyevelH_des1(omitH) = NaN;
 
    R.data(count,strcmp(header,'saccadeFrac')) = mean(omitH);

    %% === Plot the pre and post-saccade removal velocity traces ======= %%
    % Plot eye velocity trace with/without saccades
    % Smooth to affect appearance - doesn't change actual traces
    if ploton
        figure(count); clf
        plot_eyevelH = smoothdata(eyevelH, 'movmean', 10);
        plot_eyevelH_des = plot_eyevelH;
        plot_eyevelH_des(omitH) = NaN;
        %plot(time,plot_eyevelH,'k',time, plot_eyevelH_des,'b');
        plot(time,eyevelH, 'k',time, eyevelH_des1, 'b')
        hold on
        if exist('eyevelH_des', 'var')
            plot(time, eyevelH_des, 'b')
        end
        
        xlim([0 length(plot_eyevelH)/1000]);     ylim([-200 200])
        xlabel('Time (s)');    set(gcf,'Position',[leftPos botPos (screensize(3)-leftPos) 300]);
        yy = linspace(0, length(plot_eyevelH)/1000, length(eyevelHtemp));
        hold on

        if exist('rawThres', 'var')
            plot(yy, tempFit + rawThres(1), ':r');
            plot(yy, tempFit + rawThres(2), ':r');
        else
            plot(yy, fit1 + rawThres1(1), ':r');
            plot(yy, fit1 + rawThres1(2), ':r');
        end

        
    end


    %% === FIT SINE FITS BASED ON DESACCADED TRACES ==================== %%
    % fit data using a linear regression (data specified by 'keep_'index)
    % b=coefficients, bint=95% confidence intervals, r=residual, rint=interval
    % stats include 1)R-square, 2)F statistics, 3)p value 4)error variance
    warning('off','stats:regress:NoConst') % No constant term bc sine centered at 0

    % ------------CHAIR VELOCITY------------
    [b,~,~,~,~] = regress(headvel, vars);
    headH_amp = sqrt(b(1)^2+b(2)^2);
    headH_angle = rad2deg(atan2(b(2), b(1)));
    R.data(count,strcmpi(header,'headamp'))= headH_amp;
    R.data(count,strcmpi(header,'headangle'))= headH_angle;

    % ------------DRUM VELOCITY------------
    [b,~,~,~,~] = regress(drumvel, vars);
    drumH_amp = sqrt(b(1)^2+b(2)^2);
    drumH_angle = rad2deg(atan2(b(2), b(1)));
    R.data(count,strcmpi(header,'drumamp'))= drumH_amp;
    R.data(count,strcmpi(header,'drumangle'))= drumH_angle;

    % calculate eye gain as VOR or OKR based on head signal
    if headH_amp > 3         % Chair signal
        refH_amp = headH_amp;
        refH_angle = headH_angle;
        idealEye = drumvel-headvel;
    elseif drumH_amp >3      % No chair signal, drum signal
        refH_amp = drumH_amp;
        refH_angle = drumH_angle;
        idealEye = drumvel;
    else                    % No stimulus
        refH_amp = 1;
        refH_angle = 0;
        idealEye = zeros(1,ndatapoints);
    end

    % ------------ EYE VELOCITY------------
    [b,~,~,~,stat] = regress(eyevelH(~omitH), vars(~omitH,:));
    eyevelH_amp = sqrt(b(1)^2+b(2)^2);
    eyevelH_phase = rad2deg(atan2(b(2), b(1)));
    R.data(count,strcmp(header,'eyeHamp'))= eyevelH_amp;
    R.data(count,strcmp(header,'eyeHangle'))= eyevelH_phase;

    % ------------ EYE RELATIVE TO CHAIR/DRUM------------
    eyevelH_rel_gain = eyevelH_amp/refH_amp;
    eyevelH_rel_phase = (eyevelH_phase - refH_angle);
    eyevelH_rel_phase = mod(eyevelH_rel_phase,360) - 180;


    R.data(count,strcmp(header,'eyeHgain'))= eyevelH_rel_gain;
    R.data(count,strcmp(header,'eyeHphase'))= eyevelH_rel_phase;
    R.data(count,strcmp(header,'rsquare'))= stat(1);
    R.data(count,strcmp(header,'pval'))= stat(3);
    R.data(count,strcmp(header,'variance'))= sqrt(stat(4)); % STD of error - more is worse
    warning on

    % Plot fitted sine
    if ploton
        figure(count); hold on
        y = vars*b;
        plot(time, y,'r','LineWidth',1)
        %title(sprintf('%s %s %.1f Amp: %.2f Phase: %.2f',filename,datatype, timepts(count), eyevelH_amp, eyevelH_rel_phase),'interpreter','none')
        title(sprintf('%s        Amp: %.2f Phase: %.2f',datatype, eyevelH_amp, eyevelH_rel_phase),'interpreter','none')
    end

    %% === Get Cycle by Cycle Average ================================== %%
    % Find zero crossing of reference cycle
    cycleLength = round(samplerate/freq);
    startpt = max(1,round(mod(-refH_angle,360)/360 * samplerate/freq));
    zeroCross = startpt:cycleLength:ndatapoints;
    nCycles = length(zeroCross)-1;

    % --- Average of All Cycles, with Only Saccades Removed ---------------
    eyevelAll = NaN(nCycles,cycleLength);
    eyevelDesAll = NaN(nCycles,cycleLength);
    headAll = NaN(nCycles,cycleLength);
    eyevel2cycle = NaN(nCycles,cycleLength*2);

    for i = 1:nCycles
        eyevelAll(i,:) = eyevelH(zeroCross(i):zeroCross(i)+cycleLength-1)';
        eyevelDesAll(i,:) = eyevelH_des1(zeroCross(i):zeroCross(i)+cycleLength-1)';
        headAll(i,:) = headvel(zeroCross(i):zeroCross(i)+cycleLength-1)';
        if i<nCycles
            eyevel2cycle(i,:) = eyevelH_des1(zeroCross(i):zeroCross(i)+cycleLength*2-1)'; %*** temp
        end
    end


    eyevelDesMean = nanmean(eyevelDesAll);
    eyevelDesSem = nanstd(eyevelDesAll)./sqrt(sum(~isnan(eyevelDesAll)));
    headMean = nanmean(headAll);

    R.eyevelMean{count}  = eyevelDesMean;
    R.eyevelSem{count}  = eyevelDesSem;
    R.eyeVel2cycle{count} = eyevel2cycle';

    % --- Average of Only Good Cycles -------------------------------------
    badCycles = false(1,nCycles);
    for i = 1:nCycles
        if any(omitCenters(zeroCross(i):zeroCross(i)+cycleLength-1))
            badCycles(i) = 1;
        end
    end

    goodCount =  sum(~badCycles);
    if goodCount > 0
        eyevelCycleMean = nanmean(eyevelAll(~badCycles,:), 1);
    else
        eyevelCycleMean = zeros(size(eyevelAll(1,:)));
    end

    R.eyevelCycleMean{count}  = eyevelCycleMean;   
    R.data(count,strcmp(header,'nGoodCycles')) = goodCount;

    %% === Plot Cycle by Cycle Average ================================= %%
    if ploton     
        figure(count+100); clf;
        % plot data
        ttCycle = (1:cycleLength)/samplerate;
        plot(ttCycle, smooth(eyevelCycleMean, 50),'b'); hold on
        plot(ttCycle, smooth(eyevelDesMean, 50), 'g');
        plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'r')
        plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k');
        % Cosmetics
        box off
        set(gcf,'Position',[leftPos (botPos+400) 700 (screensize(4)-(botPos+400)-80)]);
        ylim([-30 30]);   xlim([0 max(ttCycle)])
        ylabel('deg/s');  xlabel('Time (s)');
        title('Average Traces');
        text (.01, 15, ['Good cycles: ', num2str(goodCount), '/', num2str(length(zeroCross))],'FontSize',10);
        text (.01, 12, ['Eye amp: ', num2str(eyevelH_amp,3)],'FontSize',10);
        legend({'Desaccaded full cycle removed', 'Desaccaded segments','Sine fit','Stimulus'},'EdgeColor','w')
        drawnow;
    end
end
