%% SETUP
clear;clc;%close all
try
    [dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
catch
    [dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
end

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\**']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];

%% PARAMETERS

% SS FIRING RATE CALULATION
ss_fr_calc = 'RecipInterval'; % RecipInterval, InstFiringRate, spikeDensityFunction'

binSize = 50; % (ms)
kernel_sd = .01; % Seconds
bin_ifr = .02; % Seconds

% 3 Riciprical interval Method
fr_thresh = 500;

% EXPERIMENTAL CONDITIONS
condition    = {'csNOcs'}; %{'csNOcs', 'csNOcs_B', 'NOcsNOcs', '2csNOcs', 'allcs'};
stimType     = {'step'}; % 'sine', 'step'
expmtFreq    = [.5]; % .5, 1, 2, 5
stepType     = {'50msAccel_200msVel', '1000', '500', '250', '150', '80'}; % '50msAccel_200msVel', '1000', '500', '250', '150' '80'
learningType = {'x2', 'x0', 'OKR', 'VOR'};%, 'x0', 'OKR', 'VOR'};

% PLOTTING CHOICES
plots = [1, ... % Sanity Check Plot
         0, ... % All Channels Plot
         0, ... % Final Average plots
         0, ... % Individual Example Plots
         0, ... % Visualize Relationship between CS, Ephys, and Firing Rate
         0, ... % Same as 3, but for a single cell recording
         0, ... % radial plots for ss tuning checks
         0];    % radial plots for ss tuning checks ALL CELLS

% REMOVE NOT-RELAVANT FILES
dataTable(logical(dataTable.maxRemoved),:) = []; % Bad Files
dataTable(~(dataTable.sortedCS),:) = [];

% OTHER
preProcess = [1, 1, 1];

%% Loop through all combinations of parameters
for stimType_indx = 1:length(stimType)
    %for expmtFreq_indx = 1:length(expmtFreq)
    for expmtFreq_indx = 1:length(stepType)
        for condition_indx = 1:length(condition)
            for learningtype_indx = 1:length(learningType)
                
                %% SELECT THE DATA THAT YOU ARE INTERESTED IN
                tempTable = dataTable;
                tempTable(~contains(tempTable.sineStep, stimType(stimType_indx)),:) = [];
                tempTable(~contains(tempTable.learningType, learningType(learningtype_indx)),:) = [];
                
                if contains(stimType{stimType_indx}, 'sine')
                    tempTable(~(tempTable.freq == expmtFreq(expmtFreq_indx)),:) = [];
                    metainfoTitle = [' | ', stimType{stimType_indx}, ' | ', ...
                                    num2str(expmtFreq(expmtFreq_indx)), 'Hz | ', ...
                                    condition{condition_indx}, ' | ', ...
                                    learningType{learningtype_indx}, ' | '];
                                
                elseif contains(stimType{stimType_indx}, 'step')
                    
                    tempTable(~contains(tempTable.stepType, stepType(expmtFreq_indx)),:) = [];
                    
                    metainfoTitle = [' | ', stimType{stimType_indx}, ' | ', ...
                                    stepType(expmtFreq_indx), 'Hz | ', ...
                                    condition{condition_indx}, ' | ', ...
                                    learningType{learningtype_indx}, ' | '];
                end
                
                disp(metainfoTitle)
                disp(['Files Found: ', num2str(height(tempTable))]);
                
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
                csLocFilename = ['CSLocations_csNOcs_', stimType{:},'_', learningType{:}, '_', num2str(expmtFreq), '.mat'];
                
                %% LOOP THROUGH EACH FILE
                for i = 1:height(tempTable)
                    disp(tempTable.name{i})
                    [ss_times_diff, diffs, goodcsLocs, cs, Cycles_ss, z] = mainCFanalysis(tempTable(i,:), allFiles, ...
                                                    expmtFreq(expmtFreq_indx), ...
                                                    learningType{learningtype_indx}, ...
                                                    condition{condition_indx}, ...
                                                    preProcess, ss_fr_calc, plots, expmtDataFolder, csLocFilename );
                                                
                    ss_times_diff_all = [ss_times_diff_all; ss_times_diff];
                    alldiffs = [alldiffs; diffs];
                    allgoodcsLocs = [allgoodcsLocs goodcsLocs];
                    allcs = [allcs cs];
                    allCycles_ss = [allCycles_ss; Cycles_ss];
                    allPhase = [allPhase; z.ssfr_phase];
                    allAmp = [allAmp; z.ssfr_amp];
                    
                    %% PLOT Summary: Single Cell Averages
                    if plots(6)
                        figure()
                        Summary = tight_subplot(3,1,[.03 .03],[.03 .03],[.03 .03]);
                        
                        % Stim, and CSs
                        axes(Summary(1))
                        histogram(cs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'k'); hold on
                        histogram(goodcsLocs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'c');
                        yyaxis right
                        plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2); hold on
                        plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'Color', [0, 0.4470, 0.7410] , 'LineWidth', 2);
                        title([metainfoTitle, ' ', tempTable.name{i}])
                        legend('Binned CS: All', 'Binned CS: Relevant', 'T Vel', 'H Vel')
                        xlim([0 max(z.cycleTime_b)])
                        xticklabels(xticks)
                        
                        % Simple Spike Firing
                        axes(Summary(2)); hold on
                        plot(z.cycleTime_ss, nanmean(Cycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
                        ylim([30 110])
                        % good in cycle N
                        rectangle('Position',[min(z.csWindow_good)/z.sr_e,nanmean(Cycles_ss(:)),(max(z.csWindow_good)-min(z.csWindow_good))/z.sr_e,max(ylim)], ...
                            'FaceColor',[.85 .85 .95], 'EdgeColor', [.85 .85 .95])
                        % bad in cycle N
                        rectangle('Position',[min(z.csWindow_bad)/z.sr_e,nanmean(Cycles_ss(:)),(max(z.csWindow_bad)-min(z.csWindow_bad))/z.sr_e,max(ylim)], ...
                            'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
                        % Bad in cycle 2
                        rectangle('Position',[min(z.csWindow_bad2)/z.sr_e,min(ylim),(max(z.csWindow_bad2)-min(z.csWindow_bad2))/z.sr_e,abs(nanmean(Cycles_ss(:))-min(ylim))], ...
                            'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
                        
                        plot(z.cycleTime_ss, nanmean(Cycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
                        hline(nanmean(Cycles_ss(:)), ':k');
                        legend(['Average ss firing rate: All cycles (', num2str(size(Cycles_ss,1)), ') in Current Recording'])
                        xticklabels(xticks)
                        
                        % Average of Differences
                        axes(Summary(3)); hold on
                        
                        ylim([-100 100]);
                        hline(0, ':k');

                        legendText = ['Average Cycle ss fr Difference | ', num2str(size(diffs, 1)), ' Examples'];
                        yThing = (1:((z.ssWindow_bin*2)+1))/z.sr_e;
                        color = [0.4940, 0.1840, 0.5560];
                        
                        try
                            alldiffsMean = nanmean(alldiffs);
                            plot(yThing, alldiffsMean, 'Color', color, 'LineWidth', 1);
                            xlim([0 z.chunkLength/z.sr_e])
                        catch
                        end
                        vline(mean(xlim), ':k');
                        vline(mean(xlim)-.120, ':k');
                        xticklabels(xticks);
                        legend(legendText)
                        drawnow
                    end
                    
                end
                
                if plots(8)
                    figure()
                    rplots = tight_subplot(1,1,[.03 .03],[.1 .1],[.03 .03]);
                    axes(rplots(1))

                    polarplot(deg2rad(allPhase), allAmp, '*k')
                    title([metainfoTitle, ' All cells '])
                end

                
                %% PLOT 3: Across Trial Averages
                if plots(3)
                 
                    figure()
                    Summary = tight_subplot(3,1,[.03 .03],[.03 .03],[.03 .03]);
                    
                    % Stim, and CSs
                    axes(Summary(1))
                    histogram(allcs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'k'); hold on
                    histogram(allgoodcsLocs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'c');
                    yyaxis right
                    plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2); hold on
                    plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'Color', [0, 0.4470, 0.7410] , 'LineWidth', 2);
                    title([metainfoTitle, ' All Cells'])
                    legend('Binned CS: All', 'Binned CS: Relevant', 'T Vel', 'H Vel')
                    xlim([0 max(z.cycleTime_b)])
                    xticklabels(xticks)
                
                    % Simple Spike Firing
                    axes(Summary(2)); hold on
                    plot(z.cycleTime_ss, nanmean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
                    ylim([30 110])
                    % good in cycle N
                    rectangle('Position',[min(z.csWindow_good)/z.sr_e,nanmean(allCycles_ss(:)),(max(z.csWindow_good)-min(z.csWindow_good))/z.sr_e,max(ylim)], ...
                              'FaceColor',[.85 .85 .95], 'EdgeColor', [.85 .85 .95])
                    % bad in cycle N
                    rectangle('Position',[min(z.csWindow_bad)/z.sr_e,nanmean(allCycles_ss(:)),(max(z.csWindow_bad)-min(z.csWindow_bad))/z.sr_e,max(ylim)], ...
                              'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
                    % Bad in cycle 2
                    rectangle('Position',[min(z.csWindow_bad2)/z.sr_e,min(ylim),(max(z.csWindow_bad2)-min(z.csWindow_bad2))/z.sr_e,abs(nanmean(allCycles_ss(:))-min(ylim))], ...
                              'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
                
                    plot(z.cycleTime_ss, nanmean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
                    hline(nanmean(allCycles_ss(:)), ':k');
                    legend('Average ss firing rate: All cycles in All Segements')
                    xticklabels(xticks)
                
                    % Average of Differences
                    axes(Summary(3)); hold on
                    plot((1:((z.ssWindow_bin*2)+1))/z.sr_e, nanmean(alldiffs), 'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
                    legend('Average Cycle ss Firing Rate Difference')
                    xlim([0 z.chunkLength/z.sr_e])
                    ylim([-100 100])
                    hline(0, ':k')
                    vline(mean(xlim), ':k');
                    vline(mean(xlim)-.120, ':k');
                    xticklabels(xticks)
                
                end
            end
        end
    end
end
