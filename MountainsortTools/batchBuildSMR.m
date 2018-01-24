tic


options

filenames = [
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170810_JC6_ephys_cell2\20170810_JC6_ephys_cell2_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170810_JC6_ephys_cell3\20170810_JC6_ephys_cell3_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170817_JC6_ephys_cell1\20170817_JC6_ephys_cell1_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170823_JC5_ephys_cell2b\20170823_JC5_ephys_cell2b_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170914_JC7_cell1\20170914_JC7_cell1_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170920_JC7_ephys_cell1c\20170920_JC7_ephys_cell1c.smr"
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170920_JC7_ephys_cell1c_2ms\20170920_JC7_ephys_cell1c_2ms_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell2a\20170924_JC10_cell2a_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell2c\20170924_JC10_cell2c.smr",    
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170924_JC10_cell3\20170924_JC10_cell3_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell2a\20170925_JC10_cell2a_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell2c\20170925_JC10_cell2c_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell3a\20170925_JC10_cell3a_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20170925_JC10_cell5\20170925_JC10_cell5_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell2b_1mW_1ms\20171005_JC9_cell2b_1mW_1ms_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell2c_10mW_1ms\20171005_JC9_cell2c_10mW_1ms_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell3\20171005_JC9_cell3_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell4a_1mW_1ms\20171005_JC9_cell4a_1mW_1ms_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171005_JC9_cell4c_10mW_1ms\20171005_JC9_cell4c_10mW_1ms_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171018_JC8_cell1b_10mW\20171018_JC8_cell1b_10mW_MS.smr",
    %"Z:\1_Maxwell_Gagnon\hannahProjectData\smrFiles\20171018_JC8_cell1c_1mW\20171018_JC8_cell1c_1mW_MS.smr",
    ];

% loop through each file in the filenames / ops.target list

for i = 1:length( filenames )
    
    ops.target                  = filenames{i}; % target .smr file to use
    buildToSpike2(ops)
    disp(i*(1/length(ops.target)))
    
end

toc