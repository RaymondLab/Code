%% Mass VOR Analysis
% 2/1/18 Maxwell Gagnon
% - Search through each of the child direcotries of a given folder and attempt
% to run runVORm on each, then will spit out a list of what folders failed
% and which folders secceeded.

%% Set directories and preallocate vars
tic
topDirectory = cd;
subfolders = dir;
goodFolders = cell(length(subfolders),1);
badFolders = cell(length(subfolders),1);


%% CYCLE THROUGH EACH SUBFOLDER
for i = 1:length(subfolders)
    
    try
        % NAVIGATE TO FOLDER AND ATTEMPT TO run runVORm
        cd(subfolders(i).name);
        runVORm
        % Run Polar Plots
        polarPlotVectorsMean2
        % CREATE & SAVE SUBPLOTS
        figureName = strcat(subfolders(i).name, '_', 'SUBPLOT');
        figs2subplots( figureName , [6 7] )
        goodFolders{i} = strcat(subfolders(i).folder,'\', subfolders(i).name);
    catch
        badFolders{i} = strcat(subfolders(i).folder,'\', subfolders(i).name);
    end
    
    % RETRUN TO TOP DIRECTORY
    cd(topDirectory)
end


%% PRINT RESULTS
fprintf('FAILED FOLDERS:\n')
disp(badFolders(~cellfun('isempty',badFolders)));

fprintf('\n\nSUCCEEDED FOLDERS: \n')
disp(goodFolders(~cellfun('isempty',goodFolders)));

toc