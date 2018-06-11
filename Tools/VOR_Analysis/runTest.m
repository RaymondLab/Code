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
    - in batch testing, report how many were found
    - Plot preview of segments to make sure that the start/finish are
    actually getting the proper parts
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
        case 'Delta-7'
            fprintf('Running: Delta-7')
            VOR_Delta7(params)
        case 'Delta-7 Generalization'
            fprintf('Running: Delta-7 Generalization Analysis\n')
            VOR_Delta7Generalization(params)
        case 'Dark Rearing + Generalization'
            fprintf('Running: Dark Rearing Generalization Analysis\n')
            VOR_DarkRearingGeneralization(params)
    end
    
    % make polar plots?
    if params.do_polar_plots
        polarPlotVectorsMean2
    end
    
    % Make Subplots?
    if params.do_subplots
        tempFolders = strsplit(params.folder, '\'); 
        figureName = strcat(params.folder, '\', tempFolders(end), '_', 'SUBPLOT', '_', 'Thresh at ', num2str(params.saccadeThresh) );
        figureCount = length(findobj('Type', 'figure'));
        
        % this function automatically finds the optimal subplot organization
        
        
        % TESTING
        if strcmp(params.analysis, 'Delta-7')
            p = [19, 10];
            firsts = 1:p(2):p(1)*p(2);
            
            theNumber = 1;
            for col = 1 : p(1)
                for row = 1 : p(2)
                    a(row, col) = theNumber;
                    theNumber = theNumber + 1;
                end
            end
            a = a';
            arr = { a(1,1):a(1, end-2); a(1, end-1):a(1,end);
                    a(2,1):a(2, end-2); a(2, end-1):a(2,end);
                    a(3,1):a(3, end-2); a(3, end-1):a(3,end);
                    a(4,1):a(4, end-2); a(4, end-1):a(4,end);
                    a(5,1):a(5, end-2); a(5, end-1):a(5,end);
                    a(6,1):a(6, end-2); a(6, end-1):a(6,end);
                    a(7,1):a(7, end-2); a(7, end-1):a(7,end);
                    a(8,1):a(8, end-2); a(8, end-1):a(8,end);
                    a(9,1):a(9, end-2); a(9, end-1):a(9,end);
                    a(10,1):a(10, end-2); a(10, end-1):a(10,end);
                    a(11,1):a(11, end-2); a(11, end-1):a(11,end);
                    a(12,1):a(12, end-2); a(12, end-1):a(12,end);
                    a(13,1):a(13, end-2); a(13, end-1):a(13,end);
                    a(14,1):a(14, end-2); a(14, end-1):a(14,end);
                    a(15,1):a(15, end-2); a(15, end-1):a(15,end);
                    a(16,1):a(16, end-2); a(16, end-1):a(16,end);
                    a(17,1):a(17, end-2); a(17, end-1):a(17,end);
                    a(18,1):a(18, end-2); a(18, end-1):a(18,end);
                    a(19,1):a(19,2);
                };

%             arr = {firsts(1):p(2)-1; firsts(1)+p(2)-1;
%                    firsts(2):firsts(2)+(p(2)-3); firsts(2)+p(2)-1;
%                    firsts(3):firsts(3)+p(2)-3; firsts(3)+p(2)-1;
%                    firsts(4):firsts(4)+p(2)-3; firsts(4)+p(2)-1;
%                    firsts(5):firsts(5)+p(2)-3; firsts(5)+p(2)-1;
%                    firsts(6):firsts(6)+p(2)-3; firsts(6)+p(2)-1;
%                    firsts(7):firsts(7)+p(2)-3; firsts(7)+p(2)-1;
%                    firsts(8):firsts(8)+p(2)-3; firsts(8)+p(2)-1;
%                    firsts(9):firsts(9)+p(2)-3; firsts(9)+p(2)-1;
%                    firsts(10):firsts(10)+p(2)-3; firsts(10)+p(2)-1;
%                    firsts(11):firsts(11)+p(2)-3; firsts(11)+p(2)-1;
%                    firsts(12):firsts(12)+p(2)-3; firsts(12)+p(2)-1;
%                    firsts(13):firsts(13)+p(2)-3; firsts(13)+p(2)-1;
%                    firsts(14):firsts(14)+p(2)-3; firsts(14)+p(2)-1;
%                    firsts(15):firsts(15)+p(2)-3; firsts(15)+p(2)-1;
%                    firsts(16):firsts(16)+p(2)-3; firsts(16)+p(2)-1;
%                    firsts(17):firsts(17)+p(2)-3; firsts(17)+p(2)-1;
%                    firsts(18):firsts(18)+p(2)-3; firsts(18)+p(2)-1;
%                    };
            figs2subplots( figureName{1}, p, arr)
        else
            [p, ~] = numSubplots(figureCount);
            figs2subplots( figureName{1} , p )
        end

    end
end        