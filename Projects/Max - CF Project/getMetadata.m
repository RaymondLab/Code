%% Set up
% clear;clc;
% A = chanData;
% 
% % open Excel File
% A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
% %A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max (Akira).xlsx';
% A.expmt_table = readtable(A.excelFile);
% 
% A.expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';
% %A.expmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';
% 
% A.bFiles = dir([A.expmtDataFolder '\**\*']);
% A.bFiles(~contains({A.bFiles.name}, {'behavior'})) = [];
% 
% %A.whoseData = 'Akira';
% A.whoseData = 'Jennifer';

%% Load data instead
clear;clc;close all
load C:\Users\maxga\Desktop\RecList.mat
plotOn = 1;

%A.bFiles(~contains({A.bFiles.name}, {'behavior'})) = [];
A.bFiles([A.bFiles.isdir]) = [];
A.bFiles(~contains({A.bFiles.name}, {'.mat'})) = [];
A.bFiles(contains({A.bFiles.name}, {'da0301'})) = [];
A.bFiles(contains({A.bFiles.name}, {'da02'})) = [];

%% Main Loop
for j = 1:length(A.bFiles)
    
    % Skip Ephys files
    if ~contains({A.bFiles(j).name}, {'behavior.mat'})
        continue
    end
    
    if exist(fullfile(A.bFiles(j).folder, strrep(A.bFiles(j).name, 'behavior', 'aligned')), 'file')
        continue
    end
    

    
    
    % Keep track of where you are
    disp([A.bFiles(j).name, '(', num2str(j), '/', num2str(length(A.bFiles)), ')'])
    
    % Open Behavior
    filePath = fullfile(A.bFiles(j).folder, A.bFiles(j).name);
    load(filePath)
    if length(datchandata(behaviorData,'ss')) < 200
        disp('     No ss Timestamps')
        continue
    end
    
    % Open Ephys
    ephysName = strrep(A.bFiles(j).name, 'behavior', 'ephys');
    ephysEntry = A.bFiles(contains({A.bFiles.name}, ephysName));
    
    if ~isempty(ephysEntry)
        ephysPath = fullfile(ephysEntry.folder, ephysEntry.name);
        try
            load(ephysPath)
        catch
            disp('Ephys Error')
        end
        
        % Align Traces
        tic
        [behaviorEphysAligned, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorData, ephysData, plotOn);
        toc
        disp(shiftAmt)
        newName = strrep(ephysName, 'ephys', 'aligned');
        save(fullfile(A.bFiles(j).folder, newName), 'behaviorEphysAligned');
    else
        disp('     No Ephys File')
    end
    
    % Plot Traces
    
end
