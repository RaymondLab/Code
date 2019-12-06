%% Setup
clear;clc;%close all
try
[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';
catch
    [dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
    expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';
end

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\*']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];

%% Choose Parameters

% ss firing rate calculation
useSDF = 0;
kernel_sd = .03; % Seconds
bin_ifr = .05; % Seconds

% Pattern to look for
% NOcsNOcs, csNOcs, 2csNOcs
condition = 'csNOcs'; 
NOcsNOcs = 0;

PLOT_1 = 1; % Sanity Check Plot
PLOT_2 = 0; % All Channels Plot
PLOT_3 = 1; % Final Average plots
PLOT_4 = 0; % Individual Example Plots

%% Filter
tempTable = dataTable;

allFiles(~contains({allFiles.name}, {'aligned'})) = [];

stimType        = 'sine'; % sine, step
tempTable(~contains(tempTable.sineStep, {stimType}),:) = [];

expmtFreq       = .5;
tempTable(~(tempTable.freq == expmtFreq),:) = [];

learningType    = 'x2'; % VOR, OKR, x0, x2 
tempTable(~contains(tempTable.learningType, {learningType}),:) = [];

tempTable(~(tempTable.maxSortedCS == 1 | tempTable.jenrSortedCS),:) = [];
%tempTable(~(tempTable.maxSortedCS == 1),:) = [];
%tempTable(~(tempTable.jenrSortedCS),:) = [];

tempTable(~isnan(tempTable.maxRemoved),:) = [];
tempTable(contains(tempTable.name, {'el1219.0016'}),:) = [];

disp(['Files Found: ', num2str(height(tempTable))]);

%% 
alldiffs = [];
allgoodcsLocs = [];
allcs = [];
for i = 1:height(tempTable)
    disp(tempTable.name(i))
    %% Open the File
    renamedFile = strrep(tempTable.name{i}, '.', '_');
    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
    load(fullfile(expmtRow(1).folder, expmtRow(1).name));
    recData = behaviorEphysAligned;
    sr_e = recData(10).samplerate;
    sr_b = recData(7).samplerate;
    
    
    %% Make head and target matrix
    cycleLen_b = sr_b * (1/expmtFreq);
    startpt_b = findstartpt(recData, 7, learningType, expmtFreq);
    [cycleMat_tVel, cycleMean_tVel] = VOR_breakTrace(cycleLen_b, startpt_b, recData(7).data);
    [cycleMat_hVel, cycleMean_hVel] = VOR_breakTrace(cycleLen_b, startpt_b, recData(5).data);
    cycleTimeVec_b = 0:1/500:(cycleLen_b-1)/500;
    
    
    %% MAKE cs matrix
    csLocs = zeros(length(recData(10).data),1);
    recData(9).data(recData(9).data < 0) = [];

    for k = 1:length(recData(9).data)
        csLocs(round(recData(9).data(k)*sr_e)) = 1;
    end
    cycleLen_e = sr_e * (1/expmtFreq);
    %startpt_e = startpt_b * 100;
    startpt_e = findstartpt(recData, 10, learningType, expmtFreq);
    [cycleMat_cs, cycleMean_cs] = VOR_breakTrace(cycleLen_e, startpt_e, csLocs);
    cycleTime_e = 0:1/sr_e:(cycleLen_e-1)/sr_e;


    %% MAKE ss continuous firing rate

    % Spike Density Function
    if useSDF
        sdf = plotSpikeDensityfunction(recData(8).data, kernel_sd);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_e, startpt_e, sdf);
        segTime_ss = [0:1/sr_e:(length(sdf)-1)/sr_e]';
        segTime_ss = round(segTime_ss*100000)/100000;
        bin_size = 1;
        segment_ss = sdf;
    % Instantaneous Firing Rate
    else
        binned = zeros(round(recData(8).data(end)*sr_e),1);
        for x = 1:length(recData(8).data)
            binned(round(recData(8).data(x)*sr_e)) = 1;
        end
        
        bin_size = sr_e * bin_ifr;
        ifr = [];
        for x = 1:bin_size:length(binned)
            endPnt = min([(x+bin_size-1) length(binned)]);
            ifr(end+1) = sum( binned(x:endPnt) );
        end        
        cycleLen_ifr = cycleLen_e/bin_size;
        startpnt_ifr = startpt_e/bin_size;
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_ifr, startpnt_ifr, ifr);
        cycleTime_ifr = linspace(0, 1/expmtFreq, length(cycleMean_ss));
        
        figure(); hold on
        plot(cycleTime_ifr, cycleMean_ss/(bin_size/sr_e), 'k')
        plot(cycleTime_ifr, (cycleMean_ss/(bin_size/sr_e))+std(cycleMat_ss), ':k')
        plot(cycleTime_ifr, (cycleMean_ss/(bin_size/sr_e))-std(cycleMat_ss), ':k')
        segTime_ss = linspace(0,recData(8).data(end), length(ifr));
        cycleTime_e = linspace(0,recData(8).data(end), cycleLen_ifr);
        segment_ss = ifr;

    end

    
    %% PLOT Summary 1: Sanity Check
    if PLOT_1
        figure('Position', [2 557 958 439])
        overviewPlot = tight_subplot(2,3,[.05 .01],[.03 .03],[.01 .01]);
        
        axes(overviewPlot(1));
        plot(segTime_ss, segment_ss);
        xlim([0 10]);
        yticks([]);
        title('Cont. Firing Rate: Segment')

        axes(overviewPlot(6));
        plot(cycleTime_e, cycleMat_ss'); hold on
        plot(cycleTime_e, cycleMean_ss, 'k', 'LineWidth', 5);
        title('Cont. Firing Rate: Cycles');
        yticks([]);

        axes(overviewPlot(3));
        btimeVec = dattime(recData(1,7));
        plot(cycleTimeVec_b, cycleMean_tVel, 'r'); hold on
        plot(cycleTimeVec_b, cycleMean_hVel, 'b'); 
        yticks([]);
        title('Stim')
        legend('T Vel', 'H Vel')

        axes(overviewPlot(2));
        plot(dattime(recData(10)), recData(10).data)
        vline(recData(8).data(50:53))
        xlim([recData(8).data(50) recData(8).data(53)])
        yticks([]);
        title('Simple Spikes')

        axes(overviewPlot(5));
        plot(dattime(recData(10)), recData(1,10).data)
        vline(recData(1,9).data(1:4))
        xlim([recData(1,9).data(1) recData(1,9).data(4)])
        yticks([]);
        title('Complex Spikes')
        
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
                segTime_ss = dattime(recData(1,j));
                plot(segTime_ss, recData(j).data)
                title(recData(j).chanlabel)
            catch
            end
            
            if j == 1
                title([tempTable.name(i) recData(j).chanlabel])
            end
        end
    end
    
    
    %% FIND appropriate Cycles

    % First x% of cycle
    csWindow_no = 1:(sr_e * .201);
    csWindowN1 = (sr_e * .201):(cycleLen_e/2);
    csWindowN2 = 1:(cycleLen_e/2);

    % 300ms window
    ssWindow = .3 * sr_e; 
    ssWindow = round(ssWindow/bin_size);
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
            
        case 'NocsNOcs'
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
    end

    disp(find(~any(~conds,2)))
    goodCycles = ~any(~conds,2);


    for k = 1:min(size(cycleMat_cs, 1), size(cycleMat_ss, 1))-1
        if goodCycles(k)

            csLoc_cycle = find(cycleMat_cs(k,:), 1);
            csLoc_cycle = round(csLoc_cycle/bin_size);

            csLoc_seg = (k-1)*cycleLen_e+csLoc_cycle+startpt_e-1;
            ssLog_seg = csLoc_seg/100;
            ssChunkA  = segment_ss((ssLog_seg-ssWindow):(ssLog_seg+ssWindow));
            ssChunkB  = segment_ss((ssLog_seg+cycleLen_e-ssWindow):(ssLog_seg+cycleLen_e+ssWindow));
            ssChunkDiff = ssChunkB - ssChunkA;

            %% PLOT individual examples
            if PLOT_4
                figure()
                cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);


                axes(cycleExample(1));
                plot(cycleTimeVec_b, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
                plot(cycleTimeVec_b, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
                vline(csLoc_cycle/sr_e, '-k')
                vline((csLoc_cycle/sr_e)-ssWindow/sr_e, '--k')
                vline((csLoc_cycle/sr_e)+ssWindow/sr_e, '--k')
                xticks([])
                yticks([])
                hline(0, ':k')
                title(tempTable.name(i))
                legend({'Target Vel', 'Head Vel'})

                % Whole cycle sub-figure
                axes(cycleExample(2));
                plot(cycleTime_e, cycleMat_ss(k  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                plot(cycleTime_e, cycleMat_ss(k+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
                vline(csLoc_cycle/sr_e, '-k')
                vline((csLoc_cycle/sr_e)-ssWindow/sr_e, '--k')
                vline((csLoc_cycle/sr_e)+ssWindow/sr_e, '--k')
                yticks([])
                hline(0, ':k')
                legend({'Cycle N', 'Cycle N+1'})
                title('CS -> !CS Cycles')
                text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(k)])

                % 601ms window sub-figure
                axes(cycleExample(3));
                plot( (1:((ssWindow*2)+1))/sr_e, ssChunkA, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                plot( (1:((ssWindow*2)+1))/sr_e, ssChunkB, 'Color', [0, 0.5, 0], 'LineWidth', 2);

                title('600ms window around CS')
                xlim([0 length(ssChunkA)/sr_e])
                ylim([-6 6]);
                yticks([])
                xticks([])
                hline(0, ':k')
                vline(mean(xlim), 'k')

                % Difference sub-figure
                axes(cycleExample(4));
                ssChunkDiff = ssChunkB - ssChunkA;
                plot( (1:((ssWindow*2)+1))/sr_e, ssChunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
                plot( (1:((ssWindow*2)+1))/sr_e, ssChunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');


                title('Cycle N+1 - Cycle N')
                xlim([0 length(ssChunkA)/sr_e])
                ylim([-6 6]);
                yticks([])
                hline(0, ':k')
                vline(mean(xlim), 'k')
            end


            %% Retain important values
            alldiffs(end+1,:) = ssChunkDiff;
            allgoodcsLocs(end+1) = csLoc_cycle;

        end

    end
    allcs = [allcs, find(nansum(cycleMat_cs))]; 
    
    
end

%% PLOT Summary 3: Across Trial Averages
if PLOT_3

    % PLOT all cs
    figure()
    csSummary = tight_subplot(2,1,[.01 .01],[.03 .03],[.01 .01]);
    axes(csSummary(1));
    plot(cycleTimeVec_b, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
    plot(cycleTimeVec_b, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
    legend('T Vel', 'H Vel')
    %vline(allcs/sr_e, 'k');
    yticks([])
    xticks([])
    title(tempTable.name(i))
    axes(csSummary(2));
    hist(allcs/sr_e, 40)
    yticks([])
    
    
    % PLOT Good CS Locations
    figure()
    csSummary = tight_subplot(2,1,[.01 .01],[.03 .03],[.01 .01]);
    axes(csSummary(1));
    plot(cycleTimeVec_b, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
    plot(cycleTimeVec_b, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
    legend('T Vel', 'H Vel')
    ylim([-20 20])
    yticks([])
    xticks([])
    vline(allgoodcsLocs/sr_e, 'k')
    hline(0, ':k')
    title('good cs locations relative to cycle')
    axes(csSummary(2));
    hist(allgoodcsLocs/sr_e, 20)
    yticks([])
    xlim([0 max(cycleTimeVec_b)])

    
    % PLOT Average Differences
    figure()
    plot((1:((ssWindow*2)+1))/sr_e, alldiffs'); hold on
    plot((1:((ssWindow*2)+1))/sr_e, nanmean(alldiffs), 'k', 'LineWidth', 3)
    hline(0, 'k')
    ylim([-40 40])
    xlim([0 length(ssChunkA)/sr_e])
    title('CS+!CS ss Firing Rate Differences')
    vline(mean(xlim), 'k');
    vline(mean(xlim)-.120, 'k');
end
