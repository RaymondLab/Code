%% Set up

% open Excel File
excelFile = 'C:\Users\maxwellg\Documents\RL_Code\Projects\Max - CF Project\RAYMOND_DATA Max Edit.xlsx';
expmt_table = readtable(excelFile);

% Seperate the folders into motor recordings and ephys recordings
ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);
bFiles(contains({bFiles.name}, {'du'})) = [];

%% Match the corresponding ephys folders with thier motor folders
for j = 1:length(bFiles)

    % Does this experiment exist in the excel file?
    expmt_row = find(contains(expmt_table.Filename, bFiles(j).name));

    % Does this experiment have a matching Ephys file?
    ephys_exists = 0;
    if contains(bFiles(j).name, '.0')
        eFolder = strrep(bFiles(j).folder, 'da', 'du');
        eFolder = [eFolder, 'un'];
        eFile = bFiles(j).name;
        eFile = strrep(eFile, 'da', 'du');
        eFile = strrep(eFile, '.0', '.');
        full_ephys = fullfile(eFolder, eFile);
        if isfile(full_ephys)
            ephys_exists = 1;
        end
    end

    % Open file
    try
        beh = opensingleMAXEDIT(fullfile(bFiles(j).folder, bFiles(j).name), ephys_exists, full_ephys);
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

    % Add Ephys File Name
    if ephys_exists && contains(expmt_table.EphysFilename{expmt_row}, 'PlaceHolder')
        expmt_table.EphysFilename{expmt_row} = eFile;
    end

    % Add Ephys Alignment
    if ephys_exists && (expmt_table.EphysAlignmentValue(expmt_row) == 0)
        ephys_shift = beh(contains({beh.chanlabel}, 'Ephys')).tstart;
        expmt_table.EphysAlignmentValue(expmt_row) = ephys_shift;
    end

    % Add nan values when there is no ephys data
    if ~ephys_exists
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