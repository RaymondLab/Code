function R = VORstim(data, tstart, tstop, freq, labels, timepts,velthresh, pulseDur, ploton,mask)
% VORstepfit.m
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

%% Get sampling rate
samplerate = data(1).samplerate;
stimL = 'TTL3';
stimR = 'TTL4';
[~, filename] = fileparts(pwd);


%% Set up cell structure to hold all R.data
nsegs = length(tstart);
header = {'timept','start','end','saccadeFrac','nGoodCycles'};
nCols = length(header);
R.data = NaN(length(tstart),nCols); % Main array for storing R.data
R.header = header;
R.labels = labels;
R.means{nsegs} = [];

if exist('timepts','var')
    R.data(:,strcmpi(header,'timept')) = timepts;
else
    R.data(:,strcmpi(header,'timept')) = mean([tstart tstop],2);
end

%% Default parameters
if ~exist('velthresh','var')
    velthresh = 100;
    oldSaccade = 0;
end

if ~exist('ploton','var')
    ploton = 1;
end
if isempty(pulseDur)
   pulseDur = 1./(freq*2);
   pulseDur = .5*ones(1,nsegs);
end

%% define time before and after saccade to remove
presaccade = 0.1;
postsaccade = 0.3;

fprintf('Threshold = %g\n',velthresh)
fprintf('Presaccade = %g ms\n',presaccade)
fprintf('Postsaccade = %g ms\n',postsaccade)

presaccadeN = round(presaccade*samplerate); %convert back to # of datapoints
postsaccadeN = round(postsaccade*samplerate); %convert back to # of datapoints

%% Cycle through each segment
for count = 1:nsegs
    
    % Skip segments where frequency is given (analyze separately)
    if ~mask(count)
        continue
    end
    
    % Get the current times, label
    timestart = tstart(count);
    timeend = tstop(count);
    datatype = labels{count};
    
    % fill data matrix with file information
    R.data(count,strcmpi(header,'start'))= timestart;
    R.data(count,strcmpi(header,'end'))= timeend;
    
    % Segment data to current time segment
    dataseg = datseg(data, [tstart(count) tstop(count)]);
    
    % Read in data
    eyeposH         = datchan(dataseg,'hepos');
    eyevelH         = datchan(dataseg,'hevel');
    
    % Determine left or right or both
    Rside = ~isempty(strfind(datatype, 'R'));
    Lside = ~isempty(strfind(datatype, 'L'));
    
    tBefore = .1;  % Time before stim start to plot
%     tAfter = .5;  % Time after stim end to plot
    tAfter = .2;  % Time after stim end to plot
    
    if Rside && ~Lside
        stimChan = stimR;
    else
        stimChan = stimL;
    end
    
    stimPlus = datchandata(dataseg,[stimChan '+']);
    stimMinus = datchandata(dataseg,[stimChan '-']);
%     stimon = datchandata(dataseg,[stimChan '+']);
%     stimoff = datchandata(dataseg,[stimChan '-']);
    if stimMinus(1) < stimPlus(1)
        stimMinus(1) = []; end
    if stimPlus(end) > stimMinus(end)
        stimPlus(end) = [];
    end
        
%     figure; plot(stimPlus,ones(size(stimPlus)),'+r',stimMinus,ones(size(stimMinus)),'+b')

    % Deal with multi-pulse trains of stim
    isi = diff(stimPlus);
    isithresh = .2 % Minimum distance between stims to consider separate pulse (eg. 10 Hz = 100 ms)
    stimon = stimPlus(find(isi>isithresh)+1); stimon(end)=[];
    stimoff = stimMinus(isi>isithresh); stimoff(1)=[];
