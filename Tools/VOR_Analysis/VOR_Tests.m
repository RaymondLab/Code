function VOR_Tests(params)
    % This function takes in the information given to the UI and runs the
    % relavent test(s) on the data

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
    
    %% Default Analysis
    switch params.analysis
        case 'Dark Rearing + Generalization'
            fprintf('Running: Dark Rearing Generalization Analysis\n')
            VOR_DarkRearingGeneralization(params)
        case 'Amin_GC_Steps'
            fprintf('Running: Amin''s Granule Cell Step Analysis\n')
            VOR_Default_Step(params);
        otherwise
            fprintf('Running: Default Sine Analysis\n')
            params = VOR_Default(params);
    end

    %% Unique Analysis & Summaries
    fprintf('Generating Summary Figures...')
    warning('off');
    expmtExcelFile = fullfile(params.folder,[params.file '.xlsx']);
    
    switch params.analysis
        case 'Sriram_OKR'
            fprintf('Running: Fit Subtraction Analysis\n')
            VOR_Summary('eyeHphase', expmtExcelFile, 0); 
            VOR_Summary_Sriram_OKR(params, [7 8 9], [1 2 3], 'T60 - T0')
            VOR_Summary_Sriram_OKR(params, [4 5 6], [1 2 3], 'T15 - T0')
            VOR_Summary_Sriram_OKR(params, [7 8 9], [4 5 6], 'T60 - T15')
            % JENN FUNCTION GOES HERE
            
        case 'Dark Rearing'
            fprintf('Running: Dark Rearing''s t30 & t0 Analysis\n')
            VOR_Summary_Sriram_DR1(params);
            
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
    
    fprintf('Done!\n')

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
