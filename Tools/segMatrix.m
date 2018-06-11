function segmentMatrix = segMatrix(params)%% this script is used to takes a segments, or chunks of data, and organize
% them in a useful way.
%
% max.gagnon11@gmail.com 5/18

%% Import & organize data

% Choose Which mouse to load from
if params.mouse == 1
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\2018- 05-20180502T212015Z-001\2018- 05\050118_1\050118_1_100Hz.mat')
elseif params.mouse == 2
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\2018- 05-20180502T212015Z-001\2018- 05\050118_2\050118_2_100Hz.mat')
else
    warning('Wrong Mouse number. Please Enter 1 or 2')
end

switch params.channel
    case 'Control'
        data = sig_405_RS;
    case 'GCaMP'
        data = sig_472_RS;
    case 'Difference'
        data = sig_472_RS - sig_405_RS;
end

switch params.filter
    case 'Filtered'
        data = smooth(data, 10);
    case 'Unfiltered'
        
    otherwise
        warning('Typo!')
        params.filter
end


%% setup 

% Define start time
offset = params.segLen / 4;
startT = camtime(params.segment(1)) * 100 + offset;

% CHOOSE ONE: total amount of segments, or end time of the segments
endT = camtime(params.segment(2)) * 100;
%segNum = 4;

% Define length of each segment, and the gap between them
segLen = params.segLen;
gapLen = 0;

% if segNum is given, find endT
if ~exist('endT', 'var')
    segSum = segLen * segNum;
    gapSum = gapLen * (segNum -1);
    endT = startT + segSum + gapSum;
end

startTList = startT:segLen+gapLen:endT;
startTList = floor(startTList);

% if endT is given, find the segNum
if ~exist('segNum', 'var')
    segNum = length(startTList);
end

%% create matrix with rows for each segment

% pre-Allocate matrix
segmentMatrix = zeros(segNum, segLen);

row = 1;

for i = startTList
  
    if row == segNum
         % on the final segment, fill in the rest of the values with NaN, as the
        % final segment is likely to be only a partial cycle.
        finalSeg = data( i : endT);
        finalSeg = [finalSeg' NaN(1, segLen - length(finalSeg))];
        segmentMatrix(row,:) = finalSeg;
    else
        % add to matrix normally
        segmentMatrix(row,:) = data(i:i+segLen-1)';
    end
    
    row = row + 1;
end





