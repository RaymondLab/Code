%% Open Excel File
clear;clc;close all

[dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
%dataTable.learningType = cell(height(dataTable),1);

expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

allFiles = dir([expmtDataFolder, '\**\*']);

csFiles = allFiles;
csFiles(~contains({csFiles.name}, {'sortedCS'})) = [];
allFiles(~contains({allFiles.name}, {'aligned'})) = [];

%% loop through each one
for j = 2700:height(dataTable)
    disp(j)
        
    %% Skip non-related recordings
    if dataTable.UnableToAlign(j)
        continue
    end
    if ~contains(dataTable.ephysMat(j), 'ephys') 
        continue
    end
%     if dataTable.alignVal(j) > 0 %&& dataTable.alignVal(j) > .004.
%         continue
%     end
    if ~contains(dataTable.sineStep(j), 'sine')
        continue
    end
%     if dataTable.freq(j) ~= .5
%         continue
%     end
%     if ~contains(dataTable.learningType(j), 'x2')
%         continue
%     end
%     if ~isnan(dataTable.goodCSIsolation(j))
%         continue
%     end

    %% Open File
    try 
        alignedFile = dataTable.alignedMat{j};
        fileInfo = allFiles(contains({allFiles.name}, {alignedFile}));
        load(fullfile(fileInfo(1).folder, fileInfo(1).name));
    catch
        disp('Opening Failed!')
        continue
    end
    
    %% Visualize 
    try
        figure(2);clf
        timeVec = dattime(behaviorEphysAligned(10));
        plot(timeVec, behaviorEphysAligned(10).data)
        vline(behaviorEphysAligned(8).data(50:53))   
        xlim([behaviorEphysAligned(8).data(50), behaviorEphysAligned(8).data(53)])

    catch
        disp('Plotting Failed!')
        continue
    end
    
    %% Get Manual Input
    
    try
        list = {'Good', 'Bad'};
        [indx,tf] = listdlg('ListString',list);
        if indx-1
            % Run re alignment
            [behaviorDat, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorEphysAligned(1:end-1), behaviorEphysAligned(10).data, 1);
            list = {'Good', 'Bad'};
            [indx,tf] = listdlg('ListString',list);
            if indx-1
                
            end
        end
    catch
    end
       
end


%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx')
