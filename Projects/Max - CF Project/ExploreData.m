%% Open Excel File
clear;clc;close all

[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_Backup.xlsx')

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';

allFiles = dir([expmtDataFolder, '\**\*']);

% csFiles2 = allFiles;
% csFiles2(~contains({csFiles2.name}, {'sortedCS'})) = [];
%allFiles(~contains({allFiles.name}, {'aligned.mat'})) = [];

superGoodCSIso = {};

%% loop through each one
for j = 1:height(dataTable)
    %% Skip non-related recordings
    
    % Bad Recording Files
%     if ~isnan(dataTable.maxRemoved(j))
%         continue
%     end
    
    % Only Aligned Files
    if ~contains(dataTable.alignedMat(j), 'aligned') 
        continue
    end
    
%     if contains(dataTable.behaviorMat(j), 'behavior') 
%         continue
%     end
    
    % Expmt Condition Filtering
%     if ~contains(dataTable.sineStep(j), 'sine')
%         continue
%     end
%     if dataTable.freq(j) ~= .5
%         continue
%     end
%     if ~contains(dataTable.learningType(j), 'OKR')
%         continue
%     end

    % Other Condition
%     if ~isnan(dataTable.maxSortedCS(j))
%         continue
%     end
%     if ~dataTable.maxSortedCS(j)
%         continue
%     end
%     if isnan(dataTable.goodCSIsolation(j))
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
    if ~isempty(behaviorEphysAligned(9).data)
        disp('empty!')
    end
    
    disp(j)

    %% Add Sorted CS to behavior File
%     try
%         alignedFile = dataTable.alignedMat{j};
%         rootName = alignedFile(1:11);
%         csFileIndx = contains({csFiles2.name}, {rootName});
%         if ~any(csFileIndx)
%             continue
%         end
%         % Load sortedCS File
%         sortedCSFileInfo = csFiles2(find(csFileIndx));
%         load(fullfile(sortedCSFileInfo(1).folder, sortedCSFileInfo(1).name));
%         
%         % Load Aligned File
%         fileInfo = allFiles(contains({allFiles.name}, {alignedFile}));
%         load(fullfile(fileInfo(1).folder, fileInfo(1).name));
%         
%         figure(1); clf
%         timeVec = dattime(behaviorEphysAligned(1,10));
%         plot(timeVec, behaviorEphysAligned(10).data)
%         title(dataTable.name(j))
%  
% %         list = {'Use', 'Dont', 'Other'};
% %         [indx,tf] = listdlg('ListString',list);
% %         if indx == 1 
% %             superGoodCSIso(end+1) = dataTable.ephysMat(j);
% %         end
% 
%         vline(Channel01(:,1)+behaviorEphysAligned(10).tstart)
%         behaviorEphysAligned(9).data = Channel01(:,1)+behaviorEphysAligned(10).tstart;
%         save(fullfile(fileInfo(1).folder, fileInfo(1).name), 'behaviorEphysAligned')
% 
%         if ~isempty(behaviorEphysAligned(1,9).data)
%             dataTable.sortedCS(j) = 1;
%         else
%             dataTable.sortedCS(j) = 0;
%         end
%     
%     
%     catch
%         disp('Failed!')
%         continue
%     end
    
    %% Visualize 
%     try
%         figure(2);clf
%         disp(dataTable.maxAlignVal(j))
%         timeVec = dattime(behaviorEphysAligned(10));
%         plot(timeVec(1:end/2), behaviorEphysAligned(10).data(1:end/2))
%         vline(behaviorEphysAligned(8).data(100:150))
%         xlim([behaviorEphysAligned(8).data(100), behaviorEphysAligned(8).data(150)]) 
%         drawnow
%     catch
%         disp('Plotting Failed!')
%         continue
%     end
%     list = {'Good', 'Bad', 'Other'};
%     [indx,tf] = listdlg('ListString',list);
%     if indx-1 == 1 
%         dataTable.maxRemoved(j) = 1;
%     elseif indx-1 == 2
%         disp('apple')
%     end
    
    %% Get Manual Input
%     try
%         ephysData = behaviorEphysAligned(10).data;
%         figure(11); clf
%         ssLocs = zeros(length(ephysData),1);
%         behaviorEphysAligned(8).data(behaviorEphysAligned(8).data < 0) = [];
%         
%         for k = 1:length(behaviorEphysAligned(8).data) 
%             ssLocs(round(behaviorEphysAligned(8).data(k)*behaviorEphysAligned(10).samplerate)) = 1;
%         end
%         [c,lags] = xcorr(ephysData,ssLocs);
%         plot(lags/50000, c);
%         xCorrShiftVal = lags(find(c == max(c)))/behaviorEphysAligned(10).samplerate;    
%         disp(['     ', num2str(xCorrShiftVal)]);
%         [behaviorDat, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorEphysAligned(1:end-1), behaviorEphysAligned(10).data, 1);
%         
%         dataTable.xcorrAlignVal(j) = xCorrShiftVal;
%     catch
%         disp('xcorr Failed!')
%     end
    
end


%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx')
