%% Set up
clear;clc;
A = chanData;

% open Excel File
A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
%A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max (Akira).xlsx';
A.expmt_table = readtable(A.excelFile);

A.expmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
%A.expmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';

%bFiles = dir([ExpmtDataFolder '\**\*.0*']);
A.bFiles = dir([A.expmtDataFolder '\**\*']);
A.whoseData = 'Akira';
A.whoseData = 'Jennifer';

%figure(1); clf
%ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);

%% Filters
% Remove directories
A.bFiles([A.bFiles.isdir]) = [];
% Remove zip files
A.bFiles(contains({A.bFiles.name}, {'.zip'})) = [];

%% Match the corresponding ephys folders with their motor folders
for j = 1:length(A.bFiles)
    
    disp([A.bFiles(j).name, '(', num2str(j), '/', num2str(length(A.bFiles)), ')'])
    % If the file is an ephys or oddly named file, skip it - Jennifer
    if length(A.bFiles(j).name) ~= 11
        continue
    end
    
    %if ~contains({A.bFiles(j).name}, {'unit'})
    if ~contains({A.bFiles(j).name}, {'da'})
        disp('     -Not Behavior File')
        continue
    end
        
    %% Find Behavior
    [A, bPath, expmtRow] = A.findBehavior(A.bFiles(j).name, A.bFiles(j).folder);
    
    %% Find Ephys
    [A, ephys_exists, ePath] = A.findEphys(A.bFiles(j).name, expmtRow);
    
    if ~ephys_exists
        continue
    end
    
    %% Open File
    try
        [beh, shiftAmt, shiftConfidence] = opensingleMAXEDIT(bPath, ephys_exists, ePath);
    catch
        disp('     -Failed to Open. Skipped')
        continue
    end
    
    %% plotAllChans
    %A.plotAllChans(beh);
    
    %% save Ephys Shift Val
    A = A.findEphysAllignment(beh, expmtRow, shiftConfidence);
    %A.plot2(beh);
    
    % Find the Stim Type
    %A = A.findStimType(expmtRow);
    %[A, peakFreqEstimate] = A.findExpmtFreq(beh, expmtRow);
    %A.plotPowerSpec(beh);
    %A = A.findAmpPhase(beh, peakFreqEstimate, expmtRow);

    fclose('all');
end

writetable(A.expmt_table, A.excelFile);