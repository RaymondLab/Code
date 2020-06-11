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
frCalc = 3;

binSize = 50; % (ms)
kernel_sd = .01; % Seconds
bin_ifr = .02; % Seconds

% 3 Riciprical interval Method
fr_thresh = 500;

% EXPERIMENTAL CONDITIONS
condition    = 'csNOcs_B'; % NOcsNOcs, csNOcs, 2csNOcs, csNOcs_B
stimType     = 'sine'; % sine, step
expmtFreq    = .5;
learningType = 'x0'; % VOR, OKR, x0, x2 

% PLOTTING CHOICES
PLOT_1 = 0; % Sanity Check Plot
PLOT_2 = 0; % All Channels Plot
PLOT_3 = 1; % Final Average plots
PLOT_4 = 0; % Individual Example Plots
PLOT_5 = 0; % Visualize Relationship between CS, Ephys, and Firing Rate


%% SELECT THE DATA THAT YOU ARE INTERESTED IN
tempTable = dataTable;
tempTable(~isnan(tempTable.maxRemoved),:) = []; % Bad Files

tempTable(~contains(tempTable.sineStep, {stimType}),:) = [];
tempTable(~contains(tempTable.learningType, {learningType}),:) = [];
tempTable(~(tempTable.freq == expmtFreq),:) = [];
tempTable(~(tempTable.maxSortedCS == 1 | tempTable.jenrSortedCS),:) = [];
disp(['Files Found: ', num2str(height(tempTable))]);

%% PREALLOCATE
alldiffs = [];
alldiffPercent = [];
allgoodcsLocs = [];
allcs = [];
allDeltas = [];
ss_times_diff_all = [];
allCycles_ss = [];
csLocFilename = ['CSLocations_csNOcs_', stimType,'_', learningType, '_', num2str(expmtFreq), '.mat'];

%% Main Loop
for i = 1:height(tempTable)
    disp(tempTable.name(i))
    metainfoTitle = [tempTable.name{i}, ' | ',condition, ' | ', stimType, ' | ', learningType, ' | ', num2str(expmtFreq), ' | '];
    
    %% Open the File
    renamedFile = strrep(tempTable.name{i}, '.', '_');
    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
    load(fullfile(expmtRow(1).folder, expmtRow(1).name));
    recData = behaviorEphysAligned;
    
    %% Get parameters
    sr_e = recData(10).samplerate;
    cycleLen_e = sr_e * (1/expmtFreq);
    cycleTime_e = 0:1/sr_e:(cycleLen_e-1)/sr_e;
    segTime_e = dattime(recData(10));
    startpt_e = findstartpt(recData, 10, learningType, expmtFreq);

    sr_b = recData(7).samplerate;
    cycleLen_b = sr_b * (1/expmtFreq);
    cycleTime_b = 0:1/500:(cycleLen_b-1)/500;
    startpt_b = findstartpt(recData, 7, learningType, expmtFreq);
    
    %% MAKE matrixes
    % cs Matrix
    csLocs = zeros(length(recData(10).data),1);
    recData(9).data(recData(9).data < 0) = [];
    for k = 1:length(recData(9).data)
        csLocs(round(recData(9).data(k)*sr_e)) = 1;
    end
    [cycleMat_cs, cycleMean_cs] = VOR_breakTrace(cycleLen_e, startpt_e, csLocs);
    
    % head and target matrix
    [cycleMat_tVel, cycleMean_tVel] = VOR_breakTrace(cycleLen_b, startpt_b, recData(7).data);
    [cycleMat_hVel, cycleMean_hVel] = VOR_breakTrace(cycleLen_b, startpt_b, recData(5).data);

    %% PRE PROCESS DATA
    
    % A:  Remove Complex Spikes from Simple Spike Data
    CS_removal_range = .002; % ms
    removed_A = 0;
    for j = 1:length(recData(9).data)
        deltas = abs(recData(8).data - recData(9).data(j));
        recData(8).data(deltas < CS_removal_range) = [];
        removed_A = removed_A + sum(deltas < CS_removal_range);
    end    
    disp(['Removed_A: ', num2str(removed_A), ' / ', num2str(length(recData(8).data))])
    
    
    % B:  Remove Complex Spike Spikelets from Simple Spike Data
    post_CS_removal_window = .005; % ms
    removed_B = 0;
    for j = 1:length(recData(9).data)
        deltas = recData(8).data - recData(9).data(j);
        recData(8).data(deltas < post_CS_removal_window & deltas > 0) = [];
        deltas(deltas < 0) = [];
        removed_B = removed_B + sum(deltas < post_CS_removal_window);
    end  
    disp(['Removed_B: ', num2str(removed_B), ' / ', num2str(length(recData(8).data))])
