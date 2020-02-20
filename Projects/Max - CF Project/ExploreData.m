%% Open Excel File
clear;clc;

[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_D.xlsx')
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_Backup.xlsx')

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';

allFiles = dir([expmtDataFolder, '\**\*']);

% csFiles2 = allFiles;
% csFiles2(~contains({csFiles2.name}, {'sortedCS'})) = [];
%allFiles(~contains({allFiles.name}, {'aligned.mat'})) = [];

superGoodCSIso = {};
d = 1;
%% loop through each one
for j = 1:height(dataTable)
    %% Skip non-related recordings
    
    % SKIP BAD RECORDINGS
    if dataTable.maxRemoved(j)
        continue
    end
    
    % ALIGNED FILES
    if ~contains(dataTable.alignedMat(j), 'aligned') 
        continue
    end
%     if contains(dataTable.behaviorMat(j), 'behavior') 
%         continue
%     end


    % SINE/STEP
    if ~contains(dataTable.sineStep(j), 'step')
        continue
    end
    
    
    % FREQUENCY/STEP TYPE
%     if dataTable.freq(j) ~= .5
%         continue
%     end
    if contains(dataTable.stepType(j), '?')
        continue
    end

    
    % LEARNING TYPE
%     if contains(dataTable.learningType(j), '?')
%         continue
%     end
%     if contains(dataTable.learningType(j), 'Shift')
%         continue
%     end
    
    
    % OTHER
%     if ~isnan(dataTable.maxSortedCS(j))
%         continue
%     end
    if ~dataTable.maxSortedCS(j)
        continue
    end
%     if ~dataTable.goodCSIsolation(j)
%         continue
%     end
    
%     if dataTable.sortedCS(j)
%         continue
%     end

%     if dataTable.goodCSIsolation(j) == 0
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
    
    disp(j)
       
    %% ADD SORTED CS TO BEHAVIOR FILE
    csFileName = fullfile(fileInfo(1).folder, fileInfo(1).name);
    csFileName = strrep(csFileName, 'aligned', 'sortedCS');
    try 
        load(csFileName);
    catch
        disp('apple')
    end
    if ~isempty(behaviorEphysAligned(9).data)
        continue
    end
    
    figure(1); clf
    timeVec = dattime(behaviorEphysAligned(1,10));
    plot(timeVec, behaviorEphysAligned(10).data)
    title(dataTable.name(j))
    vline(Channel01(:,1)+behaviorEphysAligned(10).tstart)
    xlim([10 20])
    
    list = {'good', 'bad', 'Other'};
    [indx,tf] = listdlg('ListString',list);
    if indx == 1 
        behaviorEphysAligned(9).data = Channel01(:,1)+behaviorEphysAligned(10).tstart;
        save(fullfile(fileInfo(1).folder, fileInfo(1).name), 'behaviorEphysAligned')
    elseif indx == 2
        dataTable.sortedCS(j) = 0;
    elseif indx == 3
        disp('apples')
    end
    
    %% MANUAL: Is this a good CS?
%     try
%         figure(1);clf
%         Summary = tight_subplot(1,1,[.03 .03],[.03 .03],[.03 .03]);
%         axes(Summary(1))
%         timeVec = dattime(behaviorEphysAligned(10));
%         plot(timeVec, behaviorEphysAligned(10).data);
% 
%         list = {'Good', 'Bad', 'Other'};
%         [indx,tf] = listdlg('ListString',list);
%         switch indx
%             case 1
%                 dataTable.goodCSIsolation(j) = 1;
%             case 2
%                 dataTable.goodCSIsolation(j) = 0;
%         end
% 
%     catch
%     end
   
    %% MANUAL: Sine/Step
%     try
%         figure(1);clf
%         timeVec = dattime(behaviorEphysAligned(5));
%         plot(timeVec, behaviorEphysAligned(7).data, 'b'); hold on
%         plot(timeVec, behaviorEphysAligned(5).data, 'r'); 
%         legend('Target Vel', 'Head Vel')
%          
%         xlim([10 20])
%         ylim([-100 100])
% 
%         list = {'step', 'sine', 'Other'};
%         [indx,tf] = listdlg('ListString',list);
%         switch indx
%             case 1
%                 dataTable.sineStep{j} = 'step';
%             case 2
%                 dataTable.sineStep{j} = 'sine';
%             case 3
%                 dataTable.sineStep{j} = '?';
%         end
%         
%     catch
%     end

    %% MANUAL: Stim Type (x2, x0, OKR, VORD, Shift, Other)
%     try
%         figure(1);clf
%         timeVec = dattime(behaviorEphysAligned(5));
%         plot(timeVec, behaviorEphysAligned(7).data, 'b'); hold on
%         plot(timeVec, behaviorEphysAligned(5).data, 'r'); 
%         legend('Target Vel', 'Head Vel')
%          
%         xlim([10 20])
%         ylim([-100 100])
% 
%         list = {'x2', 'x0', 'OKR', 'VORD', 'Shift', 'Other'};
%         [indx,tf] = listdlg('ListString',list);
%         switch indx
%             case 1
%                 dataTable.learningType{j} = 'x2';
%             case 2
%                 dataTable.learningType{j} = 'x0';
%             case 3
%                 dataTable.learningType{j} = 'OKR';
%             case 4
%                 dataTable.learningType{j} = 'VORD';
%             case 5
%                 dataTable.learningType{j} = 'Shift';
%             case 6
%                 dataTable.learningType{j} = 'Unknown';
%         end
%         
%     catch
%     end
    
    
end


%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx')
