function [startTimes, endTimes] = extractSegmentTimes(folder)
spike2_file_extension = '.smrx';
%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file spike2_file_extension]),[]);
chanindsAll = [chanlist.number];
chaninds = find(arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist));
rawdata = importSpike(fullfile(folder,[file spike2_file_extension]),chanindsAll(chaninds));
%ADDED By Sima For Sriram dark rearing(8.12.2022)
idx = find(ismember(rawdata.samplerate, '5'));
rawdata.samplerate(idx+1)='5';
%
%% Find Segment Start and stops
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['X' 'x'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['X' 'x'], 2))';

%% BUG FIX for an experiment protocol error - December 2019 (Max's Fault)
% There was an error in a VERY small amount of experiments where the final
% segment did not record the 'x' that denoted the end of a segment. This
% bug was fixed in the experiment protcol late December 2019. 

if SampleKeys(end) == 'X'
    SampleKeys(end+1) = 'x';
    SampleKeyTimes(end+1) = SampleKeyTimes(end) + 45;
end
   

%% Combine
starts = SampleKeyTimes(strfind(SampleKeys, 'Xx'));
ends = SampleKeyTimes(strfind(SampleKeys, 'Xx')+1);
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
