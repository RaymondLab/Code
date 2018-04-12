function runTest(params)
% This function takes in the information given to the UI and runs the 
% relavent test(s) on the data
%{
TODO
    - Second pass on the Desaccading fit
    - Print the Parameters in the results section (Test Summary document?)
    - VORsineFit --> eyevel2cycle. What is this used for? 
    - Take note of each filterin/smoothing that takes place
    - Eye Coil filtering? - Ask Hannah
    - Seperate unique analysis to individual functions
    - Error Handling for bad information
    - Turn runVOR into function, not script
    - Name of Sriram's Project
    - auto remove 'calib' folders from attempts
    - subplot auto choose dimensions / manual choose dimensions 
%}

% Single or Batch Analysis
if params.count == 'Single Analysis'
   singleAnalysis(params)
    
elseif params.count == 'Batch Analysis'
    
    subfolders = dir(params.folder);
    goodFolders = cell(length(subfolders),1);
    badFolders = cell(length(subfolders),1);
    
    for ii = 3:length(subfolders)
        try
            % Change folder to the relevant sub-folder
            params.folder = subfolders(ii).folder;
            
            % Run the single individual analysis on each subfolder
            singleAnalysis(params);
            
            % Keep track of folders that worked, and those that didn't
            goodFolders{ii} = strcat(subfolders(ii).folder,'\', subfolders(ii).name);
        catch
            badFolders{ii} = strcat(subfolders(ii).folder,'\', subfolders(ii).name);
        end

        close all
        cd(topDirectory)
    end
    
    % Print which folders worked, and which didn't
    fprintf('FAILED FOLDERS:\n')
    disp(badFolders(~cellfun('isempty',badFolders)));
    fprintf('\n\nSUCCEEDED FOLDERS: \n')
    disp(goodFolders(~cellfun('isempty',goodFolders)));
end
end

function singleAnalysis(params)
    % Move to correct location
    cd(params.folder)
    
    % Run appropriate Test
    switch params.analysis
        case 'original'
            fprintf("Running: Original Analysis\n")
            runVOR
            %VOR_original(params)
        case 'Sriram'
            fprintf('Running: Sriram''s Analysis\n')
            runVORm
            %VOR_Sriram(params)
        case 'Delta-7 Generalization'
            fprintf('Running: Delta-7 Generalization Analysis\n')
            runVORa
            %VOR_Delta7Gen(params)
    end
    
    % Make Subplots?
    if params.do_subplots
        figureName = strcat(params.folder, '_', 'SUBPLOT', '_', 'Unfiltered', '_', 'New_Saccade');
        figs2subplots( figureName , [7 9] )
    end
    
    % make polar plots?
    if params.do_polar_plots
        polarPlotVectorsMean2
    end
end        