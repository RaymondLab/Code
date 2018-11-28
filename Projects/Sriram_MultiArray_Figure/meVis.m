%% Load file

clear;clc;close all
dbstop if error
cd X:\1_Maxwell_Gagnon\ProjectData_Sriram\Sriram_gc_backup
seg_file_names = dir;
seg_file_names(~contains({seg_file_names.name}, 'stim_180807_143')) = [];
seg_file_names(contains({seg_file_names.name}, '.mda')) = [];
tbefore = 0;
tafter = 30000; % 30,000 = 1 second

%% debug
file = 'X:\1_Maxwell_Gagnon\ProjectData_Sriram\Sriram_gc_backup';

%% Extract each

% time each segment
tic
time = NaN(length(seg_file_names),1);

% FOR EACH FILE
for i = 1:length(seg_file_names)
    
    % open .rhs file
    try
        read_Intan_RHS2000_file(file, seg_file_names(i).name)
    catch
        warning(['File Error: ', seg_file_names(i).name])
        pause
        continue
    end
    
    figure()
    ha = tight_subplot(16,1,[0 0],[0 0],[0 0]);
    
    % FOR EACH CHANNEL IN FILE
    for j = 1:16
        
        % Remove Stim Artifacts, replace with mean(data)
        stimAll = find(stim_data(any(stim_data,2),:) ~= 0);
        stimStarts = stimAll(1:6:end);
        if ~isempty(stimStarts)
            meanVal = mean(amplifier_data(j,:));
            for k = 1:length(stimStarts)
                amplifier_data(j,stimStarts(k)-tbefore:stimStarts(k)+tafter) = meanVal;
            end          
        end
        
        % Plot
        axes(ha(j))
        plot(amplifier_data(j,:), 'k')
        
        % Cosmetics
        set(gca,'xtick',[])
        set(gca,'xticklabel',[])
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        xlim([0 length(amplifier_data(j,:))])
        minVal = min(min(amplifier_data(j,:)));
        maxVal = max(max(amplifier_data(j,:)));
        ylim([minVal maxVal])
    end 
    figure()
    freqSpec(amplifier_data, 30000)
    %print(seg_file_names(i).name)
    close all 
    
end