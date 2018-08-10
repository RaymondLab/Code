function buildToSpike2(ops) 
    
%% this function will take a channel of waveforms in either a .txt 
%  or .mda format and add it to an existing .smr file
% 
% See 'options.m' file for various things like file location and initial
% sorting method
%
% - waveform data should be in SAME FOLDER as smr file
% - waveform data should have the SAME NAME as smr file
% - options.m should be in SAME FOLDER as this file
% - this process requires SON Interface from  - http://ced.co.uk/upgrades/spike2matson
%
% Maxwell Gagnon


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Part 1 - Set Up %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
fprintf('\nLocation of build:\n')
%options;
%fprintf(ops.target) % TODO folder as input instead of single file
activateCEDS64;


% get a row vector of spike times and (if applicable) row vector of unit #s
if isequal(ops.method, 'mountainSort')
    
    waveFile = strrep(ops.target, '.smr', '.curated.mda');
    waveFile = strrep(waveFile, 'smrFiles', 'mdaFiles');
    spikeData = readmda(waveFile);
    
    % check that spikes don't appear too close to the begining of the file
    for i = 1:length(spikeData)
        if spikeData(2:i) / ops.sampleRate > ops.spike_window_waveform(1,1) * -1
            break
        else
            spikeData(:,i) = [];
        end
    end 
    
    % extract & convert spikeTime from samples to s
    spikeTimes = spikeData(2,:) ./ ops.sampleRate;
    % Unit information is stored in the third column of the mda data matrix.
    units = spikeData(3,:);    
elseif isequal(ops.method, 'plexon')
    spikeFile = strrep(ops.target, '.smr', '_MS.txt');
    spikeFile = strrep(spikeFile, 'smrFiles', 'txtFiles');
    spikeData = csvread(spikeFile);
    spikeTimes = spikeData(:,2)';
    units = spikeData(:,1)';
end

% Gather various data from .smr file
data = importSpike(ops.target);
chanind = datchanind(data,ops.chanName);
channumber = data(chanind).chanval;

% TEMP REMOVE IF NEEDED: Hack to fix .0004 offest issue
%spikeTimes = spikeTimes + .0004;




% Extract waveforms using plexon spike times and waveform window info
waveforms = datsegdata(datchan(data(chanind), channumber), spikeTimes, ops.spike_window_waveform);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Part 2 - Copy Original Channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nCopying smr file...')

% Open file & gather info
fhand1 = CEDS64Open(ops.target);
if (fhand1 <= 0);  fprintf(fhand1); CEDS64ErrorMessage(fhand1); unloadlibrary ceds64int; return; end
[~, OldFileId]  = CEDS64AppID( fhand1 );
timebase 		= CEDS64TimeBase( fhand1 );
maxchans 		= CEDS64MaxChan( fhand1 );

% Create new file & set info to match original file
newFile = strrep(ops.target, '.smr', ops.newFileName);
fhand2 = CEDS64Create( newFile, maxchans);
if (fhand2 <= 0);  fprintf(fhand2); CEDS64ErrorMessage(fhand2); unloadlibrary ceds64int; return; end
CEDS64TimeBase( fhand2, timebase );
CEDS64AppID( fhand2, OldFileId );

