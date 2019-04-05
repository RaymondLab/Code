%% SRIRAM MULTI ARRAY FIGURE SCRIPT - AUGUST 29 2018

%% Read from Recording Segment
clear;clc;close all
%cd Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Granule_cell_recording\NR2_F_10_S1
%cd('C:\Users\maxwellg\Desktop\Sriram Nov CG Recording')
cd('C:\Users\maxwellg\Desktop\290119-selected COPY')
seg_file_names = dir;
%seg_file_names(~contains({seg_file_names.name}, 'first_181120_')) = [];
%seg_file_names(~contains({seg_file_names.name}, 'stim_180807_143')) = [];
seg_file_names(contains({seg_file_names.name}, '.mda')) = [];
sample_rate = frequency_parameters.amplifier_sample_rate;
native_chan_names = {amplifier_channels.native_channel_name};
read_Intan_RHS2000_file(seg_file_names(1).folder, seg_file_names(1).name)    




s_to_disp = [0 60];
data = amplifier_data;


%% plot each channel for specific
for j = 2%:length(seg_file_names)
    
    % open each segment
    read_Intan_RHS2000_file(seg_file_names(j).folder, seg_file_names(j).name)
    sample_rate = frequency_parameters.amplifier_sample_rate;
    native_chan_names = {amplifier_channels.native_channel_name};
    % Amp Data Plots (2x2)
    plot4Group(1,   4, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(5,   8, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(9,  12, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(13, 16, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(17, 20, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(21, 24, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(25, 28, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)
    plot4Group(29, 32, s_to_disp, sample_rate, data, t, seg_file_names(j), native_chan_names)

      % Amp Data plots (4x4)
%     plot4Group(1, 16, s_to_disp, sample_rate, amplifier_data, t, seg_file_names(j), native_chan_names)
%     plot4Group(17, 32, s_to_disp, sample_rate, amplifier_data, t, seg_file_names(j), native_chan_names)

end


function plot4Group(start, stop, s_to_disp, s_r, data, t, seg_file_names, native_chan_names)

    % create full screen figure
    figure('units','normalized','outerposition',[0 0 1 1])
    
    for i = start:stop

        % define subplot position and plot channel data
        subplot(2,2, (i - start) + 1)
        plot(t(1+s_to_disp(1)*s_r:s_to_disp(2)*s_r), data(i, 1+s_to_disp(1)*s_r:s_to_disp(2)*s_r ))
        
        % Only display X axis on first subplot, no need to repeat each time
        if i == start
            xlabel('seconds')
            xticks([s_to_disp(1), s_to_disp(2)])
        else
            xticks([])
        end
        
        % other Cosmetics
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'FontName','Times','fontsize',5.5)
        title([seg_file_names.name(1:end-4) ': ', native_chan_names{i}],'Interpreter','none', 'FontSize', 12)
        yy = ylim;
        yy = [yy(1) 0 yy(2)];
        yticks(yy)      
    end
end



    