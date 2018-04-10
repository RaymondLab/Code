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


function R = VORsineFit(data, tstart, tstop, sinefreq, labels, timepts,velthres,oldSaccade, ploton)
% close all
clf
set(0, 'DefaultFigurePaperPositionMode', 'auto');
[~, filename] = fileparts(pwd);

%% Get sampling rate
samplerate = data(1).samplerate;
nsegs = length(tstart); % Number of segments to analyze

%% Set up cell structure to hold all R.data
header = {'timept'  'start' 'end'   'eyeHgain' 'eyeHphase'...
    'headamp' 'headangle' 'drumamp' 'drumangle' 'eyeHamp' 'eyeHangle'...
    'saccadeFrac' 'rsquare' 'pval' 'variance','nGoodCycles'};
nCols = length(header);
R.data = NaN(nsegs,nCols); % Main array for storing R.data
R.header = header;
R.labels = labels;
if ~exist('timepts','var')
    timepts = mean([tstart tstop],2);
end
R.data(:,strcmpi(header,'timept')) = timepts;

%% Default parameters
if ~exist('velthres','var')
    velthres = 100;
    oldSaccade = 0;
end

if ~exist('ploton','var')
    ploton = 1;
end

presaccade = 0.1;   % time to exclude before saccade (s)
postsaccade = 0.3;  % time to exclude after saccade (s)

fprintf('Threshold = %g\n',velthres)
fprintf('Presaccade = %g ms\n',presaccade)
fprintf('Postsaccade = %g ms\n',postsaccade)

presaccadeN = round(presaccade*samplerate); %convert back to # of datapoints
postsaccadeN = round(postsaccade*samplerate); %convert back to # of datapoints

