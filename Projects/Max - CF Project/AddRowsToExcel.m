%% Set up

% open Excel File
excelFile = 'C:\Users\maxwellg\Documents\RL_Code\Projects\Max - CF Project\RAYMOND_DATA Max Edit.xlsx';
expmt_table = readtable(excelFile);

ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);
bFiles(contains({bFiles.name}, {'301'})) = [];

%% Match the corresponding ephys folders with their motor folders
for j = 1:length(bFiles)

    % If the file is a ephys file, skip it
    if contains({bFiles.name}, {'du'})
        continue
    end
    
    % Does this experiment exist in the excel file?
    expmt_row = find(contains(expmt_table.Filename, bFiles(j).name));

    % Does this experiment have a matching Ephys file?
    ephys_exists = 0;
    ePath = [];
    if contains(bFiles(j).name, '.0')
        eFile = strrep(bFiles(j).name, 'da', 'du');
        eFile = strrep(eFile, '.0', '.');
        ephys_loc = find(contains({bFiles.name}, eFile));
        if ephys_loc > 0
            ephys_exists = 1;
            ePath = fullfile(bFiles(ephys_loc).folder, bFiles(ephys_loc).name);
        end
    end

    % Open file
    try
        bPath = fullfile(bFiles(j).folder, bFiles(j).name)
        [beh shiftAmt, shiftConfidence] = opensingleMAXEDIT(bPath, ephys_exists, ePath);
    catch
        warning(fullfile(bFiles(j).folder, bFiles(j).name))
        continue
    end

    % Add New line if needed
    if isempty(expmt_row)
        TempRow = expmt_table(find(contains(expmt_table.Filename, 'PlaceHolder')), :);
        TempRow.Filename = bFiles(j).name;
        expmt_table = [expmt_table; TempRow];
        expmt_row = find(contains(expmt_table.Filename, bFiles(j).name));
        disp(bFiles(j).name)
    end

    % ephys information
    if ephys_exists
        
        % Add Ephys File Name
        if ~contains(expmt_table.EphysFilename{expmt_row}, eFile)
            expmt_table.EphysFilename{expmt_row} = eFile;
        end
        
        % Add Alignment Value
        ephys_shift = beh(contains({beh.chanlabel}, 'Ephys')).tstart;
        if ~(expmt_table.EphysAlignmentValue(expmt_row) == ephys_shift) && (shiftConfidence > 30)
            expmt_table.EphysAlignmentValue(expmt_row) = ephys_shift;
        else
            expmt_table.EphysAlignmentValue(expmt_row) = NaN;
        end
        
    % No ephys information
    else
        expmt_table.EphysFilename{expmt_row} = NaN;
        expmt_table.EphysAlignmentValue(expmt_row) = 0; 
    end

    % Add CS Information
    if isempty(beh(contains({beh.chanlabel}, 'cs')).data)
        expmt_table.CSPresent(expmt_row) = 0;
        expmt_table.CSSorted(expmt_row) = 0;
    end
    
    fclose('all');
end

writetable(expmt_table, excelFile);