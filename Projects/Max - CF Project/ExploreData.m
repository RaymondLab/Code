%% Open Excel File
clear;clc;close all

[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
%dataTable.learningType = cell(height(dataTable),1);

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

allFiles = dir([expmtDataFolder, '\**\*']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];

%% loop through each one
for j = 1:height(dataTable)
    disp(j)
    if ~contains(dataTable.alignedMat(j), 'aligned')
        continue
    end
    if dataTable.freq(j) ~= .5
        continue
    end
    if ~isempty(dataTable.learningType{j})
        continue
    end
    %% Prep
    alignedFile = dataTable.alignedMat{j};
    fileInfo = allFiles(contains({allFiles.name}, {alignedFile}));
    load(fullfile(fileInfo.folder, fileInfo.name));
    
    % ephys fig
    figure(1);clf
    
    timeVec = dattime(behaviorEphysAligned(1,10));
    plot(timeVec, behaviorEphysAligned(1, 10).data);
    xlim([0, timeVec(end)])
    title(alignedFile)
    
    % behavior Fig
    figure(2);clf
    
    timeVec = dattime(behaviorEphysAligned(1,7));
    plot(timeVec, behaviorEphysAligned(1,7).data, 'r'); hold on
    plot(timeVec, behaviorEphysAligned(1,5).data, 'b');
    xlim([0 8])
    ylim([-80 80])
    title(alignedFile)
    legend('T Vel', 'H Vel')
    drawnow
    
    if isempty(dataTable.learningType{j})
        try
        list = {'x2', 'x0', 'OKR', 'VORD', 'Unknown'};
        [indx,tf] = listdlg('ListString',list);
        dataTable.learningType{j} = list{indx};
        catch
        end
    end
    
end


%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx')
