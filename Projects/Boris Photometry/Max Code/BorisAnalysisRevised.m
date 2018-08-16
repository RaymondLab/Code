
%% Set Up
clear;clc;close all

% read table and set up parameters
table = readtable('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\SegInfo.xlsx');
struct = table2struct(table);
direction = {'L', 'R'};
lightGreen = [117 187 49] ./ 255;

% 0: no filtering, 1: filtering
filter = 0;


%% Run Segments
for iii = 1:length(struct)
    %% Import Data
    switch struct(iii).recNum
        case 1
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz.mat')
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz405.mat')
            Chan_405_Control = debleach;
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_1\MATLAB Variables\MATLAB Variables_100Hz472.mat')
            Chan_472_GCaMP = debleach;
        case 2
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz.mat')
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz405.mat')
            Chan_405_Control = debleach;
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M1\Recording_2\MATLAB Variables\MATLAB Variables_100Hz472.mat')
            Chan_472_GCaMP = debleach;
        case 3
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz.mat')
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz405.mat')
            Chan_405_Control = debleach;
            load('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1\MATLAB Variables\MATLAB Variables_100Hz472.mat')
            Chan_472_GCaMP = debleach;
    end
    
    %% Create Difference Channel
    Chan_Diff = Chan_472_GCaMP - Chan_405_Control;
    
    %% Filtering
    if filter
        Chan_405_Control = smooth(Chan_405_Control, 10);
        Chan_472_GCaMP = smooth(Chan_472_GCaMP, 10);
        Chan_Diff = smooth(Chan_Diff, 10);
    end
    
    %% Matrix of Segments (Normal)
    if ~(struct(iii).special)
        
        offset = struct(iii).segLen / 4;
        startT = camtime(struct(iii).start) * 100 + offset;
        endT = camtime(struct(iii).stop) * 100;

        segMat_405_Control  = vec2mat(Chan_405_Control(startT:endT),struct(iii).segLen, NaN);
        segMat_472_GCaMP    = vec2mat(Chan_472_GCaMP(startT:endT),struct(iii).segLen, NaN);
        segMat_Diff         = vec2mat(Chan_Diff(startT:endT),struct(iii).segLen, NaN);
        
    %% Matrix of Segments (Special) TODO
    else
        disp('APPLES')
        continue
%         % this vector contains pause lengths
%         m2r1s1 = [0 0 0 4 1 1 1 1 1 1 1 1 4 2  2 2 2 2 2 2  2  2  2 2];
%         % add time for movement
%         m2r1s1 = m2r1s1 + 2;
%         % this vector contains pause lengths
%         m2r1s2 = [3 5 5 5 6 5 4 4 3 4 3 3 4 15 7 9 6 6 7 12 10 14 7 9 17];
%         % add time for movement
%         m2r1s2 = m2r1s2 + 2;
%         
%         segment = m2r1s2;
%         
%         % pre-alocate
%         %R_matrix = NaN(length(segment), (2+max(segment))*400);
%         %L_matrix = NaN(length(segment), (2+max(segment))*400);
%         segmentMatrix = NaN(length(segment), (2+max(segment))*400);
%         startT = camtime(params.segment(1)) * 100;
%         %endT = camtime(params.segment(2))  * 100;
%         
%         for i = 1:length(segment)
%             
%             segmentMatrix(i,1:segment(i)*400) = data(startT:startT+(segment(i)*400)-1);
%             
%             % First movement is always rightward (from MOUSE PERSPECTIVE!!)
%             %     if mod(i, 2) == 1
%             %         R_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
%             %     else
%             %         L_matrix(i,1:segment(i)*400) = data(startTime:startTime+(segment(i)*400)-1);
%             %     end
%             
%             startT = startT + (segment(i)+2)*400;
%         end
        % if params.direction == 'R'
        %     segMat_405_Control = segMat_405_Control(1:2:end, :);
        %     segMat_472_GCaMP = segMat_472_GCaMP(1:2:end, :);
        %     segMat_Diff = segMat_Diff(1:2:end, :);
        % else 
        %     segMat_405_Control = segMat_405_Control(2:2:end, :);
        %     segMat_472_GCaMP = segMat_472_GCaMP(2:2:end, :);
        %     segMat_Diff = segMat_Diff(2:2:end, :);
        % end

    end  
    
    %% Plot Individual Traces
    % Boris_IndividualTraces
    
    %% Plot Variation
    % Boris_Variation
    
    %% Plot Window Measures
    % Boris_windowMeasures
    
    
    
    %% Spike Analysis
    disp(iii)
    Boris_spikeAnalysis(segMat_405_Control, struct(iii), direction);
    title('Control')
    Boris_spikeAnalysis(segMat_472_GCaMP, struct(iii), direction);
    title('GCaMP')
    Boris_spikeAnalysis(segMat_Diff, struct(iii), direction);
    title(['Difference ' num2str(struct(iii).mouse) '_R' num2str(struct(iii).recNum) '_S' num2str(struct(iii).segNum)])
    
    
end
%% Let user know it's done
    disp('DONE! :) ')
