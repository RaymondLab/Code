%% Combine Motor & Ephys Files into a Spike2 .smr

%% Reset Everything
clear;clc;close all


%% Setup
%ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);
%bFiles(~contains({bFiles.name}, 'unit')) = [];

%% Match the corresponding ephys folders with thier motor folders
for j = 1:length(bFiles)
    
    % Check if behavior files has a corresponding ephys file
    ephys_exists = 0;
    full_ephys = [];
    
    % Jennifer's naming Scheme
    %eFolder_temp = strrep(files_m(j).folder, 'da', 'du');
    %eFolder_temp = [eFolder_temp, 'un'];
    %eFile_temp = files_m(j).name;
    %eFile_temp = strrep(eFile_temp, 'da', 'du');
    %eFile_temp = strrep(bFiles(j).name, '.0', '.');
    %full_ephys = fullfile(eFolder_temp, eFile_temp);

    if ~contains(bFiles(j).name, 'unit')
        continue
    end
    % Akira's Ephys naming Scheme
     eFile = strrep(bFiles(j).name, '.0', '.');
     eFile = strrep(eFile, 'unit', 'U');
     
     ephys_loc = find(contains({bFiles.name}, eFile));
     
    % Does this file exist? 
    if ephys_loc > 0
        ephys_exists = 1;
        full_ephys = fullfile(bFiles(ephys_loc).folder, bFiles(ephys_loc).name)
    end

    full_behavior = fullfile(bFiles(j).folder, bFiles(j).name)
    
    % Extract behavior Data
    try
        beh = opensingleMAXEDIT(full_behavior, ephys_exists, full_ephys);
    catch
        warning([full_behavior, ' Failed'])
        continue
    end
    
    % Plot
    figure(1); clf
    ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);
    
    for q = 1:8
        
        axes(ha(q))
        if isempty(beh(q).data)
            title([beh(q).chanlabel, ' is empty'])
            continue
        end

        samplerate = beh(q).samplerate;
        timeVec = beh(q).tstart:(1/samplerate):beh(q).tend;

        % Plot
        plot(timeVec, beh(q).data)
        title(beh(q).chanlabel)

        % only show Tick labels on bottom
        if q ~= length(ha)
            xlimMax = max(timeVec);
            xticks([]);
            xticklabels([]);
        else
            vline(beh(end-1).data(1:20));
            figure(4);clf
            fa = tight_subplot(2,1,[0 0],[.03 .03],[.03 .03]);
            axes(fa(1))
            plot(timeVec, beh(q).data)
            xlim([0 .5])
            axes(fa(2))
            vline(beh(end-1).data(1:50));
            xlim([0 .5])
            figure(1)
        end
    end

    linkaxes(ha, 'x')
    %xlim([0 .5])
    disp(length(beh(8).data) / length(beh(1).data))

    figure(2)
    title(bFiles(j).name)
    disp(timeVec(1))
    figure(4)
    if ephys_loc > 0
        disp('apple')
    end
    clc
    fclose('all')
end