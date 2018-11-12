%% Multielectrode --> .mda for MountainSort 

%% Read from Recording Segment
%Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Granule_cell_recording\NR2_F_10_S1
clear;clc;close all
dbstop if error
cd Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Granule_cell_recording\NR2_F_10_S1
seg_file_names = dir;
seg_file_names(~contains({seg_file_names.name}, 'stim_180807_143')) = [];
seg_file_names(contains({seg_file_names.name}, '.mda')) = [];


%% Make mda & params file for each .rhs file
tic
time = NaN(length(seg_file_names),1);

for i = 1:length(seg_file_names)
    
    % open .rhs file
    read_Intan_RHS2000_file(seg_file_names(i).folder, seg_file_names(i).name)
    
    % create mda
    mdaName = fullfile(seg_file_names(i).folder, strrep(seg_file_names(i).name,'.rhs', '_amplifier_data.mda'));
    writemda(amplifier_data, mdaName)
    
    figure()
    % store other useful information in to params file -- OPTIONAL???? TODO
    %sample_rate = frequency_parameters.amplifier_sample_rate;
    %native_chan_names = {amplifier_channels.native_channel_name};
    time(i) = toc;
    print('Done!')
end