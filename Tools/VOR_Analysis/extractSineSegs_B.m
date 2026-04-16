%{
Maxwell Gagnon July 19

This detects segments from a small set of experiments that Jaydev ran in
the summer of 2019.

%}
function [startTimes, endTimes] = extractSineSegs_B(folder)
%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(      arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist)     );
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));
rawrecData = importSpike(fullfile(folder,[file '.smr']),chanindsAll(4));

%% New Sine Experiments
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['0' '1' '2' '3' '4'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['0' '1' '2' '3' '4'], 2))';

% test 1
starts = SampleKeyTimes(strfind(SampleKeys, '40'));
ends = SampleKeyTimes(strfind(SampleKeys, '40')+1);

% test 2
starts = [starts SampleKeyTimes(strfind(SampleKeys, '41'))];
ends = [ends SampleKeyTimes(strfind(SampleKeys, '41')+1)];

% block test
starts = [starts SampleKeyTimes(strfind(SampleKeys, '23'))];
ends = [ends SampleKeyTimes(strfind(SampleKeys, '23')+1)];

% block train
starts = [starts SampleKeyTimes(strfind(SampleKeys, '31'))];
ends = [ends SampleKeyTimes(strfind(SampleKeys, '31')+1)];

starts = [starts SampleKeyTimes(strfind(SampleKeys, '30'))];
ends = [ends SampleKeyTimes(strfind(SampleKeys, '30')+1)];

%% Combine
startTimes = sort(starts)';
endTimes = sort(ends)';


%% Take the Experiment start time listed in the excel file, and remove incorrect segments

% remove segments before start time
expmt_start_time = readmatrix(fullfile(folder,[file '.xlsx']), 'Sheet', 1, 'Range', 'G2:G2');
endTimes(startTimes < (expmt_start_time)) = [];
startTimes(startTimes < (expmt_start_time)) = [];

% remove segments after experiment is over
rawCells = readcell(fullfile(folder,[file '.xlsx']), 'Sheet', 1, 'Range', 'A2:A500');
segment_Names = rawCells(~cellfun(@(c) any(ismissing(c)), rawCells));
if length(segment_Names) < length(endTimes)
    endTimes(length(segment_Names)+1:end) = [];
    startTimes(length(segment_Names)+1:end) = [];
end

%% place start and end times into the excel file
if ~isempty(startTimes)
    writematrix(startTimes, fullfile(folder,[file '.xlsx']), 'Sheet', 'Sheet1', 'Range', 'D2');
    writematrix(endTimes, fullfile(folder,[file '.xlsx']), 'Sheet', 'Sheet1', 'Range', 'E2');
end
