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
function [startTimes, endTimes] = extractSineSegs(folder)
%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file '.smr']),[]);
chanindsAll = [chanlist.number];
chaninds = find(      arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist)     );
rawdata = importSpike(fullfile(folder,[file '.smr']),chanindsAll(chaninds));
rawrecData = importSpike(fullfile(folder,[file '.smr']),chanindsAll(4));

%% Sine Experiments
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['S' 's' 'L' 'P'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['S' 's' 'L' 'P'], 2))';

% find the correct start/stop patterns
start_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss'));
end_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss')+1);

% light on training
start_SLs_loc = SampleKeyTimes(strfind(SampleKeys, 'SLs'));
start_SLs_loc = [start_SLs_loc SampleKeyTimes(strfind(SampleKeys, 'SLs')+1)];
end_SLs_loc = SampleKeyTimes(strfind(SampleKeys, 'SLs')+2); %Normal
%end_SLs_loc = SampleKeyTimes(strfind(SampleKeys, 'SLs')+3); %Dark Resting
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

%% Special Case: The file recording ends before the sine ends (no 's' after 'S')
if SampleKeys(end) == 'S'
    start_special = SampleKeyTimes(end);
    end_special = rawrecData.tend;
    
    print('yes')
else
    start_special = [];
    end_special = [];
end

%% Combine 
startTimes = sort([start_Ss_loc start_SLs_loc start_SLL_loc start_SPs_loc start_SPL_loc start_special])';
endTimes = sort([end_Ss_loc end_SLs_loc end_SLL_loc end_SPs_loc end_SPL_loc end_special])';


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
