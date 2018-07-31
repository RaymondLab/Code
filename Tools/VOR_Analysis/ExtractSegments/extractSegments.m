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

%% Setup
cd('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Delta 07 Amin Data\Gain Up\1 hz gain up\WT\Exp-Delta07-Ch01-04-11102017');
pathname = cd;
activateCEDS64;
[~, filenameroot] = fileparts(pathname);
A = CEDS64Open(fullfile(pathname,[filenameroot '.smr']));
[iRead, vMObj] = CEDS64ReadMarkers(A, 31, 1000, 0);

%% Extract the S, s, and L Markers from the recording 
g = 1;
for i = 1:length(vMObj) 
    switch char(vMObj(i).m_Code1)
        case {'S', 's', 'L'}
            newObj(g) = vMObj(i);
            g = g + 1;
    end
end

%% use S, s, and L to find the start and end times of the experiment
startTimes = [];
endTimes = [];
k = 1;
j = 1;
for i = 1:length(newObj)
    
    % find S start Times
    if char(newObj(i).m_Code1) == 'S' 
        startTimes(k) = newObj(i).m_Time;
        k = k + 1; 
        % s end Time
        if char(newObj(i+1).m_Code1) == 's'
            endTimes(j) = newObj(i+1).m_Time;
            j = j + 1;
        % L end Time & start Time
        elseif char(newObj(i+1).m_Code1) == 'L'
            endTimes(j) = newObj(i+1).m_Time;
            j = j + 1;
            startTimes(k) = newObj(i+1).m_Time;
            k = k + 1;
            if char(newObj(i+2).m_Code1) == 's' || char(newObj(i+2).m_Code1) == 'L'
                endTimes(j) = newObj(i + 2).m_Time;
                j = j + 1;
            end
        end
    end
end

%% Take the Experiment start time listed in the excel file, and remove incorrect segments

% remove segments before start time
expmt_start_time = xlsread(fullfile(pathname,[filenameroot '.xlsx']), 1, 'G2' );
endTimes(startTimes < (expmt_start_time *100000)) = [];
startTimes(startTimes < (expmt_start_time *100000)) = [];

% remove segments after experiment is over
[~, segment_Names, ~] = xlsread(fullfile(pathname,[filenameroot '.xlsx']), 1, 'A2:A500' );
if length(segment_Names) < length(endTimes)
    endTime(length(segment_Names)+1:end) = [];
end

%% Convert to seconds
endTimes = endTimes' /     100000;
startTimes = startTimes' / 100000;

%% place start and end times into the excel file
tFilename = [filenameroot '.xlsx'];
xlswrite(tFilename, startTimes, 'Sheet1', 'D2')
xlswrite(tFilename, endTimes, 'Sheet1', 'E2')
