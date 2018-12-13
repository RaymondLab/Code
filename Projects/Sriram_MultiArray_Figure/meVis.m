%% Load file

clear;clc;close all
dbstop if error
%cd X:\1_Maxwell_Gagnon\ProjectData_Sriram\Sriram_gc_backup
cd('C:\Users\maxwellg\Desktop\Sriram Nov CG Recording')
seg_file_names = dir;
%seg_file_names(~contains({seg_file_names.name}, 'stim_180807_143')) = [];
seg_file_names(~contains({seg_file_names.name}, 'first_181120_')) = [];
seg_file_names(contains({seg_file_names.name}, '.mda')) = [];
tbefore = 0;
tafter = 30000; % 30,000 = 1 second

%% debug
%file = 'X:\1_Maxwell_Gagnon\ProjectData_Sriram\Sriram_gc_backup';
file = 'C:\Users\maxwellg\Desktop\Sriram Nov CG Recording';

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
    
    q = figure();
    q.Visible = 'off';
    ha = tight_subplot(16,1,[0 0],[0 0],[0 0]);
    
    % Find Stim 
    stimAll = find(stim_data(any(stim_data,2),:) ~= 0);
    stimStarts = stimAll(1:6:end);
    
    % FOR EACH CHANNEL IN FILE
    for j = 1:16
        % If Stim Artifacts, replace with mean(data)
        if ~isempty(stimStarts)
            meanVal = mean(amplifier_data(j,:));
            for k = 1:length(stimStarts)
                amplifier_data(j,stimStarts(k)-tbefore:stimStarts(k)+tafter) = meanVal;
            end          
        end
        
        % Plot
        plot(ha(j), amplifier_data(j,:), 'k')
        
        % Cosmetics
        set(ha(j),'xtick',[])
        set(ha(j),'xticklabel',[])
        set(ha(j),'ytick',[])
        set(ha(j),'yticklabel',[])
        xlim([0 length(amplifier_data(j,:))])
        minVal = min(min(amplifier_data(j,:)));
        maxVal = max(max(amplifier_data(j,:)));
        ylim([minVal maxVal])
        box off
    end 
    
    freqSpec(amplifier_data, 30000)
    q.Visible = 'on';
    linkaxes(ha)
    close all 
    
end