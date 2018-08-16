function [segMat_405_Control, segMat_472_GCaMP, segMat_Diff]  = segMatrix(params)

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

%% Organize data - Normal
Chan_Diff = Chan_472_GCaMP - Chan_405_Control;

switch params.filter
    case 'Filtered'
        Chan_405_Control = smooth(Chan_405_Control, 10);
        Chan_472_GCaMP = smooth(Chan_472_GCaMP, 10);
        Chan_Diff = smooth(Chan_Diff, 10);
    case 'Unfiltered'
        
    otherwise
        warning('Typo!')
        params.filter
end

offset = params.segLen / 4;
startT = camtime(params.segment(1)) * 100 + offset;
endT = camtime(params.segment(2))  * 100;
% make control chan matrix
segMat_405_Control = vec2mat(Chan_405_Control(startT:endT),params.segLen);
segMat_405_Control(end,:) = [];

% make GCaMP chan matrix
segMat_472_GCaMP = vec2mat(Chan_472_GCaMP(startT:endT),params.segLen);
segMat_472_GCaMP(end,:) = [];

% make difference matrix
segMat_Diff = vec2mat(Chan_Diff(startT:endT),params.segLen);
segMat_Diff(end,:) = [];



%% setup for CUstom Process (Comment this section out be default)
% 
% % this vector contains pause lengths
% m2r1s1 = [0 0 0 4 1 1 1 1 1 1 1 1 4 2  2 2 2 2 2 2  2  2  2 2];
% % add time for movement
% m2r1s1 = m2r1s1 + 2;
% % this vector contains pause lengths
% m2r1s2 = [3 5 5 5 6 5 4 4 3 4 3 3 4 15 7 9 6 6 7 12 10 14 7 9 17];
% % add time for movement
% m2r1s2 = m2r1s2 + 2;
% 
% segment = m2r1s2;
% 
% % pre-alocate
% %R_matrix = NaN(length(segment), (2+max(segment))*400);
% %L_matrix = NaN(length(segment), (2+max(segment))*400);
% segmentMatrix = NaN(length(segment), (2+max(segment))*400);
% startT = camtime(params.segment(1)) * 100;
% %endT = camtime(params.segment(2))  * 100;
% 
% for i = 1:length(segment)  
% 
%     segmentMatrix(i,1:segment(i)*400) = data(startT:startT+(segment(i)*400)-1);
%     
%     % First movement is always rightward (from MOUSE PERSPECTIVE!!)
% %     if mod(i, 2) == 1
% %         R_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
% %     else
% %         L_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
% %     end
% 
%     startT = startT + (segment(i)+2)*400;
% end









