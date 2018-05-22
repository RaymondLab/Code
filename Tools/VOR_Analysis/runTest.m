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
    - finish desaccade script
    - add new desaccade script now all analysis
%}

% Single or Batch Analysis
if strcmp(params.count, 'Single Analysis')
   singleAnalysis(params)
    
elseif strcmp(params.count,'Batch Analysis')
    
    subfolders = dir(params.folder);
    topDirectory = params.folder;
    
    % remove non-folders and calib folders from 'subfolders' list
    for ii = length(subfolders):-1:1
        if ~(subfolders(ii).isdir)
            subfolders(ii) = [];
            continue
        end
        if contains(subfolders(ii).name, '_cali')
            subfolders(ii) = [];
            continue
        end
    end
    
    goodFolders = cell(length(subfolders),1);
    badFolders = cell(length(subfolders),1);
    
    for ii = 3:length(subfolders)
        try
            % Change folder to the relevant sub-folder
            params.folder = strcat(subfolders(ii).folder, '\', subfolders(ii).name);
            
            % Run the single individual analysis on each subfolder
            singleAnalysis(params);
            
            % Keep track of folders that worked, and those that didn't
            goodFolders{ii} = strcat(subfolders(ii).folder,'\', subfolders(ii).name);
        catch
            badFolders{ii} = strcat(subfolders(ii).folder,'\', subfolders(ii).name);
        end

        % close all figures, except the GUI
        figHandles = findobj('Type', 'figure');
        for i = 1:length(figHandles)
            if strcmp(figHandles(i).Name, 'VOR_Analysis')
                figHandles(i) = []; break
            end
        end
        close(figHandles)
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
        case 'Dark Rearing'
            fprintf('Running: Dark Rearing Analysis\n')
            runVORm
            %VOR_DarkRearing(params)
        case 'Delta-7 Generalization'
            fprintf('Running: Delta-7 Generalization Analysis\n')
            VOR_Delta7Generalization(params)
        case 'Dark Rearing + Generalization'
            fprintf('Running: Delta-7 Generalization Analysis\n')
            VOR_DarkRearingGeneralization(params)
    end
    
    % make polar plots?
    if params.do_polar_plots
        polarPlotVectorsMean2
    end
    
    % Make Subplots?
    if params.do_subplots
        figureName = strcat(params.folder, '_', 'SUBPLOT', '_', 'Unfiltered', '_', 'New_Saccade');
        figureCount = length(findobj('Type', 'figure'));
        
        % this function automatically finds the optimal subplot organization
        [p, ~] = numSubplots(figureCount);
        figs2subplots( figureName , p )
    end
end        