function [startTimes, endTimes] = extractSegmentTimes(folder, params)
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
startTimes = sort([start_Ss_loc start_SLs_loc start_SLL_loc start_SPs_loc start_SPL_loc start_special])';
endTimes = sort([end_Ss_loc end_SLs_loc end_SLL_loc end_SPs_loc end_SPL_loc end_special])';

if contains(params.analysis, 'Default (Sine Only)')
    startTimes = sort(starts)';
    endTimes = sort(ends)';
end

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
xlswrite(fullfile(folder,[file '.xlsx']), startTimes, 'Sheet1', 'D2')
xlswrite(fullfile(folder,[file '.xlsx']), endTimes, 'Sheet1', 'E2')
