%% this script is used to takes a segments, or chunks of data, and organize
% them in a useful way.
%
% max.gagnon11@gmail.com 5/18

%% Import data
clear
data = 1:1000;

%% setup 

% Define start time
startT = 10;

% CHOOSE ONE: total amount of segments, or end time of the segments
endT = 80;
%segNum = 4;

% Define length of each segment, and the gap between them
segLen = 12;
gapLen = 2;

% if segNum is given, find endT
if ~exist('endT', 'var')
    segSum = segLen * segNum;
    gapSum = gapLen * (segNum -1);
    endT = startT + segSum + gapSum;
end

startTList = startT:segLen+gapLen:endT;

% if endT is given, find the segNum
if ~exist('segNum', 'var')
    segNum = length(startTList);
end

%% create matrix with rows for each segment

% pre-Allocate matrix
segMatrix = zeros(segNum, segLen);

row = 1;

for i = startTList
  
    if row == segNum
         % on the final segment, fill in the rest of the values with NaN, as the
        % final segment is likely to be only a partial cycle.
        finalSeg = data( i : endT);
        finalSeg = [finalSeg NaN(1, segLen - length(finalSeg))];
        segMatrix(row,:) = finalSeg;
    else
        % add to matrix normally
        segMatrix(row,:) = data(i:i+segLen-1);
    end
    
    row = row + 1;
end
