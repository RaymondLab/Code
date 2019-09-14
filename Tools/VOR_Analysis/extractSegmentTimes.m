function [startTimes, endTimes] = extractSegmentTimes(folder)
%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist));
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));

%% Find Segment Start and stops
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['X' 'x'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['X' 'x'], 2))';

starts = SampleKeyTimes(strfind(SampleKeys, 'Xx'));
ends = SampleKeyTimes(strfind(SampleKeys, 'Xx')+1);

%% Combine
startTimes = sort(starts)';
endTimes = sort(ends)';


%% Take the Experiment start time listed in the excel file, and remove incorrect segments

% remove segments before start time
expmt_start_time = xlsread(fullfile(folder,[file '.xlsx']), 1, 'G2' );
endTimes(startTimes < (expmt_start_time)) = [];
startTimes(startTimes < (expmt_start_time)) = [];

% remove segments after experiment is over
[~, segment_Names, ~] = xlsread(fullfile(folder,[file '.xlsx']), 1, 'A2:A500' );
if length(segment_Names) < length(endTimes)
    endTimes(length(segment_Names)+1:end) = [];
    startTimes(length(segment_Names)+1:end) = [];
end

%% place start and end times into the excel file
if ~isempty(startTimes) && ~isempty(endTimes)
    xlswrite(fullfile(folder,[file '.xlsx']), startTimes, 'Sheet1', 'D2')
    xlswrite(fullfile(folder,[file '.xlsx']), endTimes, 'Sheet1', 'E2')
end
