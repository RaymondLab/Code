%% Combine Motor & Ephys Files into a Spike2 .smr

%% Reset Everything
clear;clc;close all


%% Setup
ExpmtDataFolder = 'D:\NOT FROM SERVER FOR KYLE\2019_05 - Max Climbing Fiber\Initial Data for testing\D1_1995';
%ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);
%bFiles(~contains({bFiles.name}, '303')) = [];


for j = 1:length(bFiles)
    %% Match the corresponding ephys folders with thier motor folders
    
    ephys_exists = 0;
    ePath = [];
    
    % Jennifer's naming Scheme
    eFile = strrep(bFiles(j).name, 'da', 'du');
    eFile = strrep(eFile, '.0', '.');

    % Akira's Naming Scheme
    %if ~contains(bFiles(j).name, 'unit')
    %    continue
    %end
    % Akira's Ephys naming Scheme
    %eFile = strrep(bFiles(j).name, '.0', '.');
    %eFile = strrep(eFile, 'unit', 'U');
     
    % Search through lisberger files to see if ephys exists
    ephys_loc = find(contains({bFiles.name}, eFile));
     
    % Extract ephys Data 
    if ephys_loc > 0
        ephys_exists = 1;
        ePath = fullfile(bFiles(ephys_loc).folder, bFiles(ephys_loc).name)
    else
        warning([eFile ': No Ephys'])
        continue
    end
    
    % Extract behavior Data
    try
        bPath = fullfile(bFiles(j).folder, bFiles(j).name)
        beh = opensingleMAXEDIT(bPath, ephys_exists, ePath);
    catch
        warning([bPath, ' Failed'])
        continue
    end
    
    %% Plots
    % Figure 1: Overview of each channel
    figure(1); clf
    ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);
    
    for q = 1:8
        
        axes(ha(q))
        
        if isempty(beh(q).data)
            title([beh(q).chanlabel, ' is empty'])
            continue
        end

        samplerate = beh(q).samplerate;
        timeVec = 0:( 1/samplerate ):( length(beh(q).data)-1 )/samplerate;

        % Plot
        plot(timeVec, beh(q).data)
        title(beh(q).chanlabel)

        % Only show Tick labels on bottom (Epyhs Channel)
        if q ~= length(ha)
            xticks([]);
        end
    end
    linkaxes(ha, 'x')
    
    if ephys_loc > 0
        allignEventsAndEphys(beh(q).data, beh(end-1).data, samplerate, 2);
    end
    
    clc
    fclose('all')
end