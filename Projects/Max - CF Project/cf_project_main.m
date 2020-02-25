%% SETUP
clear;clc;%close all
try
    [dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    p.expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
catch
    [dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    p.expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
end

% Only keep 'Aligned Files'
cd(p.expmtDataFolder);
allFiles = dir('**/*aligned*.mat');
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];
dataTable(logical(dataTable.maxRemoved),:) = []; % Bad Files
dataTable(~(dataTable.sortedCS),:) = [];

%% PARAMETERS

% SS FIRING RATE CALULATION
p.ss_fr_calc = 'RecipInterval'; % RecipInterval, InstFiringRate, spikeDensityFunction'

p.binSize = 50; % (ms)
p.kernel_sd = .01; % Seconds
p.bin_ifr = .02; % Seconds

% 3 Riciprical interval Method
p.fr_thresh = 500;

% EXPERIMENTAL CONDITIONS
p.conditions    = {'csNOcs'}; %{'csNOcs', 'csNOcs_B', 'NOcsNOcs', '2csNOcs', 'allcs'};
p.stimTypes     = {'sine'}; % 'sine', 'step'
p.expmtFreqs    = [.5]; % .5, 1, 2, 5
p.stepTypes     = {'50msAccel_200msVel', '1000', '500', '250', '150' '80'}; % '50msAccel_200msVel', '1000', '500', '250', '150' '80'
p.learningTypes = {'x2', 'x0', 'OKR', 'VOR'};%, 'x0', 'OKR', 'VOR'};

% PLOTTING CHOICES
p.plots = [0, ... % Sanity Check Plot
           0, ... % All Channels Plot
           1, ... % Final Average plots
           0, ... % Individual Example Plots
           0, ... % Visualize Relationship between CS, Ephys, and Firing Rate
           0, ... % Same as 3, but for a single cell recording
           0, ... % radial plots for ss tuning checks
           0];    % radial plots for ss tuning checks ALL CELLS
% OTHER
p.preProcess = [1, ... % Remove Complex Spikes from Simple Spike Data
                1, ... % Remove Complex Spike Spikelets from Simple Spike Data
                1];    % Remove Simple Spikes that are too close together

%% SINE or STEP
for stimType_indx = 1:length(p.stimTypes)
    switch p.stimTypes{stimType_indx}
        case 'sine'
            relaventLen = length(p.expmtFreqs);
        case 'step'
            relaventLen = length(p.stepTypes);
    end
    
    for expmtFreq_indx = 1:relaventLen
        
        for condition_indx = 1:length(p.conditions)
            
            for learningtype_indx = 1:length(p.learningTypes)
                
                %% SELECT THE DATA THAT YOU ARE INTERESTED IN
                tempTable = dataTable;
                tempTable(~contains(tempTable.sineStep, p.stimTypes(stimType_indx)),:) = [];
                tempTable(~contains(tempTable.learningType, p.learningTypes(learningtype_indx)),:) = [];
                
                switch p.stimTypes{stimType_indx}
                    case 'sine'
                        tempTable(~(tempTable.freq == p.expmtFreqs(expmtFreq_indx)),:) = [];
                        
                        metainfoTitle = [' | ', p.stimTypes{stimType_indx}, ' | ', ...
                                        num2str(p.expmtFreqs(expmtFreq_indx)), 'Hz | ', ...
                                        p.conditions{condition_indx}, ' | ', ...
                                        p.learningTypes{learningtype_indx}, ' | '];
                        p.csLocFilename = ['CSLocations_csNOcs_', ...
                                        p.stimTypes{stimType_indx}, '_', ...
                                        p.learningTypes{learningtype_indx}, '_', ...
                                        num2str(p.expmtFreqs), '.mat'];
                    case 'step'
                        tempTable(~contains(tempTable.stepType, p.stepTypes(expmtFreq_indx)),:) = [];
                        
                        metainfoTitle = [' | ', p.stimTypes{stimType_indx}, ' | ', ...
                                        p.stepTypes{expmtFreq_indx}, ' ms | ', ...
                                        p.conditions{condition_indx}, ' | ', ...
                                        p.learningTypes{learningtype_indx}, ' | '];
                        p.csLocFilename = ['CSLocations_csNOcs_', ...
                                        p.stimTypes{stimType_indx}, '_', ...
                                        p.stepTypes{expmtFreq_indx}, '.mat'];
                end
                
                %% Printing
                disp(metainfoTitle)
                disp(['Files Found: ', num2str(height(tempTable))]);
                if height(tempTable) == 0
                    continue
                end
                
                %% PREALLOCATE
                alldiffs = [];
                alldiffPercent = [];
                allgoodcsLocs = [];
                allcs = [];
                allDeltas = [];
                ss_times_diff_all = [];
                allCycles_ss = [];
                allPhase = [];
                allAmp = [];
                
                %% LOOP THROUGH EACH FILE
                for i = 1:height(tempTable)
                    disp(tempTable.name{i})
                    
                    % Open the File
                    renamedFile = strrep(tempTable.name{i}, '.', '_');
                    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
                    load(fullfile(expmtRow(1).folder, expmtRow(1).name));
                    segData = behaviorEphysAligned;
                    if isempty(segData(9).data)
                        disp([renamedFile, ' Contains no CS!!!']);
                        continue
                    end
                    
                    % Run Analysis
                    [ss_times_diff, diffs, goodcsLocs, cs, Cycles_ss, z, csInfo] = mainCFanalysis(segData, tempTable(i,:), p, ...
                                                    p.expmtFreqs(expmtFreq_indx), ...
                                                    p.learningTypes{learningtype_indx}, ...
                                                    p.conditions{condition_indx});
                                                    %p.stepTypes{expmtFreq_indx}, ...
                    % Collect running data
                    ss_times_diff_all = [ss_times_diff_all; ss_times_diff];
                    alldiffs = [alldiffs diffs];
                    allgoodcsLocs = [allgoodcsLocs; goodcsLocs];
                    allcs = [allcs; cs];
                    allCycles_ss = [allCycles_ss; Cycles_ss];
                    allPhase = [allPhase; z.ssfr_phase];
                    allAmp = [allAmp; z.ssfr_amp];
                    
                    % PLOT Summary: Single Cell Averages
                    if p.plots(6)
                        plot_summary1(cs, z, goodcsLocs, [metainfoTitle, ' ', tempTable.name{i}], Cycles_ss, diffs)
                    end
                    
                end
                
                if p.plots(8)
                    figure()
                    rplots = tight_subplot(1,1,[.03 .03],[.1 .1],[.03 .03]);
                    axes(rplots(1))

                    polarplot(deg2rad(allPhase), allAmp, '*k')
                    title([metainfoTitle, ' All cells '])
                end

                
                % PLOT 3: Across Trial Averages
                if p.plots(3)
                    plot_summary1(allcs, z, allgoodcsLocs, [metainfoTitle, ' All Cells'], allCycles_ss, alldiffs)
                end
            end
        end
    end
end
