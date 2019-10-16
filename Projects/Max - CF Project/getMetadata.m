%% Set up
clear;clc; close all
A = chanData;

% open Excel File
A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
%A.excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max (Akira).xlsx';
A.expmt_table = readtable(A.excelFile);

A.expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';
%A.expmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';

A.bFiles = dir([A.expmtDataFolder '\**\*']);
A.bFiles(~contains({A.bFiles.name}, {'behavior'})) = [];

%A.whoseData = 'Akira';
A.whoseData = 'Jennifer';


%% Load data instead
clear;clc;close all
load C:\Users\maxga\Desktop\RecList.mat
load('C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\shiftVals')
plotOn = 1;

%A.bFiles(~contains({A.bFiles.name}, {'behavior'})) = [];
A.bFiles([A.bFiles.isdir]) = [];
%A.bFiles(~contains({A.bFiles.name}, {'.mat'})) = [];
%A.bFiles(contains({A.bFiles.name}, {'da0301'})) = [];
%A.bFiles(contains({A.bFiles.name}, {'da02'})) = [];
A.bFiles(~contains({A.bFiles.name}, {'aligned'})) = [];

files = A.bFiles;

%% Initial Loop to Align Files
% for j = 1:length(A.bFiles)
%     
%     % Skip Ephys files
%     if ~contains({A.bFiles(j).name}, {'behavior.mat'})
%         continue
%     end
%     
%     if exist(fullfile(A.bFiles(j).folder, strrep(A.bFiles(j).name, 'behavior', 'aligned')), 'file')
%         continue
%     end
%     
% 
%     % Keep track of where you are
%     disp([A.bFiles(j).name, '(', num2str(j), '/', num2str(length(A.bFiles)), ')'])
%     
%     % Open Behavior
%     filePath = fullfile(A.bFiles(j).folder, A.bFiles(j).name);
%     load(filePath)
%     if length(datchandata(behaviorData,'ss')) < 200
%         disp('     No ss Timestamps')
%         continue
%     end
%     
%     % Open Ephys
%     ephysName = strrep(A.bFiles(j).name, 'behavior', 'ephys');
%     ephysEntry = A.bFiles(contains({A.bFiles.name}, ephysName));
%     
%     if ~isempty(ephysEntry)
%         ephysPath = fullfile(ephysEntry.folder, ephysEntry.name);
%         try
%             load(ephysPath)
%         catch
%             disp('Ephys Error')
%             continue
%         end
%         
%         % Align Traces
%         tic
%         [behaviorEphysAligned, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorData, ephysData, plotOn);
%         toc
%         disp(shiftAmt)
%         newName = strrep(ephysName, 'ephys', 'aligned');
%         
%         if shiftConfidence ~= 0
%             save(fullfile(A.bFiles(j).folder, newName), 'behaviorEphysAligned');
%         else
%             disp('Alignment Failure')
%         end
% 
%     else
%         disp('     No Ephys File')
%     end
%     
%     % Plot Traces
%     
% end


%% Double Check Loop

%shiftVal = nan(length(A.bFiles),1);
eSamplerate = 50000;%ephysDat.samplerate;
%ephysData = datchandata(ephysDat,'Ephys');
 

for j = 1:length(files)
    
    if shiftVal(j) > 0 && shiftVal(j) < .1
        continue
    end
    
    % Keep track of where you are
    disp([files(j).name, '(', num2str(j), '/', num2str(length(files)), ')'])
    disp(shiftVal(j));
    
    % Open Behavior
    filePath = fullfile(files(j).folder, files(j).name);
    load(filePath)
    
    timeEphys = 0:1/eSamplerate:(length(behaviorEphysAligned(1, 10).data)-1)/eSamplerate;
    
    
    if shiftVal(j) < 0 || shiftVal(j) > .1
        figure(2);clf
        plot(timeEphys + behaviorEphysAligned(1, 10).tstart, ...
             behaviorEphysAligned(1, 10).data);hold on
        xlim([behaviorEphysAligned(1, 10).tstart, behaviorEphysAligned(1, 10).tstart+.5])
        
        vline(behaviorEphysAligned(1, 8).data(1:100)+behaviorEphysAligned(1, 8).tstart, 'r');
        
        [behaviorEphysAligned, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorEphysAligned, behaviorEphysAligned(1, 10).data, 1);
        
        disp(shiftConfidence)
        if shiftConfidence > 150
            temp = behaviorEphysAligned(end);
            behaviorEphysAligned(10:end) = [];
            behaviorEphysAligned = [behaviorEphysAligned, temp];
            disp(shiftAmt)
            save(fullfile(files(j).folder, files(j).name), 'behaviorEphysAligned');
        end
        
        disp('apple')
    end
    
%     try
%         shiftVal(j) = behaviorEphysAligned(1,10).tstart;
%     catch
%     end
    
end

save('C:\Users\maxga\Desktop\shiftVals', 'shiftVal')