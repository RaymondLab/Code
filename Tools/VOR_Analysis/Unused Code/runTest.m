function runTest(params)
% This function takes in the information given to the UI and runs the
% relavent test(s) on the data

% Single or Batch Analysis
if contains(params.count, 'Single Analysis')
   singleAnalysis(params)
   disp('Done! :)')
elseif contains(params.count,'Batch Analysis')

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
    %params.badFolders = badFolders((~cellfun('isempty',badFolders)));
    fprintf('\n\nSUCCEEDED FOLDERS: \n')
    disp(goodFolders(~cellfun('isempty',goodFolders)));
    %params.goodFolders = goodFolders(~cellfun('isempty',goodFolders));

    % Export parameters to a cvs file
    exportParameters(params)
    disp('Done! :)')
end
end

function singleAnalysis(params)
    % Move to correct location
    cd(params.folder)

    % Run appropriate Test
    switch params.analysis
        case 'Sine Only - Vanilla'
            fprintf('Running - Sine Analysis with no additinal measuers')
            VOR_Default(params)
        case 'Dark Rearing'
            fprintf('Running: Dark Rearing Analysis\n')
            runVORm
            %VOR_DarkRearing(params)
        case 'Delta-7'
            fprintf('Running: Delta-7')
            params.segCount = 18;
            params.extraFigs = 1;
            VOR_Delta7(params)
        case 'Delta-7 Generalization'
            fprintf('Running: Delta-7 Generalization Analysis\n')
            params.segCount = 28;
            params.extraFigs = 3;
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
           subplotOrganization(params, figureName);
        % deault
        else
            [p, ~] = numSubplots(figureCount);
            figs2subplots( figureName{1} , p )
        end

    end
end

% This function will export all of the parameters of the data analysis so
% they can be refered to later.
function exportParameters(params)

% Add more information to params
params.Run_Date = char(datetime('now'));
params.Run_Date = strrep(params.Run_Date, ':', '-');
params.Computer = getenv('computername');
params.Person = getenv('username');

% convert params struct to table
paramsTable = struct2table(params);

% write summary of parameters to a csv file. csv Files can be read in EXCEL
textFileName = ['Parameters File - ' params.analysis ' - ' params.Run_Date '.csv'];
writetable(paramsTable, textFileName, 'Delimiter', ',')
close('my_files.csv')

end

function subplotOrganization(params, figureName)

    spDim = [ (params.segCount + params.extraFigs) , 10];
    firsts = 1:spDim(2):spDim(1)*spDim(2);
    firsts = firsts';
    aaa = zeros(spDim);
    aaa(:,1) = firsts;
    for i = 1:length(firsts)
        aaa(i,:) = aaa(i,1):aaa(i,1)+spDim(2)-1;

    end


    theNumber = 1;
    for col = 1 : spDim(1)
        for row = 1 : spDim(2)
            a(row, col) = theNumber;
            theNumber = theNumber + 1;
        end
    end

    a = a';
    arr = cell(params.segCount*2 + params.extraFigs, 1);
    row = 1;
    loc = 1;
    for i = 1:length(arr)
        if i > params.segCount*2
            arr{i} = aaa(params.segCount+1,loc):aaa(params.segCount+1,loc+1);
            loc = loc + 2;
        elseif mod(i, 2)
            arr{i} = aaa(row,1):aaa(row, end-2);
        else
             arr{i} = aaa(row, end-1):aaa(row,end);
            row = row + 1;
        end
    end

    arr2 = { a(1,1):a(1, end-2); a(1, end-1):a(1,end);
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

    figs2subplots( figureName{1}, spDim, arr)

end

