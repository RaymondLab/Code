% This script tries to find start and stop times of each segment in an
% experiment
%
% Maxwell Gagnon May-2018

%% Setup
%cd('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Delta 07 Amin Data\Gain Up\1 hz gain up\WT\Exp-Delta07-Ch01-04-11102017');


pathname = cd;
activateCEDS64;
[~, filenameroot] = fileparts(pathname);
A = CEDS64Open(fullfile(pathname,[filenameroot '.smr']));
[iRead, vMObj] = CEDS64ReadMarkers(A, 31, 1000, 0);

%% extract only S, s, and L. The other Markers don't matter
g = 1;
for i = 1:length(vMObj) 
    if char(vMObj(i).m_Code1) == 'S' || char(vMObj(i).m_Code1) == 's' || char(vMObj(i).m_Code1) == 'L'
        newObj(g) = vMObj(i);
        g = g + 1;
    end
end

%% use S, s, and L to find the start and end times of the experiment
% automatically.
i = 1;
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

%% eliminate any non-experiment related segments. THIS COULD BE IMPROVED.
len = floor((endTimes - startTimes) / 100000);
i = 1;
for i = 1:length(len)
    if len(i) < 30
        endTimes(i) = [];
        startTimes(i) = [];
    end
end

%% Convert to second and replace in the excel file
endTimes = endTimes' /     100000;
startTimes = startTimes' / 100000;


tFilename = [filenameroot '.xlsx'];
xlswrite(tFilename, startTimes, 'Sheet1', 'D2')
xlswrite(tFilename, endTimes, 'Sheet1', 'E2')
