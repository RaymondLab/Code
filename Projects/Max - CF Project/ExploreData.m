%% Open Excel File
clear;clc;close all

[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
%dataTable.learningType = cell(height(dataTable),1);

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

allFiles = dir([expmtDataFolder, '\**\*']);
csFiles = allFiles;
csFiles(~contains({csFiles.name}, {'sortedCS'})) = [];
allFiles(~contains({allFiles.name}, {'aligned'})) = [];

%% loop through each one
for j = 1:height(dataTable)
    disp(j)
        
    %% Skip non-related recordings
    if isnan(dataTable.maxSortedCS(j))
        continue
    end
%     if ~contains(dataTable.alignedMat(j), 'aligned') 
%         continue
%     end
%     if ~contains(dataTable.sineStep(j), 'sine')
%         continue
%     end
%     if dataTable.freq(j) ~= .5
%         continue
%     end
%     if ~contains(dataTable.learningType(j), 'x2')
%         continue
%     end
%     if ~isnan(dataTable.goodCSIsolation(j))
%         continue
%     end

    %% Mark if sorted CS is pesent
    try
        alignedFile = dataTable.alignedMat{j};
        fileInfo = allFiles(contains({allFiles.name}, {alignedFile}));
        load(fullfile(fileInfo(1).folder, fileInfo(1).name));
        
        figure()
        timeVec = dattime(behaviorEphysAligned(1,10));
        plot(timeVec, behaviorEphysAligned(10).data)
        vline(Channel01(:,1)+behaviorEphysAligned(10).tstart)
        behaviorEphysAligned(9).data = Channel01(:,1)+behaviorEphysAligned(10).tstart;
        save(fullfile(fileInfo(1).folder, fileInfo(1).name), 'behaviorEphysAligned')
        
    if ~isempty(behaviorEphysAligned(1,9).data)
        dataTable.sortedCS(j) = 1;
    else
        dataTable.sortedCS(j) = 0;
    end
    catch
        disp('Failed!')
        continue
    end
        
    %% Plot important things
    % ephys fig
    figure(1);clf
    
    timeVec = dattime(behaviorEphysAligned(1,10));
    plot(timeVec, behaviorEphysAligned(1, 10).data);
    xlim([0, timeVec(end)])
    title(alignedFile)
    
    % behavior Fig
%     figure(2);clf
%     
%     timeVec = dattime(behaviorEphysAligned(1,7));
%     plot(timeVec, behaviorEphysAligned(1,7).data, 'r'); hold on
%     plot(timeVec, behaviorEphysAligned(1,5).data, 'b');
%     xlim([0 8])
%     ylim([-80 80])
%     title(alignedFile)
%     legend('T Vel', 'H Vel')
    drawnow
    
    %% Get Manual Input
    if isnan(dataTable.goodCSIsolation(j))
         try
            list = {'n', 'y'};
            [indx,tf] = listdlg('ListString',list);
            dataTable.goodCSIsolation(j) = indx-1;
        catch
        end
    end
end


%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx')
