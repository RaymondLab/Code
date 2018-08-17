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


SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['S' 's' 'L'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['S' 's' 'L'], 2))';

start_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss'));
end_Ss_loc = SampleKeyTimes(strfind(SampleKeys, 'Ss')+1);
start_SL_loc = SampleKeyTimes(strfind(SampleKeys, 'SL'));
end_SL_loc = SampleKeyTimes(strfind(SampleKeys, 'SL')+1);

if ~isempty(start_SL_loc)
    start_Ls_loc = SampleKeyTimes(strfind(SampleKeys, 'Ls'));
    end_Ls_loc = SampleKeyTimes(strfind(SampleKeys, 'Ls')+1);
    start_LL_loc = SampleKeyTimes(strfind(SampleKeys, 'LL'));
    end_LL_loc = SampleKeyTimes(strfind(SampleKeys, 'LL')+1);
else
    start_Ls_loc = [];
    end_Ls_loc = [];
    start_LL_loc = [];
    end_LL_loc = [];
end

startTimes = sort([start_Ss_loc start_SL_loc start_Ls_loc start_LL_loc])';
endTimes = sort([end_Ss_loc end_SL_loc end_Ls_loc end_LL_loc])';

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
