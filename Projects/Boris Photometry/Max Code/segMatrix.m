function segmentMatrix = segMatrix(params)%% this script is used to takes a segments, or chunks of data, and organize
% them in a useful way.
%
% max.gagnon11@gmail.com 5/18

%% Import & organize data

% Choose Which mouse to load from
if params.mouse == 1
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz.mat')
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz405.mat')
    Chan_405_Control = debleach;
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz472.mat')
    Chan_472_GCaMP = debleach;
elseif params.mouse == 2    
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz.mat')
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz405.mat')
    Chan_405_Control = debleach;
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz472.mat')
    Chan_472_GCaMP = debleach;
elseif params.mouse == 3
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz.mat')
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz405.mat')
    Chan_405_Control = debleach;
    load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz472.mat')
    Chan_472_GCaMP = debleach;
else
    warning('Wrong Mouse number. Please Enter 1 or 2')
end

switch params.channel
    case 'Control'
        data = Chan_405_Control;
        %data = sig_405_RS;
    case 'GCaMP'
        data = Chan_472_GCaMP;
       % data = sig_472_RS; 
    case 'Difference'
        data = Chan_472_GCaMP - Chan_405_Control;
        %data = sig_472_RS - sig_405_RS;
end

switch params.filter
    case 'Filtered'
        data = smooth(data, 10);
    case 'Unfiltered'
        
    otherwise
        warning('Typo!')
        params.filter
end


%% setup for CUstom Process (Comment this section out be default)

% this vector contains pause lengths
m2r1s1 = [0 0 0 4 1 1 1 1 1 1 1 1 4 2  2 2 2 2 2 2  2  2  2 2];
% add time for movement
m2r1s1 = m2r1s1 + 2;
% this vector contains pause lengths
m2r1s2 = [3 5 5 5 6 5 4 4 3 4 3 3 4 15 7 9 6 6 7 12 10 14 7 9 17];
% add time for movement
m2r1s2 = m2r1s2 + 2;

segment = m2r1s2;

% pre-alocate
%R_matrix = NaN(length(segment), (2+max(segment))*400);
%L_matrix = NaN(length(segment), (2+max(segment))*400);
segmentMatrix = NaN(length(segment), (2+max(segment))*400);
startT = camtime(params.segment(1)) * 100;
%endT = camtime(params.segment(2))  * 100;

for i = 1:length(segment)  

    segmentMatrix(i,1:segment(i)*400) = data(startT:startT+(segment(i)*400)-1);
    
    % First movement is always rightward (from MOUSE PERSPECTIVE!!)
%     if mod(i, 2) == 1
%         R_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
%     else
%         L_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
%     end

    startT = startT + (segment(i)+2)*400;
end

% %% Normal Process
% % Define start time
% offset = params.segLen / 4;
% startT = camtime(params.segment(1)) * 100 + offset;
% 
% % CHOOSE ONE: total amount of segments, or end time of the segments
% endT = camtime(params.segment(2)) * 100;
% %segNum = 4;
% 
% % Define length of each segment, and the gap between them
% segLen = params.segLen;
% gapLen = 0;
% 
% % if segNum is given, find endT
% if ~exist('endT', 'var')
%     segSum = segLen * segNum;
%     gapSum = gapLen * (segNum -1);
%     endT = startT + segSum + gapSum;
% end
% 
% startTList = startT:segLen+gapLen:endT;
% startTList = floor(startTList);
% 
% % if endT is given, find the segNum
% if ~exist('segNum', 'var')
%     segNum = length(startTList);
% end
% 
% %% create matrix with rows for each segment
% 
% % pre-Allocate matrix
% segmentMatrix = zeros(segNum, segLen);
% 
% row = 1;
% 
% for i = startTList
%   
%     if row == segNum
%          % on the final segment, fill in the rest of the values with NaN, as the
%         % final segment is likely to be only a partial cycle.
%         finalSeg = data( i : endT);
%         finalSeg = [finalSeg' NaN(1, segLen - length(finalSeg))];
%         segmentMatrix(row,:) = finalSeg;
%     else
%         % add to matrix normally
%         segmentMatrix(row,:) = data(i:i+segLen-1)';
%     end
%     
%     row = row + 1;
% end