%     
    % C:  Remove Simple Spikes that are too close together
    SS_interval_minimum = .002;
    ss_times_diff = diff(recData(8).data);
    ss_times_diff_all = [ss_times_diff_all; ss_times_diff];
%     figure()
%     histogram(ss_times_diff, 1000);
    recData(8).data([false; ss_times_diff < SS_interval_minimum]) = [];
    removed_C = sum(ss_times_diff < SS_interval_minimum);
    disp(['Removed_C: ', num2str(removed_C), ' / ', num2str(length(recData(8).data))])
    
    totalRemoved = removed_A+removed_B+removed_C;
    disp(['Total Removed: ', num2str(totalRemoved)])
    percentRemoved = round(totalRemoved/length(recData(8).data)*1000)/10;
    disp(['Percent Removed: ', num2str(percentRemoved), '%'])
       
    %% MAKE ss continuous firing rate

    % Spike Density Function Method
    if frCalc == 1
        segment_ssfr = plotSpikeDensityfunction(recData(8).data, kernel_sd);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_e, startpt_e, segment_ssfr);
        bin_size_e = 1;
        
    % Instantaneous Firing Rate Method
    elseif frCalc == 2
        binned = zeros(round(recData(8).data(end)*sr_e),1);
        for x = 1:length(recData(8).data)
            binned(round(recData(8).data(x)*sr_e)) = 1;
        end
        
        bin_size_e = sr_e * bin_ifr;
        segment_ssfr = mean(vec2mat(binned, bin_size_e), 2);
        cycleLen_ss = floor(cycleLen_e/bin_size_e);
        startpnt_ss = floor(startpt_e/bin_size_e);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_ss, startpnt_ss, segment_ssfr);
        
%         figure(1); hold on
%         plot(cycleTime_ss, (cycleMean_ss/(bin_size_e/sr_e)), 'k')
%         plot(cycleTime_ss, (cycleMean_ss/(bin_size_e/sr_e))+std(cycleMat_ss), ':k')
%         plot(cycleTime_ss, (cycleMean_ss/(bin_size_e/sr_e))-std(cycleMat_ss), ':k')

        % Reciprocol Interval Method S. G. Lisberger and T. A. Pavelko 1986
    elseif frCalc == 3
        bin_size_e = 1;
        segment_ssfr = nan(length(recData(8).data),1);
        
        ssIntervals = [nan; recData(8).data(2:end) - recData(8).data(1:end-1)];
        ssTimesAndIntervals = [recData(8).data ssIntervals];
        
        timeofSecondSpike = ssTimesAndIntervals(2,1);
        ephysStartingIndx = round((timeofSecondSpike - recData(10).tstart) * sr_e);
        ssIndex = 2;
        
        for w = ephysStartingIndx:length(recData(10).data)
            if ssIndex > size(ssTimesAndIntervals, 1)
                break
            end
            
            if  (w / sr_e) - ssTimesAndIntervals(ssIndex, 1) < ssTimesAndIntervals(ssIndex, 2)
                segment_ssfr(w) = 1/ssTimesAndIntervals(ssIndex, 2);
            else
                segment_ssfr(w) = 1/ssTimesAndIntervals(ssIndex+1, 2);
            end
            
            % Update ssIndex when your ephys location is passed the next
            % spike
            if w / sr_e > ssTimesAndIntervals(ssIndex, 1)
                ssIndex = ssIndex + 1;
            end 
        end
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_e, startpt_e, segment_ssfr);
    end
    segTime_ssfr = linspace(0,recData(8).data(end), length(segment_ssfr));
    segLength_ss = length(segment_ssfr);
    cycleTime_ss = linspace(0, 1/expmtFreq, length(cycleMean_ss));

    
    
    baselineWindow_samples = sr_e * 10; % seconds
    movingMean = movmean(segment_ssfr, baselineWindow_samples);
    
