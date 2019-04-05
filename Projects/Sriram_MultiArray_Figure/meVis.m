%% Setup
clear;clc;close all
dbstop if error

% Load file
folder = 'C:\Users\maxwellg\Desktop\290119-selected (2) - Copy';

% Remove everything that is not an .rhs file
cd(folder)
seg_file_names = dir;
seg_file_names(~contains({seg_file_names.name}, '.rhs')) = [];

% Window around Stim Artifcats to remove
tbefore = 0;
tafter = 30000; % 30,000 = 1 second

%% Go through each file found in directory
for i = 1:length(seg_file_names) 
    
    % open .rhs file
    try
        clear amplifier_data
        read_Intan_RHS2000_file(folder, seg_file_names(i).name)
    catch
        warning(['File Error: ', seg_file_names(i).name])
        continue
    end
    
    % set up figure
    q = figure('units','normalized','outerposition',[-0.0042 0.0267 1.0083 0.9800]);
    %q.Visible = 'off';
    ha = tight_subplot(16,2,[0 0],[0 0],[0 0]);
    data_filt = ones(size(amplifier_data));
    
    % Find Stim locations
    stimAll = find(stim_data(any(stim_data,2),:) ~= 0);
    stimStarts = stimAll(1:6:end);
    
    % Plot each Channel
    for j = 1:32       
        % If Stim Artifacts, replace with mean(data)
        if ~isempty(stimStarts)
            meanVal = mean(amplifier_data(j,:));
            for k = 1:length(stimStarts)
                amplifier_data(j,stimStarts(k)-tbefore:stimStarts(k)+tafter) = meanVal;
            end          
        end

        %% Filtering
        samplerate = 30000;
        
        % Bandpass 250 - 3000
        N = 5;
        fc = [250 3000];
        [bb,aa] = butter(N, fc/(samplerate/2), 'bandpass');
        data_filt(j,:) = filtfilt(bb,aa,amplifier_data(j,:));
        
        % OPTIONAL - to remove 60Hz noise (plus harmonics) VERY SLOW!
        % Bandstop 60, 120, 180, 240, 300, etc...
%         for k = 240:60:2400
%             N = 2;
%             fc = [k-2 k+2]; 
%             [bb,aa] = butter(N, fc/(samplerate/2), 'stop');
%             data_filt(j,:) = filtfilt(bb,aa,data_filt(j,:));
%         end

        %% Plot
        hold on
        plot(ha(j), t,amplifier_data(j,:), 'k',t, data_filt(j, :));
        
        % Cosmetics
        set(ha(j),'xtick',[min(t):1:max(t)])
        set(ha(j),'xticklabel',[])
        minVal = min(min(amplifier_data));
        maxVal = max(max(amplifier_data));
        set(ha(j), 'TickDir', 'in')
        box(ha(j),'off')
        ha(j).FontSize = 6;        
    end 
    
    % more Cosmetics
    q.Visible = 'on';
    linkaxes(ha)
    xlim([min(t) max(t)])
    disp(seg_file_names(i).name)
    
    % OPTIONAL Power Spectrum
    %freqSpec(amplifier_data, 30000)
    %freqSpec(data_filt, 30000)
    
    %pause
    close all
    
    
end