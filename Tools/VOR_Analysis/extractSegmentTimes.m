function [startTimes, endTimes] = extractSegmentTimes(folder)
%% This is a modified version of what was renamed as extractSegmentTimesXx.m

%% Setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist));
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));

%% Find Segment Start and stops
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['P' 'p' 'T' 't'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['P' 'p' 'T' 't'], 2))';   

%% Combine
starts = SampleKeyTimes([strfind(SampleKeys, 'Pp') strfind(SampleKeys, 'Tt')]);
ends = SampleKeyTimes([strfind(SampleKeys, 'Pp') strfind(SampleKeys, 'Tt')]+1);
startTimes = sort(starts)';
endTimes = sort(ends)';


%% Take the Experiment start time listed in the excel file, and remove incorrect segments

% Remove segments before start time
expmt_start_time = readmatrix(fullfile(folder,[file '.xlsx']), 'Sheet', 1, 'Range', 'G2:G2');
endTimes(startTimes < (expmt_start_time)) = [];
startTimes(startTimes < (expmt_start_time)) = [];

% Remove segments after experiment is over
rawCells = readcell(fullfile(folder,[file '.xlsx']), 'Sheet', 1, 'Range', 'A2:A500');
segment_Names = rawCells(~cellfun(@(c) any(ismissing(c)), rawCells));
if length(segment_Names) < length(endTimes)
    endTimes(length(segment_Names)+1:end) = [];
    startTimes(length(segment_Names)+1:end) = [];
end

%% Place start and end times into the excel file
if ~isempty(startTimes) && ~isempty(endTimes)
    writematrix(startTimes, fullfile(folder,[file '.xlsx']), 'Sheet', 'Sheet1', 'Range', 'D2');
    writematrix(endTimes, fullfile(folder,[file '.xlsx']), 'Sheet', 'Sheet1', 'Range', 'E2');
end
