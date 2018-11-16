%{
Maxwell Gagnon 7/30/18

This script finds the 'S' 's' and 'L' key markers from a spike2 recordings
in order to automatically determine the start and stop of SINE segments.

'S' indicates START of a SINEWAVE segment. Either Drum, Chair or Both
's' indicates END of a SINEWAVE segment. Either Drum, Chair or Both
'L' indicates LIGHT ON
'l' indicates LIGHT OFF

NOTE: THIS SCRIPT ONLY WORKS WHEN THE WHOLE EXPERIMENT IS BASED ON SINEWAVES

DO NOT USE FOR EXPERIMENTS WITH STEPS!!
DO NOT USE FOR EXPERIMENTS WITH STIM-ONLY SEGMENTS!!

%}
function [startTimes, endTimes] = extractSegments(folder)
%% new setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(      arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist)     );
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));

% find S,s,L samplekeys and their corresponding times
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['S' 's' 'L' 'P'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['S' 's' 'L' 'P'], 2))';

% find the correct start/stop patterns
start_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss'));
end_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss')+1);

% light on training
start_SLs_loc = SampleKeyTimes(strfind(SampleKeys, 'SLs'));
start_SLs_loc = [start_SLs_loc SampleKeyTimes(strfind(SampleKeys, 'SLs')+1)];
end_SLs_loc = SampleKeyTimes(strfind(SampleKeys, 'SLs')+2);
end_SLs_loc = [end_SLs_loc SampleKeyTimes(strfind(SampleKeys, 'SLs')+1)];

start_SLL_loc = SampleKeyTimes(strfind(SampleKeys, 'SLL'));
start_SLL_loc = [start_SLL_loc SampleKeyTimes(strfind(SampleKeys, 'SLL')+1)];
end_SLL_loc = SampleKeyTimes(strfind(SampleKeys, 'SLL')+1);
end_SLL_loc = [end_SLL_loc SampleKeyTimes(strfind(SampleKeys, 'SLL')+2)];

% Pulse on Training
start_SPs_loc = SampleKeyTimes(strfind(SampleKeys, 'SPs'));
start_SPs_loc = [start_SPs_loc SampleKeyTimes(strfind(SampleKeys, 'SPs')+1)];
end_SPs_loc = SampleKeyTimes(strfind(SampleKeys, 'SPs')+2);
end_SPs_loc = [end_SPs_loc SampleKeyTimes(strfind(SampleKeys, 'SPs')+1)];

start_SPL_loc = SampleKeyTimes(strfind(SampleKeys, 'SPL'));
start_SPL_loc = [start_SPL_loc SampleKeyTimes(strfind(SampleKeys, 'SPL')+1)];
end_SPL_loc = SampleKeyTimes(strfind(SampleKeys, 'SPL')+2);
end_SPL_loc = [end_SPL_loc SampleKeyTimes(strfind(SampleKeys, 'SPL')+1)];


startTimes = sort([start_Ss_loc start_SLs_loc start_SLL_loc start_SPs_loc start_SPL_loc])';
endTimes = sort([end_Ss_loc end_SLs_loc end_SLL_loc end_SPs_loc end_SPL_loc])';

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