%% Cycle through each segment
for count = 1:nsegs

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
    if ~oldSaccade
        keep = abs(eyevelH) < 1.5*velthres;        % First pass remove saccades
        b = regress(eyevelH(keep), vars(keep,:));  % Initial fit
        eyevelHtemp = eyevelH - vars*b;            % Subtract fitted sine
    else
        eyevelHtemp = eyevelH;                      % OLD METHOD
    end

    % Find saccades in eye movement and blank out an interval on either side
    [eyevelH_des_temp, omitCenters] = desaccadeVel(eyevelHtemp, velthres, presaccadeN, postsaccadeN);
    omitH = isnan(eyevelH_des_temp);
    eyevelH_des = eyevelH;
    eyevelH_des(omitH) = NaN;
    % Fraction saccades
    R.data(count,strcmp(header,'saccadeFrac')) = mean(omitH);

    %% === Plot the pre and post-saccade removal velocity traces ======= %%
    % Plot eye velocity trace with/without saccades
    if ploton
        figure(count); clf

        % Smooth to affect appearance - doesn't change actual traces
        plot_eyevelH = smooth(eyevelH,50);
        plot_eyevelH_des = plot_eyevelH;
        plot_eyevelH_des(omitH) = NaN;
        plot(time,plot_eyevelH,'k',time, plot_eyevelH_des,'b');
        xlim([0 40]);     ylim([-30 30])
        xlabel('Time (s)');    set(gcf,'Position',[10 100 1000 300]);
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
        title(sprintf('%s %s %.1f Amp: %.2f Phase: %.2f',filename,datatype, timepts(count), eyevelH_amp, eyevelH_rel_phase),'interpreter','none')
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
        eyevelDesAll(i,:) = eyevelH_des(zeroCross(i):zeroCross(i)+cycleLength-1)';
        headAll(i,:) = headvel(zeroCross(i):zeroCross(i)+cycleLength-1)';
        if i<nCycles
            eyevel2cycle(i,:) = eyevelH_des(zeroCross(i):zeroCross(i)+cycleLength*2-1)'; %*** temp
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

    % Max G 11/17 - Don't take the mean of a vector. This happens when ther
    % e is only one good cycle. When taking a mean of a vector, it returns
    % a scalar. That's bad.
    [row, ~] = size(eyevelAll(~badCycles,:));
    if row > 1
        eyevelCycleMean = nanmean(eyevelAll(~badCycles,:));
    elseif row == 1
        eyevelCycleMean = eyevelAll(~badCycles,:);
    elseif row == 0
        eyevelCycleMean = zeros(size(eyevelAll(1,:)));
    end

    %eyevelCycleMean = nanmean(eyevelAll(~badCycles,:));
    R.eyevelCycleMean{count}  = eyevelCycleMean;
    goodCount =  sum(~badCycles);
    R.data(count,strcmp(header,'nGoodCycles')) = goodCount;

    %% === Plot Cycle by Cycle Average ================================= %%
    if ploton     
        figure(count+100); clf;

        ttCycle = (1:cycleLength)/samplerate;
        plot(ttCycle, smooth(eyevelCycleMean, 50),'b'); hold on
        plot(ttCycle, smooth(eyevelDesMean, 50), 'g');
        plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'r')
        plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k');

        box off
        ylim([-15 15]);   xlim([0 max(ttCycle)])
        ylabel('deg/s');  xlabel('Time (s)');
        %     plot(t, mean(Stim_avg), 'k');

        title(['Hor. Eye Vel: ', datatype ' ' num2str(timepts(count))]);
        text (.1, 13.5, ['Good cycles: ', num2str(goodCount), '/', num2str(length(zeroCross))],'FontSize',10);
        text (.1, 12, ['Eye amp: ', num2str(eyevelH_amp,3)],'FontSize',10);
        legend({'Desaccaded full cycle removed', 'Desaccaded segments','Sine fit','Stimulus'},'EdgeColor','w')
        drawnow;
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Added by Max Gagnon 11/17. This section takes the difference of the
    % last three (t = 30) recording's means and the first three (t = 0) recording's
    % mean and plots them.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if count == 1 % initialize each vector

        goodCountSumBegin       = [];
        goodCountSumEnd         = [];
        trueSegments            = length(tstart(~isnan(tstart)));
        headVelSegments         = [];
        drumVelSegments         = [];
        startEyeVelCycleSegments = [];
        startEyeVelDesSegments  = [];
        endEyeVelCycleSegments  = [];
        endEyeVelDesSegments    = [];
    end

    % keep a running sum of each waveform
    if count == 1|| count == 2 || count == 3

        % get head vel. segments
        headVelLong     = datchandata(dataseg,'hhvel');
        headVelSegments = [headVelSegments; headVelLong(zeroCross(i):zeroCross(i)+cycleLength-1)'];

        % get drum vel. segments
        drumVelLong     = datchandata(dataseg,'htvel');
        drumVelSegments = [drumVelSegments; drumVelLong(zeroCross(i):zeroCross(i)+cycleLength-1)'];

        % record the number of good cycles for each segment
        goodCountSumBegin         = [goodCountSumBegin; goodCount];
        startEyeVelCycleSegments  = [startEyeVelCycleSegments; (smooth(eyevelCycleMean, 50) .* goodCount)'];
        startEyeVelDesSegments    = [startEyeVelDesSegments; (smooth(eyevelDesMean, 50) .* goodCount)'];

    elseif count == (trueSegments - 3) || count == (trueSegments - 2) || count == (trueSegments - 1) % fourth to last, third to last, second to last

        % get head vel. segments
        headVelLong     = datchandata(dataseg,'hhvel');
        headVelSegments = [headVelSegments; headVelLong(zeroCross(i):zeroCross(i)+cycleLength-1)'];

        % get drum vel. segments
        drumVelLong     = datchandata(dataseg,'htvel');
        drumVelSegments = [drumVelSegments; drumVelLong(zeroCross(i):zeroCross(i)+cycleLength-1)'];

        goodCountSumEnd     = [goodCountSumEnd; goodCount];
        endEyeVelCycleSegments  = [endEyeVelCycleSegments; (smooth(eyevelCycleMean, 50) .* goodCount)'];
        endEyeVelDesSegments    = [endEyeVelDesSegments; (smooth(eyevelDesMean, 50) .* goodCount)'];

    end
end

% get the mean of the head vel over the 6 trials in question
headVelMean = mean(headVelSegments, 1);

% get the mean of the drum vel over the 6 trials in question
drumVelMean = mean(drumVelSegments, 1);

% calc mean of each channel
startEyeVelCycleMean = sum(startEyeVelCycleSegments,1) ./ sum(goodCountSumBegin);
startEyeVelDesMean  = sum(startEyeVelDesSegments, 1) ./ sum(goodCountSumBegin);
endEyeVelCycleMean  = sum(endEyeVelCycleSegments, 1) ./ sum(goodCountSumEnd);
endEyeVelDesMean    = sum(endEyeVelDesSegments, 1) ./ sum(goodCountSumEnd);

% get difference of the means
BlueDiff = endEyeVelCycleMean - startEyeVelCycleMean;
GreenDiff = endEyeVelDesMean - startEyeVelDesMean;

% data of plot
figure(count+1000); clf;
ttCycle = (1:cycleLength)/samplerate;
plot(ttCycle, BlueDiff,'b'); hold on
plot(ttCycle, GreenDiff, 'g');
diffMeanData = data(1);
diffMeanData.data = BlueDiff;
%diffMeanData.chanlabel = 'htvel';
finalLabel = 'VOR 1Hz';

%% This is a modified version of the  VORsineFit function that
% specifically handles the mean waveforms. In order to accomadate
% this new functionality, there would have to be to many changes to
% the original function, so a new one was created. See Max Gagnon
% for more details.
[eyevelH_offset, eyevelH_rel_phase, eyevelH_amp, eyeHgain] = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, BlueDiff', headVelMean', drumVelMean');
plot(ttCycle, eyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'r')
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k');
box off

% Cosmetics of plot
ylim([-15 15]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Delta Hor. Eye Vel: ', datatype(1:8) ' ']);
%text (.1, 13.5, ['Good cycles: ', num2str(goodCount), '/', num2str(nCycles)],'FontSize',10);
text (.1, 12, ['Eye amp: ', num2str(eyevelH_amp,3)],'FontSize',10);
legend({'t_3_0 - t_0 mean (Desaccaded full cycle removed)', 't_3_0 - t_0 mean (Desaccaded segments)','Sine fit','Stimulus'},'EdgeColor','w')
drawnow;

%% plot difference of raw traces
figure(1067); clf;
ttCycle = (1:cycleLength)/samplerate;
plot(ttCycle, startEyeVelCycleMean,'m'); hold on
plot(ttCycle, endEyeVelCycleMean, 'r'); hold on
plot(ttCycle, BlueDiff,'b', 'LineWidth', 1);
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k'); hold on

% Cosmetics of plot
ylim([-15 15]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Mean t_0, Mean t_3_0, & Delta Hor. Eye Vel: ', datatype(1:8) ' ']);
legend({'t_0 mean (Desaccaded full cycle removed)', 't_3_0 mean (Desaccaded segments)','t_3_0 mean - t_0 mean (Desaccaded segments)','Stimulus','zero'},'EdgeColor','w')
drawnow;

%% calc Sine fit for startEyeVelCycleMean & endEyeVelCycleMean
figure(1068); clf;
[STARTeyevelH_offset, STARTeyevelH_rel_phase, STARTeyevelH_amp, STARTeyeHgain] = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, startEyeVelCycleMean',mean(headVelSegments(1:3,:), 1)', mean(drumVelSegments(1:3,:), 1)');
[ENDeyevelH_offset, ENDeyevelH_rel_phase, ENDeyevelH_amp, ENDeyeHgain]         = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, endEyeVelCycleMean', mean(headVelSegments(4:end,:), 1)', mean(drumVelSegments(4:end,:), 1)');

% plot differences in sine fits
plot(ttCycle, STARTeyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(STARTeyevelH_rel_phase+180))*STARTeyevelH_amp,'m'); hold on
plot(ttCycle, ENDeyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(ENDeyevelH_rel_phase+180))*ENDeyevelH_amp,'r'); hold on
plot(ttCycle, eyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'b')
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k'); hold on

% Cosmetics of plot
figure(1068)
ylim([-15 15]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Sine Fit Comparison: t_3_0, t_0 mean, & Difference  Hor. Eye Vel:', datatype(1:8) ' ']);
legend({'t_0 mean Sine Fit (Desaccaded full cycle removed)', 't_3_0 mean Sine Fit (Desaccaded segments)','t_3_0 mean - t_0 mean Sine Fit (Desaccaded segments)', 'Stimulus','zero'},'EdgeColor','w')
drawnow;

%% add the new delta data to the results structure
vec1 = NaN(length(R.header), 1)';
vec1(4) =  eyeHgain;
vec1(5) =  eyevelH_rel_phase;
vec2 = NaN(length(R.header), 1)';
vec2(4) =  ENDeyeHgain - STARTeyeHgain;
vec2(5) = ENDeyevelH_rel_phase - STARTeyevelH_rel_phase;
R.data(trueSegments+1,:) = vec1;
R.data(trueSegments+2,:) = vec2;
while length(R.labels) < trueSegments+2
    R.labels = [R.labels; 'Apples'];
end
