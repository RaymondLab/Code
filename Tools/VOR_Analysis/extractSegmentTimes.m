function [startTimes, endTimes] = extractSegmentTimes(folder, first45sec)
%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist));
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));

%% Find Segment Start and stops
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['X' 'x'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['X' 'x'], 2))';

%% BUG FIX for an experiment protocol error - December 2019 (Max's Fault)
% There was an error in a VERY small amount of experiments where the final
% segment did not record the 'x' that denoted the end of a segment. This
% bug was fixed in the experiment protcol late December 2019. 

if isempty(SampleKeys)
    startTimes = [];
    endTimes = [];
    return
elseif SampleKeys(end) == 'X'
    SampleKeys(end+1) = 'x';
    SampleKeyTimes(end+1) = SampleKeyTimes(end) + 45;
end
   

%% Combine
starts = SampleKeyTimes(strfind(SampleKeys, 'Xx'));
ends = SampleKeyTimes(strfind(SampleKeys, 'Xx')+1);
startTimes = sort(starts)';
if first45sec
    endTimes = startTimes + 45;
else
    endTimes = sort(ends)';
end

%% Take the Experiment start time listed in the excel file, and remove incorrect segments

% remove segments before start time
expmt_start_time = xlsread(fullfile(folder,[file '.xlsx']), 1, 'G2' );
endTimes(startTimes < (expmt_start_time)) = [];
startTimes(startTimes < (expmt_start_time)) = [];

% Retrieve segment names given on excel sheet
[~, segment_Names, ~] = xlsread(fullfile(folder,[file '.xlsx']), 1, 'A2:A500' );

% Check for any segment names that contain the substring 'first'
first_segment_ids = find(contains(segment_Names, 'first', 'IgnoreCase',true));

% For any "first" segments, insert the start/end times corresponding to the following segment
% For example, if row 5 is "FIRST_5" and row 6 is "x2", then the start/end times of row 5 will reflect the first 5 minutes of "x2"
if ~isempty(first_segment_ids)
    for ii = 1:length(first_segment_ids)
        segIdx = first_segment_ids(ii);
        segDuration = str2double(regexp(segment_Names{segIdx}, '-?\d+', 'match', 'once')) * 60;
        startTimes = [startTimes(1:segIdx-1); startTimes(segIdx); startTimes(segIdx:end)];
        endTimes = [endTimes(1:segIdx-1); startTimes(segIdx+1)+segDuration; endTimes(segIdx:end)];
    end
end

% remove segments after experiment is over
if length(segment_Names) < length(endTimes)
    endTimes(length(segment_Names)+1:end) = [];
    startTimes(length(segment_Names)+1:end) = [];
end

%% place start and end times into the excel file
if ~isempty(startTimes) && ~isempty(endTimes)
    xlswrite(fullfile(folder,[file '.xlsx']), startTimes, 'Sheet1', 'D2')
    xlswrite(fullfile(folder,[file '.xlsx']), endTimes, 'Sheet1', 'E2')
end