%     figure();
%     plot(segTime_ssfr, segment_ssfr, 'c'); hold on
%     plot(segTime_ssfr, segment_ssfr-movingMean, 'm');
%     figure();
%     plot(movingMean);
%     segTime_ssfr = segTime_ssfr - movingMean';
    
    %% PLOT 5: FR versus Ephys and spike locations
    if PLOT_5
        figure('Position', [2 557 958 439])
        FREphys = tight_subplot(2,1,[.05 .01],[.03 .03],[.01 .01]);
        axes(FREphys(1));
        plot(segTime_ssfr, segment_ssfr)
        if ~isempty(recData(9).data)
            vline(recData(9).data);
        end
        axes(FREphys(2));
        plot(segTime_e, recData(10).data)
        if ~isempty(recData(9).data)
            vline(recData(9).data);
        end
        linkaxes(FREphys, 'x');
    end
    
    
    %% PLOT Summary 1: Sanity Check
    if PLOT_1
        figure('Position', [2 557 958 439])
        overviewPlot = tight_subplot(2,3,[.05 .01],[.03 .03],[.01 .01]);
        
        axes(overviewPlot(1));
        plot(segTime_ssfr, segment_ssfr);
        xlim([0 10]);
        yticks([]);
        title('Cont. Firing Rate: Segment')

        axes(overviewPlot(6));
        plot(cycleTime_e, cycleMat_ss'); hold on
        plot(cycleTime_e, cycleMean_ss, 'k', 'LineWidth', 5);
        title('Cont. Firing Rate: Cycles');
        stdev = nanstd(segment_ssfr);

        thresh = stdev*5 + nanmean(segment_ssfr);
        mad = nanmedian(abs(segment_ssfr - nanmedian(segment_ssfr)))*20+ nanmedian(segment_ssfr);
        hline(500)
        %ylim([0 mad*1.75])
        %yticks([]);
%         figure()
%         hist(segment_ssfr, 100)
%         xlim([0 500])

        axes(overviewPlot(3));
        btimeVec = dattime(recData(1,7));
        plot(cycleTime_b, cycleMean_tVel, 'r'); hold on
        plot(cycleTime_b, cycleMean_hVel, 'b'); 
        yticks([]);
        title('Stim')
        legend('T Vel', 'H Vel')

        axes(overviewPlot(2));
        plot(dattime(recData(10)), recData(10).data)
        vline(recData(8).data(50:53))
        xlim([recData(8).data(50) recData(8).data(53)])
        yticks([]);
        title('Simple Spikes')
        try
            axes(overviewPlot(5));
            plot(dattime(recData(10)), recData(1,10).data)
            vline(recData(1,9).data(1:4))
            xlim([recData(1,9).data(1) recData(1,9).data(4)])
            yticks([]);
            title('Complex Spikes')
        catch
        end
        
        axes(overviewPlot(4));
        title(tempTable.name(i))      
        text(1,9, ['Align Val: ', num2str(tempTable.maxAlignVal(i))] )
        text(1,8, ['Sample Start Point Ephys: ', num2str(startpt_e)])
        text(1,7, ['Sample Start Point Behav: ', num2str(startpt_b)])
        xlim([0 10])
        ylim([0 10])
    end
    
    
    %% PLOT Summary 2: All Channels
    if PLOT_2
        figure('Position', [962 32 958 964])
        ephysPlot = tight_subplot(length(recData),1,[.03 .03],[.03 .03],[.03 .03]);
        for j = 1:length(recData)
            
            try
                cycleLen_e = (recData(j).samplerate) * 1/expmtFreq;
                startpt_e = 1;
                [cycleMat, cycleMean] = VOR_breakTrace(cycleLen_e, startpt_e, recData(j).data);
            catch
            end
            
            axes(ephysPlot(j))
            
            try
                segTime_ssfr = dattime(recData(1,j));
                plot(segTime_ssfr, recData(j).data)
                title(recData(j).chanlabel)
            catch
            end
            
            if j == 1
                title([tempTable.name(i) recData(j).chanlabel])
            end
        end
    end
    
    
    %% FIND appropriate Cycles
    
    cycleLen_bin = floor(cycleLen_e/bin_size_e);
    % First x% of cycle
    csWindow_no = 1:(sr_e * .201);
    csWindowN1 = (sr_e * .201):(cycleLen_e/2);
    csWindowN2 = 1:(cycleLen_e/2);

    % 300ms window
    ssWindow_e = .3 * sr_e; 
    ssWindow_bin = floor(ssWindow_e/bin_size_e);
    conds = [];
    
    switch condition
        case 'csNOcs'
            % Condition 1: 1 cs in 200-1000ms
            conds(:,1) = sum(cycleMat_cs(:,csWindowN1),2);
            conds(:,1) = conds(:,1) == 1;
            % Condition 2: NO cs in 0-200ms
            conds(:,2)  = ~any(cycleMat_cs(:,csWindow_no),2);
            % Condition 3: NO cs in 0-1000ms of next cycle
            conds(:,3)  = ~any(cycleMat_cs(:,csWindowN2),2);
            conds(:,3)  = [conds(2:end,3); 0];
            
        case 'NOcsNOcs'
            % Condition 1: NO cs in 0-1000ms 
            conds(:,1) = ~any(cycleMat_cs(:,csWindowN2),2);
            % Condition 2: NO cs in 0-1000ms of next cycle
            conds(:,2) = [conds(2:end,1); 0];
            
        case '2csNOcs'
            % Condition 1: 2 cs in 200-1000ms
            conds(:,1) = sum(cycleMat_cs(:,csWindowN1),2);
            conds(:,1) = conds(:,1) == 2;
            % Condition 2: NO cs in 0-200ms
            conds(:,2)  = ~any(cycleMat_cs(:,csWindow_no),2);
            % Condition 3: NO cs in 0-1000ms of next cycle
            conds(:,3)  = ~any(cycleMat_cs(:,csWindowN2),2);
            conds(:,3)  = [conds(2:end,3); 0];
            
        case 'csNOcs_B'
            % Condition 1: 1 cs in 0-300ms
            csWindow_good = floor((sr_e * 1.8):(sr_e * 1.8));
            conds(:,1) = sum(cycleMat_cs(:,csWindow_good),2);
            conds(:,1) = conds(:,1) == 1;
            % Condition 2: NO cs in 0-200ms
            %csWindow_bad = 1:min(csWindow_good);
            %conds(:,2)  = ~any(cycleMat_cs(:,csWindow_bad),2);
            % Condition 3: NO cs in 0-300ms of next cycle
            conds(:,2)  = ~any(cycleMat_cs(:,csWindow_good),2);
            conds(:,2)  = [conds(2:end,2); 0];
    end
    
    disp(find(~any(~conds,2)))
    goodCycles = ~any(~conds,2);
    
    
    for k = 1:min(size(cycleMat_cs, 1), size(cycleMat_ss, 1))-1
        if goodCycles(k)
            switch condition
                case 'NOcsNOcs'
                    if exist(fullfile(expmtDataFolder, csLocFilename), 'file')
                        load(fullfile(expmtDataFolder, csLocFilename))
                        csLoc_cycle = randsample(allgoodcsLocs, 1);
                    else
                        error('csNOcs file not found. Run csNOcs to generate pseudo Locations')
                    end
                    
                otherwise
                    csLoc_cycle = find(cycleMat_cs(k,min(csWindow_good):end), 1);
                    csLoc_cycle = csLoc_cycle+(min(csWindow_good)-1);
            end
            
            csLoc_cycle_bin = floor(csLoc_cycle/bin_size_e);
            csLoc_seg = (k-1)*cycleLen_e+csLoc_cycle+startpt_e-1;
            ssLoc_seg = floor(csLoc_seg/bin_size_e);
            try
            ssChunkA  = segment_ssfr((ssLoc_seg-ssWindow_bin):(ssLoc_seg+ssWindow_bin));
            ssChunkB  = segment_ssfr((ssLoc_seg+cycleLen_bin-ssWindow_bin):(ssLoc_seg+cycleLen_bin+ssWindow_bin));
            ssChunkDiff = ssChunkB - ssChunkA;
            chunkTime = linspace(max(csWindow_no)/sr_e, max(csWindowN1)/sr_e, length(ssChunkA));
            catch
                continue
            end

            %% PLOT individual examples
            if PLOT_4
                figure()
                cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);


                axes(cycleExample(1));
                plot(cycleTime_b, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
                plot(cycleTime_b, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
                vline(csLoc_cycle/sr_e, '-k')
                vline((csLoc_cycle/sr_e)-ssWindow_e/sr_e, '--k')
                vline((csLoc_cycle/sr_e)+ssWindow_e/sr_e, '--k')
                xticks([])
                yticks([])
                hline(0, ':k')
                title(tempTable.name(i))
                legend({'Target Vel', 'Head Vel'})

                % Whole cycle sub-figure
                axes(cycleExample(2));
                plot(cycleTime_ss, cycleMat_ss(k  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                plot(cycleTime_ss, cycleMat_ss(k+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
                vline(csLoc_cycle/sr_e, '-k')
                vline((csLoc_cycle/sr_e)-ssWindow_e/sr_e, '--k')
                vline((csLoc_cycle/sr_e)+ssWindow_e/sr_e, '--k')
                yticks([])
                hline(0, ':k')
                legend({'Cycle N', 'Cycle N+1'})
                title('CS -> !CS Cycles')
                text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(k)])

                % 601ms window sub-figure
                axes(cycleExample(3));
                plot( chunkTime, ssChunkA, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                plot( chunkTime, ssChunkB, 'Color', [0, 0.5, 0], 'LineWidth', 2);

                title('600ms window around CS')
                xticks([])
                hline(0, ':k')
                vline(mean(xlim), 'k')

                % Difference sub-figure
                axes(cycleExample(4));
                ssChunkDiff = ssChunkB - ssChunkA;
                plot( chunkTime, ssChunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
                plot( chunkTime, ssChunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');

                title('Cycle N+1 - Cycle N')
                hline(0, ':k')
                vline(mean(xlim), 'k')
            end
                    
            %% Retain important values
            alldiffs(end+1,:) = ssChunkDiff;
            allgoodcsLocs(end+1) = csLoc_cycle;

        end
 
    end
    allcs = [allcs, find(nansum(cycleMat_cs))]; 
    
    allCycles_ss = [allCycles_ss; cycleMat_ss];
end

%% PLOT Summary 3: Across Trial Averages
if PLOT_3

    figure()
    Summary = tight_subplot(3,1,[.03 .03],[.03 .03],[.03 .03]);

    % Stim, and CSs
    axes(Summary(1))
    histogram(allcs/sr_e, linspace(0,max(cycleTime_b), 50), 'FaceColor', 'k'); hold on
    histogram(allgoodcsLocs/sr_e, linspace(0,max(cycleTime_b), 50), 'FaceColor', 'c');
    yyaxis right 
    plot(cycleTime_b, nanmean(cycleMat_tVel), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2); hold on
    plot(cycleTime_b, nanmean(cycleMat_hVel), 'Color', [0, 0.4470, 0.7410] , 'LineWidth', 2);
    title([metainfoTitle(12:end)])
    legend('Binned CS: All', 'Binned CS: Relevant', 'T Vel', 'H Vel')
    xlim([0 max(cycleTime_b)])
    xticklabels(xticks)
        
    % Simple Spike Firing
    axes(Summary(2)); hold on
    plot(cycleTime_ss, mean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
    ylim([30 110])
    % good in cycle N
    rectangle('Position',[min(csWindow_good)/sr_e,mean(allCycles_ss(:)),(max(csWindow_good)-min(csWindow_good))/sr_e,max(ylim)], ...
              'FaceColor',[.85 .85 .95], 'EdgeColor', [.85 .85 .95])
    % bad in cycle N
%     rectangle('Position',[min(csWindow_bad)/sr_e,mean(allCycles_ss(:)),(max(csWindow_bad)-min(csWindow_bad))/sr_e,max(ylim)], ...
%               'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
    % Bad in cycle 2
    rectangle('Position',[min(csWindow_good)/sr_e,min(ylim),(max(csWindow_good)-min(csWindow_good))/sr_e,abs(mean(allCycles_ss(:))-min(ylim))], ...
              'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
      
    plot(cycleTime_ss, mean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
    hline(mean(allCycles_ss(:)), ':k');
    legend('Average ss firing rate: All cycles in All Segements')
    xticklabels(xticks)
    
    % Average of Differences
    axes(Summary(3)); hold on
    plot((1:((ssWindow_bin*2)+1))/sr_e, nanmean(alldiffs), 'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
    legend('Average Cycle ss Firing Rate Difference')
    xlim([0 length(ssChunkA)/sr_e])
    ylim([-100 100])
    hline(0, ':k')
    vline(mean(xlim), ':k');
    vline(mean(xlim)-.120, ':k');
    xticklabels(xticks)


end

%% Extra Saving
switch condition
    case 'csNOcs'
    save(fullfile(expmtDataFolder, csLocFilename), 'allgoodcsLocs');
end