% copy all existing channels from original file (fhand1) to new file
% (fhand2)
fprintf('\nCopied Channels:')
for m = 1:maxchans
    chan = CEDS64ChanType( fhand1, m );

    if (chan > 0) % is there a channel m?
        chandiv = CEDS64ChanDiv( fhand1, m );
        rate = CEDS64IdealRate( fhand1, m );
    end

    switch(chan)
        case 0 % there is no channel with this number
        case 1 % ADC channel ( this is typically the ephys channel )
            [~, shortvals, shorttime] = CEDS64ReadWaveS( fhand1, m, ops.maxPoints2Read, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 1, rate );
            CEDS64WriteWave( fhand2, m, shortvals, shorttime );
            fprintf(' %d', m)
        case 2 % Event Fall
            [~, evtimes] = CEDS64ReadEvents( fhand1, m, ops.maxPoints2Read, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 2 );
            CEDS64WriteEvents( fhand2, m, evtimes );
            fprintf(' %d', m)
        case 3 % Event Rise
            [~, evtimes] = CEDS64ReadEvents( fhand1, m, ops.maxPoints2Read, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 3 );
            CEDS64WriteEvents( fhand2, m, evtimes );
            fprintf(' %d', m)
        case 4 % Event Both
            [~, levtimes, levinit] = CEDS64ReadLevels(fhand1, m, ops.maxPoints2Read, 0);
            CEDS64SetLevelChan( fhand2, m, rate );
            CEDS64SetInitLevel( fhand2, m, levinit );
            CEDS64WriteLevels( fhand2, m, levtimes );
            fprintf(' %d', m)
        case 5 % Marker
            [~, markervals] = CEDS64ReadMarkers( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetMarkerChan( fhand2, m, rate, 5 );
            CEDS64WriteMarkers( fhand2, m, markervals );
            fprintf(' %d', m)
        case 6 % Wave Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, wmarkervals] = CEDS64ReadExtMarks( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetExtMarkChan(fhand2, m, rate, 6, Rows, Cols, chandiv);
            CEDS64WriteExtMarks( fhand2, m, wmarkervals);
            fprintf(' %d', m)
        case 7 % Real Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, rmarkervals] = CEDS64ReadExtMarks( fhand1, m, ops.maxPoints2Read, 0 );
            CEDS64SetExtMarkChan( fhand2, m, rate, 7, Rows, Cols, -1);
            CEDS64WriteExtMarks( fhand2, m, rmarkervals);
            fprintf(' %d', m)
        case 8 % Text Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, tmarkervals] = CEDS64ReadExtMarks( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetExtMarkChan( fhand2, m, rate, 8, Rows, Cols, -1 );
            CEDS64WriteExtMarks( fhand2, m, tmarkervals); 
            fprintf(' %d', m)         
        case 9 % Realwave
            [~, floatvals, floattime] = CEDS64ReadWaveF( fhand1, m, ops.maxPoints2Read, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 9, rate );
            CEDS64WriteWave( fhand2, m, floatvals, floattime );
            fprintf(' %d', m)
    end

    % copy units, comments, offsets etc.
    if (chan > 0)
        [ ~, sComment ] = CEDS64ChanComment( fhand1, m );
        [ ~ ] = CEDS64ChanComment( fhand2, m, sComment );
        [ ~, dOffset ] = CEDS64ChanOffset( fhand1, m );
        [ ~ ] = CEDS64ChanOffset( fhand2, m, dOffset );
        [ ~, dScale ] = CEDS64ChanScale( fhand1, m );
        [ ~ ] = CEDS64ChanScale( fhand2, m, dScale );
        [ ~, dTitle ] = CEDS64ChanTitle( fhand1, m );
        [ ~ ] = CEDS64ChanTitle( fhand2, m, dTitle );
        [ ~, sUnits ] = CEDS64ChanUnits( fhand1, m );
        [ ~ ] = CEDS64ChanUnits( fhand2, m, sUnits );
    end
end
fprintf('\n...Complete!\nAll channels copied!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Part 3 - Add New Channel %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Adding new channel...')

% find/create a free/new channel and gather relevant data
wmarkchan       	= CEDS64GetFreeChan( fhand2 );          %	wmarkchan = free channel #
sampRate            = CEDS64IdealRate(fhand2, channumber);  %	sampling rate (Hz) - 50,000 % input
chanType            = 6;                                    % 	Channel type (6 for waveMark) - 6
waveWindowLength    = length(waveforms(:,1));               % 	length of waveform (in ticks) - sampling window gained from wavematrix
tickDiv             = CEDS64ChanDiv(fhand2, channumber);    % 	gather the channel data tick division
[ ~, chanOffSet] 	= CEDS64ChanOffset(fhand2, channumber);	%	gather the channel data offset value (usually 0)
[ ~, chanScale] 	= CEDS64ChanScale(fhand2, channumber);	%	set scale to two

createret = CEDS64SetExtMarkChan(fhand2, wmarkchan, sampRate, chanType, waveWindowLength, ops.waveformChans, tickDiv);
if createret ~= 0, warning('wavemarker channel not created correctly'); end

% Add channel info (optional)
CEDS64ChanTitle( fhand2, wmarkchan, ops.chanTitle );
CEDS64ChanComment( fhand2, wmarkchan, ops.chanComment );
CEDS64ChanUnits( fhand2, wmarkchan, ops.chanUnits );

% scale and offset the original data 
CEDS64ChanOffset(fhand2, wmarkchan, chanOffSet);
CEDS64ChanScale(fhand2, wmarkchan, chanScale);
waveforms = ((waveforms .* 6553.6)./ chanScale) - chanOffSet;

% each spike is considered a CEDWaveMark() object. It contains information about 
% the waveform, start time (in ticks), and unit number
numOfSpikes = length(waveforms(1,:));
wmarkdata(numOfSpikes, 1) = CEDWaveMark();

for m=1:numOfSpikes
    wmarkdata(m).SetData(waveforms(:,m));
    wmarkdata(m).SetTime(CEDS64SecsToTicks( fhand2, (spikeTimes(m) + ops.spike_window_waveform(1))));
    wmarkdata(m).SetCode(1, units(m));
end

% add that data to the new channel
fillret = CEDS64WriteExtMarks(fhand2, wmarkchan, wmarkdata);
if fillret < 0, warning('wave-marker channel not filled correctly'); end

% tidy up
CEDS64CloseAll();
unloadlibrary ceds64int;
fprintf('\n...Complete!\nChannel Added!\n\n')
toc