%     figure; plot(stimon,ones(size(stimon)),'+r',stimoff,ones(size(stimoff)),'+b')

    shortisi = isi(isi<isithresh); 
    stimfreq = mean(1./shortisi)
    
    nstims = length(stimon);   
    
    period = mean(diff(stimon))
    duration = mode(stimoff-stimon)
    
    if Rside && Lside
        T = period;
    elseif Lside || Rside
        T = tBefore + duration + tAfter;
    else
        T = period;
    end
    
    %% Calculate the eye velocity signal from the eye position signal
    % by differentiating eye position signal
    %     smoothfactor = 50;
    %     eyevelH =eyeposH; eyevelH.chanlabel = 'hevel'; eyevelH.units = 'deg/s';
    %     eyevelH.data =[diff(smooth(eyeposH.data,1)); 0]*samplerate;
    %     eyevelH =  smooth(filt100Hz(eyevelH),smoothfactor);
    
    %% Find saccades in eye movement and blank out an interval on either side
    eyevelDesaccadeRaw = desaccadeVel(eyevelH.data, velthresh, presaccadeN, postsaccadeN);
    omitH = isnan(eyevelDesaccadeRaw);
    
    % Fraction saccades
    R.data(count,strcmp(header,'saccadeFrac')) = mean(omitH);
    
    % Add channel heposDes with NaNs for saccades
    eyeposDesaccade = eyeposH;
    eyeposDesaccade.data(omitH) = NaN;
    eyeposDesaccade.chanlabel = 'heposDes';
    dataseg(end+1) = eyeposDesaccade;
    
    % Add channel hevelDes with NaNs for saccades
    eyevelDesaccade = eyevelH;
    eyevelDesaccade.data(omitH) = NaN;
    eyevelDesaccade.chanlabel = 'hevelDes';
    dataseg(end+1) = eyevelDesaccade;
    
    dataseg(datchanind(dataseg,{'hepos1','hepos2'})) = [];    
    
    %% Calculate means    
    [segMeansCycle, nGoodCycles] = datsegmeans(dataseg,stimon,[-tBefore T-tBefore],0,1); % 1 = shiftsegs; 1 = ignore segs with NaNs
    segSemsCycle = datsegsems(dataseg,stimon,[-tBefore T-tBefore],0,1); % 1 = shiftsegs; 1 = ignore segs with NaNs
    [segMeans, nCycles] = datsegmeans(dataseg,stimon,[-tBefore T-tBefore],0,0); % 1 = shiftsegs; 0 = NaNs %*** changes shiftsegs to 0 3/17/14
    segSems = datsegsems(dataseg,stimon,[-tBefore T-tBefore],0,0); % 1 = shiftsegs; 0 = NaNs %*** changes shiftsegs to 0 3/17/14    
   
    %% Make stim chans for plotting: TTL1 high ==> +1; TTL2 high ==> -1; else 0
    stimData1 = cumsum(datchandata(segMeansCycle,[stimL '+']) -datchandata(segMeansCycle,[stimL '-']) );
    stimData1 = stimData1>mean(stimData1);
    
    stimData2 = cumsum(datchandata(segMeansCycle,[stimR '+']) -datchandata(segMeansCycle,[stimR '-']) );
    stimData2 = stimData2>mean(stimData2);
    
    stimdat = datchan(segMeansCycle,[stimL '+']);
    stimdat.data = stimData1-stimData2; stimdat.chanlabel = 'stim';
    
    segMeansCycle(end+1) = stimdat;
    segMeans(end+1) = stimdat;    
    
    % Store the current means
    R.meansCycle{count} = segMeansCycle; % Cuts out entire cycle with saccade, better option
    R.means{count} = segMeans;
    R.data(count,strcmp(header,'nGoodCycles')) = nGoodCycles;
    R.semsCycle{count} = segSemsCycle;
    R.sems{count} = segSems;

    
    %% Plot data
    if ploton
        % Plot eye velocity trace with/without saccades
        figure(count); pause(.01);clf
        plot([eyevelDesaccade,eyevelH],'Overlaid',1); ylim([-100 100])
        title(datatype)
        xlim([eyevelDesaccade.tstart eyevelDesaccade.tend])
        pause(.01);
        
        % Plot the cycle means
        figure(count+100); pause(.01); clf
        if ~all(isnan(datchandata(segMeansCycle,'heposDes')))
%             plot(datchan(segMeans,{'stim','hevelDes','hepos'}),'Color',[.5 .5 .5]); hold on
            plot(datchan(segMeansCycle,{'stim','hevelDes','heposDes'}),'Color','k')
        end
        subplot(3,1,1);
        title(sprintf('%s %s %.1f',filename,datatype, timepts(count)),'interpreter','none')
        subplot(3,1,2);
        title(sprintf('%i/%i good cycles',nGoodCycles,nCycles))
        print(gcf,['resultfig' datatype '.jpg'],'-djpeg')
        pause(.01)

%% Plot SEM for entire cycle v. pointbnypoint desaccading only - velocity
% tt = dattime(segMeans(1));
% figure(count+300); clf;
% subplot(2,1,1); title([sprintf('%s %s %.1f\n',filename,datatype, timepts(count))...
%     sprintf('Cycle means, n = %i\n',nGoodCycles)],'interpreter','none' )
% fillerror(tt,datchandata(segMeansCycle,'hevelDes'),datchandata(segSemsCycle,'hevelDes'),'k',1);
% xlim([tt(1) tt(end)])
% subplot(2,1,2); title(sprintf('Desaccaded means, n = %i',nCycles))
% fillerror(tt,datchandata(segMeans,'hevelDes'),datchandata(segSems,'hevelDes'),'k',1);
% 
% xlim([tt(1) tt(end)])
%     export_fig(sprintf('%s %s %.1f',filename,datatype, timepts(count)), '-painters', '-pdf')


        
    end
end
