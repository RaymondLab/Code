function VOR_Tests(params)
    % This function takes in the information given to the UI and runs the
    % relavent test(s) on the data
    params.TopFolder = params.folder;
    % Single Analysis
    if params.count == 1
       params.folder = params.smr_files(1).folder; % hackish. related to folder selection error
       [~, params.file] = fileparts(params.folder);
       singleAnalysis(params)
       
    % Batch Analysis
    elseif params.count > 1
        for i = 1:params.count

            % re-set individual parameters for each smr file
            params.folder = params.smr_files(i).folder;
            [~, params.file] = fileparts(params.folder);
            % segNames?
            % segAmt?

            singleAnalysis(params);
            try
                params.smr_files(i).error = 0;
            catch
                params.smr_files(i).error = 1;
            end

            % Close everything, move to next file
            figHandles = findobj('Type', 'figure');
            close(figHandles(~contains({figHandles.Name}, 'VOR_GUI')))
        end

        % Did any files have errors?
        if any([params.smr_files.error])
            disp('Files with Errors: ')
            {params.smr_files(logical([params.smr_files.error])).name}
        else
            disp('No errors!')
        end

    else
        disp('No smr files found!')
    end
    fprintf('File Completed! :) \n\n\n')
end

function singleAnalysis(params)
    %% Prep
    cd(params.folder)
    params = subPlotDim(params);
    params.temp_placement = 1;
    fprintf(['\n###########################\nFile: ', params.file, ' \n'])
    
    %% Default Analysis
    switch params.analysis
        case 'Dark Rearing + Generalization'
            fprintf('Running: Dark Rearing Generalization Analysis\n')
            VOR_DarkRearingGeneralization(params)
        otherwise
            fprintf('Running: Basic Overview\n')
            %% changed to add filtering parameters
            params = VOR_Default(params);
    end

    %% Unique Analysis & Summaries
    fprintf('Generating Summary Figures...'); tic
    warning('off');
    expmtExcelFile = fullfile(params.folder,[params.file '.xlsx']);
    
    switch params.analysis
        case 'Amin_GC_Steps'
            %fprintf('Running: GC Step Summary')
            %VOR_Summary_Amin_gcStep(params)
            VOR_Summary_Sriram_CycleDiff(params, [15, 16 17], [1, 2, 3], 'T30 - T0', 'head')
            
        case 'Sriram_OKR'
            fprintf('Running: Fit Subtraction Analysis\n')
            %VOR_Summary('eyeHphase', expmtExcelFile, 0); 
            %VOR_Summary_Sriram_CycleDiff(params, [59, 60, 61], 2, 'T60 - T0', 'drum')
            %VOR_Summary_Sriram_CycleDiff(params, [15, 16, 17], 2, 'T15 - T0', 'drum')
            %VOR_Summary_Sriram_CycleDiff(params, [59, 60, 61], [15, 16, 17,], 'T60 - T15', 'drum')
            
        case 'Dark Rearing'
            fprintf('Running: Dark Rearing''s t30 & t0 Analysis\n')
            VOR_Summary_Sriram_CycleDiff(params, [15, 16 17], [1, 2, 3], 'T30 - T0', 'head')
            VOR_Summary_Sriram_CycleDiff(params, 14, 4, 'T27 5 - T2 5', 'head')
            
        case 'Alz_BPS_VOR'
            fprintf('Running: Dark Rearing''s t30 & t0 Analysis\n')
            VOR_Summary_Sriram_CycleDiff(params, [11, 12, 13], [1, 2, 3], 'T30 - T0', 'head')
            VOR_Summary_Sriram_CycleDiff(params, 10, 4, 'T27 5 - T2 5', 'head')
            
        case 'Amin_Gen'
            VOR_Summary_Amin_Gen('eyeHgain', expmtExcelFile, 0);
            
        case 'Sriram_Gen'
            VOR_Summary_Sriram_Gen('eyeHgain', expmtExcelFile, 1);
            VOR_Summary_Sriram_Gen('eyeHgain', expmtExcelFile, 0);
            VOR_Summary_Sriram_Gen('eyeHphase', expmtExcelFile, 0);
            
        case 'Default (Sine Only)'
            VOR_Summary('eyeHgain', expmtExcelFile, 1);
            VOR_Summary('eyeHgain', expmtExcelFile, 0);
            VOR_Summary('eyeHphase', expmtExcelFile, 0); 
    end
    
    toc

end

function params = subPlotDim(params)

    %% Prep
    params.segAmt = length(xlsread(fullfile(params.folder, [params.file '.xlsx']), 1, 'B2:B500'));
    sp_width = 10;
    params.sp_Dim = [params.segAmt, sp_width];
    sp_slotList = 1:(params.segAmt * sp_width);

    %% Make list of 'slots' that each figure occupies in the subplot.
    figure_loc = cell(params.segAmt*2, 1);
    slot_index = 1;
    defaultWidth = 2;
    fullSegWidth = 8;

    %% Default analysis figues are in groups of 2: full segment & summary
    for i = 1:(params.segAmt*2)
        % Full Segment locations
        if mod(i, 2)
            figure_loc{i} = sp_slotList(slot_index:slot_index+(fullSegWidth-1));
            slot_index = slot_index + fullSegWidth;
        % Summary Segments
        else
            figure_loc{i} = sp_slotList(slot_index:slot_index+(defaultWidth-1));
            slot_index = slot_index + defaultWidth;
        end
    end
    params.figure_loc = figure_loc;
end
