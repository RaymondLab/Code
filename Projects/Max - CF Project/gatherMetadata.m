%% Gather and Store Monkey Metadata


%% Set up

% open Excel File
%excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max (Akira).xlsx';
expmt_table = readtable(excelFile);

%ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';

%bFiles = dir([ExpmtDataFolder '\**\*.0*']);
bFiles = dir([ExpmtDataFolder '\**\*']);

figure(1);
ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);

% Remove directories
bFiles([bFiles.isdir]) = [];
% Remove zip files
bFiles(contains({bFiles.name}, {'.zip'})) = [];

%% Gather
for j = 1:length(bFiles)
    
    disp([bFiles(j).name, '(', num2str(j), '/', num2str(length(bFiles)), ')'])
    % If the file is an ephys or oddly named file, skip it - Jennifer 
    %if length(bFiles(j).name) ~= 11
    %   continue
    %end
    if ~contains({bFiles.name}, {'unit'})
        disp('     -Not Behavior File')
        continue
    end
end

%% Store


%% Plot
