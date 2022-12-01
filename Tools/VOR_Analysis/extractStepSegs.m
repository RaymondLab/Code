function [startTimes, endTimes] = extractStepSegs(folder)
spike2_file_extension = '.smrx';

%% setup
[~, file] = fileparts(folder);
chanlist = readSpikeFile(fullfile(folder,[file spike2_file_extension]),[]);
chanindsAll = [chanlist.number];
chaninds = find(      arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanlist)     );
rawdata = importSpike(fullfile(folder,[file spike2_file_extension]),chanindsAll(chaninds));

%% Pulse Experiments
SampleKeys = strcat(rawdata.samplerate(any(rawdata.samplerate == ['P' 'p' 'l' 'L'], 2))');
SampleKeyTimes = rawdata.data(any(rawdata.samplerate == ['P' 'p' 'l' 'L'], 2))';

% Pulse only
start_Pp_loc = SampleKeyTimes(strfind(SampleKeys, 'Pp'));
end_Pp_loc = SampleKeyTimes(strfind(SampleKeys, 'Pp')+1);

% test/train segs
start_Plp_loc = SampleKeyTimes(strfind(SampleKeys, 'Plp'));
start_Plp_loc = [start_Plp_loc SampleKeyTimes(strfind(SampleKeys, 'Plp')+1)];
end_Plp_loc = SampleKeyTimes(strfind(SampleKeys, 'Plp')+2);
end_Plp_loc = [end_Plp_loc SampleKeyTimes(strfind(SampleKeys, 'Plp')+1)];

% okr
start_Lp_loc = SampleKeyTimes(strfind(SampleKeys, 'Lp'));
end_Lp_loc = SampleKeyTimes(strfind(SampleKeys, 'Lp')+1);

% vor
start_Llp_loc = SampleKeyTimes(strfind(SampleKeys, 'Llp')+1);
start_Llp_loc = start_Llp_loc + 1.5; % Hack-y. There is no actual start KeyboardMark
end_Llp_loc = SampleKeyTimes(strfind(SampleKeys, 'Llp')+2);


startTimes = sort([start_Pp_loc start_Plp_loc start_Lp_loc start_Llp_loc])';
endTimes = sort([end_Pp_loc end_Plp_loc end_Lp_loc end_Llp_loc])';

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
