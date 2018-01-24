% Compare the spikes times of a list of mda files to a list of txt files

filenames = [
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170810_JC6_ephys_cell2\20170810_JC6_ephys_cell2_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170810_JC6_ephys_cell3\20170810_JC6_ephys_cell3_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170817_JC6_ephys_cell1\20170817_JC6_ephys_cell1_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170823_JC5_ephys_cell2b\20170823_JC5_ephys_cell2b_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170914_JC7_cell1\20170914_JC7_cell1_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170920_JC7_ephys_cell1c_2ms\20170920_JC7_ephys_cell1c_2ms_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell2a\20170924_JC10_cell2a_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell2c\20170924_JC10_cell2c_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell3\20170924_JC10_cell3_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell2a\20170925_JC10_cell2a_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell2c\20170925_JC10_cell2c_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell3a\20170925_JC10_cell3a_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell5\20170925_JC10_cell5_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell2b_1mW_1ms\20171005_JC9_cell2b_1mW_1ms_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell2c_10mW_1ms\20171005_JC9_cell2c_10mW_1ms_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell3\20171005_JC9_cell3_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell4a_1mW_1ms\20171005_JC9_cell4a_1mW_1ms_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell4c_10mW_1ms\20171005_JC9_cell4c_10mW_1ms_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171018_JC8_cell1b_10mW\20171018_JC8_cell1b_10mW_MS.smr",
    "Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171018_JC8_cell1c_1mW\20171018_JC8_cell1c_1mW_MS.smr",
    ];

sampleRate = 50000;
offset =   .0004;

% get text file's spike information and place it in a huge matrix
for i = 1:length(filenames)
    % get txt file info
    txtspikeFile = strrep(filenames{i}, '.smr', '.txt');
    txtspikeFile = strrep(txtspikeFile, 'smrFiles', 'txtFiles');
    txtspikeData = csvread(txtspikeFile);
    txtspikeTimes = txtspikeData(:,2)';
    
    % get corresponding mda file info
    mdaspikeFile = strrep(filenames{i}, '_MS.smr', '.curated.mda');
    mdaspikeFile = strrep(mdaspikeFile, 'smrFiles', 'mdaFiles');
    mdaspikeData = readmda(mdaspikeFile);
    mdaspikeTimes = mdaspikeData(2,:) ./ sampleRate;
    
    % compare the two
    fprintf('File: #%d\n', i)
    %txtspikeTimesMOD = txtspikeTimes + offset;
    if i ==4
    end
    
    if length(mdaspikeTimes) == length(txtspikeTimes)
        fprintf('Same Length!\n')
        diff = mdaspikeTimes - txtspikeTimes - offset;
        disp(min(abs(diff)))
    else
        fprintf('NOT same length!\n')
        fprintf('txt Unit Count: %d\n', max(txtspikeData(:,1)))
        fprintf('mda Unit Count: %d\n', max(mdaspikeData(3,:)))
    end   
    
end



%u4 = mdaspikeData(3,find(mdaspikeData(3,:) == 4));