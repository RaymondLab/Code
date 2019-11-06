%% Setup
clear;clc;close all
[dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\*']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];

%% Choose Parameters and filter 

tempTable = dataTable;
alldiffs = [];
allgoodcsLocs = [];
allcs = [];


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
PLOT_Summary1 = 0;
PLOT_Summary2 = 0;
PLOT_Summary3 = 1;
individualPlot = 0;
allFiles(~contains({allFiles.name}, {'aligned'})) = [];


%% 
for i = 1:height(tempTable)
    disp(tempTable.name(i))
    %% Open the File
    renamedFile = strrep(tempTable.name{i}, '.', '_');
    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
    fullFileName = fullfile(expmtRow(1).folder, expmtRow(1).name);
    load(fullFileName)
    
    
    %% MAKE cs matrix
    csLocs = zeros(length(behaviorEphysAligned(10).data),1);
    behaviorEphysAligned(9).data(behaviorEphysAligned(9).data < 0) = [];

    for k = 1:length(behaviorEphysAligned(9).data)
        csLocs(round(behaviorEphysAligned(9).data(k)*behaviorEphysAligned(10).samplerate)) = 1;
    end
    cycleLength = (behaviorEphysAligned(10).samplerate) * 1/expmtFreq;
    startpt = findstartpt(behaviorEphysAligned, 10, learningType, expmtFreq);
    [cycleMat_cs, cycleMean_cs] = VOR_breakTrace(cycleLength, startpt, csLocs);
    
    
    %% Make head and target matrix
    cycleLengthB = (behaviorEphysAligned(7).samplerate) * 1/expmtFreq;
    startptB = findstartpt(behaviorEphysAligned, 7, learningType, expmtFreq);
    [cycleMat_tVel, cycleMean_tVel] = VOR_breakTrace(cycleLengthB, startptB, behaviorEphysAligned(7).data);
    [cycleMat_hVel, cycleMean_hVel] = VOR_breakTrace(cycleLengthB, startptB, behaviorEphysAligned(5).data);
    cycleTimeVecB = 0:1/500:(cycleLengthB-1)/500;
    
    
    %% MAKE ss continuous firing rate
    kernel_sd = .05;
    sdf = plotSpikeDensityfunction(behaviorEphysAligned(8).data, kernel_sd);
    [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLength, startpt, sdf);
    cycleLen = size(cycleMat_ss,2);
    cycleTimeVec = 0:1/50000:(cycleLen-1)/50000;
    
    
    %% PLOT Summary 1: Sanity Check
    if PLOT_Summary1
        figure('Position', [2 557 958 439])
        overviewPlot = tight_subplot(2,3,[.05 .01],[.03 .03],[.01 .01]);
        
        timeVec = [0:1/50000:(length(sdf)-1)/50000]';
        timeVec = round(timeVec*100000)/100000;

        axes(overviewPlot(1));
        plot(timeVec, sdf);
        xlim([0 10]);
        yticks([]);
        title('Cont. Firing Rate: Segment')

        axes(overviewPlot(4));
        plot(cycleTimeVec, cycleMat_ss'); hold on
        plot(cycleTimeVec, cycleMean_ss, 'k', 'LineWidth', 5);
        title('Cont. Firing Rate: Cycles');
        yticks([]);

        axes(overviewPlot(3));
        timeVec = dattime(behaviorEphysAligned(1,7));
        plot(timeVec, behaviorEphysAligned(1,7).data, 'r'); hold on
        plot(timeVec, behaviorEphysAligned(1,5).data, 'b');
        xlim([0 8])
        ylim([-80 80])
        yticks([]);
        title('Stim')
        legend('T Vel', 'H Vel')

        axes(overviewPlot(2));
        plot(dattime(behaviorEphysAligned(10)), behaviorEphysAligned(10).data)
        vline(behaviorEphysAligned(8).data(50:53))
        xlim([behaviorEphysAligned(8).data(50) behaviorEphysAligned(8).data(53)])
        yticks([]);
        title('Simple Spikes')

        axes(overviewPlot(5));
        plot(dattime(behaviorEphysAligned(10)), behaviorEphysAligned(1,10).data)
        vline(behaviorEphysAligned(1,9).data(1:4))
        xlim([behaviorEphysAligned(1,9).data(1) behaviorEphysAligned(1,9).data(4)])
        yticks([]);
        title('Complex Spikes')
        
        axes(overviewPlot(6));
        title(tempTable.name(i))
        text(1,9, ['Align Val: ', num2str(tempTable.maxAlignVal(i))] )
        xlim([0 10])
        ylim([0 10])
    end
    
    
    %% PLOT Summary 2: All Channels
    if PLOT_Summary2
        figure('Position', [962 32 958 964])
        ephysPlot = tight_subplot(length(behaviorEphysAligned),1,[.03 .03],[.03 .03],[.03 .03]);
        for j = 1:length(behaviorEphysAligned)
            
            try
                cycleLength = (behaviorEphysAligned(j).samplerate) * 1/expmtFreq;
                startpt = 1;
                [cycleMat, cycleMean] = VOR_breakTrace(cycleLength, startpt, behaviorEphysAligned(j).data);
            catch
            end
            
            axes(ephysPlot(j))
            
            try
                timeVec = dattime(behaviorEphysAligned(1,j));
                plot(timeVec, behaviorEphysAligned(j).data)
                title(behaviorEphysAligned(j).chanlabel)
            catch
            end
            
            if j == 1
                title([tempTable.name(i) behaviorEphysAligned(j).chanlabel])
            end
        end
    end
    
    
    %% PLOT 120ms difference
    
    % First x% of cycle
    csWindow_no = 1:(50000 * .201);
    csWindowN1 = (50000 * .201):(cycleLength/2);
    csWindowN2 = 1:(cycleLength/2);

    % 300ms window
    ssWindow = .3 * 50000; 

    for k = 1:min(size(cycleMat_cs, 1), size(cycleMat_ss, 1))-1
        
        % If your cycle contains 1 CS and in the proper location
        if sum(cycleMat_cs(k,csWindowN1)) == 1 && sum(cycleMat_cs(k,csWindow_no)) == 0
            
            % If your NEXT cycle does NOT contain CS in proper location
            if ~any(cycleMat_cs(k+1,csWindowN2))
                csLoc = find(cycleMat_cs(k,:), 1);
                disp(k)
                
                if csLoc < max(ssWindow)
                    vecSecondHalf = cycleMat_ss(k,1:(csLoc+ssWindow));
                    prevCycleChunkLength = ((ssWindow*2 + 1) - length(vecSecondHalf))-1;
                    vecFirstHalf = cycleMat_ss(k-1, end-prevCycleChunkLength:end);
                    ssChunkA = [vecFirstHalf vecSecondHalf];
                    
                    vecSecondHalf = cycleMat_ss(k+1,1:(csLoc+ssWindow));
                    prevCycleChunkLength = ((ssWindow*2 + 1) - length(vecSecondHalf))-1;
                    vecFirstHalf = cycleMat_ss(k, end-prevCycleChunkLength:end);
                    ssChunkB = [vecFirstHalf vecSecondHalf];
                else
                    ssChunkA = cycleMat_ss(k,csLoc-(ssWindow):csLoc+(ssWindow));
                    ssChunkB = cycleMat_ss(k+1,csLoc-(ssWindow):csLoc+(ssWindow));
                end
                
                ssChunkDiff = ssChunkB - ssChunkA;

                %% PLOT individual examples
                if individualPlot
                    figure()
                    cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);


                    axes(cycleExample(1));
                    plot(cycleTimeVecB, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
                    plot(cycleTimeVecB, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
                    vline(csLoc/50000, '-k')
                    vline((csLoc/50000)-ssWindow/50000, '--k')
                    vline((csLoc/50000)+ssWindow/50000, '--k')
                    xticks([])
                    yticks([])
                    hline(0, ':k')
                    title(tempTable.name(i))
                    legend({'Target Vel', 'Head Vel'})

                    % Whole cycle sub-figure
                    axes(cycleExample(2));
                    plot(cycleTimeVec, cycleMat_ss(k  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                    plot(cycleTimeVec, cycleMat_ss(k+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
                    vline(csLoc/50000, '-k')
                    vline((csLoc/50000)-ssWindow/50000, '--k')
                    vline((csLoc/50000)+ssWindow/50000, '--k')
                    yticks([])
                    hline(0, ':k')
                    legend({'Cycle N', 'Cycle N+1'})
                    title('CS -> !CS Cycles')
                    text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(k)])

                    % 601ms window sub-figure
                    axes(cycleExample(3));
                    plot( (1:((ssWindow*2)+1))/50000, ssChunkA, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
                    plot( (1:((ssWindow*2)+1))/50000, ssChunkB, 'Color', [0, 0.5, 0], 'LineWidth', 2);

                    title('600ms window around CS')
                    xlim([0 length(ssChunkA)/50000])
                    ylim([-60 60]);
                    yticks([])
                    xticks([])
                    hline(0, ':k')
                    vline(mean(xlim), 'k')

                    % Difference sub-figure
                    axes(cycleExample(4));
                    ssChunkDiff = ssChunkB - ssChunkA;
                    plot( (1:((ssWindow*2)+1))/50000, ssChunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
                    plot( (1:((ssWindow*2)+1))/50000, ssChunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');


                    title('Cycle N+1 - Cycle N')
                    xlim([0 length(ssChunkA)/50000])
                    ylim([-60 60]);
                    yticks([])
                    hline(0, ':k')
                    vline(mean(xlim), 'k')
                end
                
                
                %% Retain important values
                alldiffs(end+1,:) = ssChunkDiff;
                allgoodcsLocs(end+1) = csLoc;
                

            end
        end
        
    end
    allcs = [allcs, find(nansum(cycleMat_cs))];

    
end

%% PLOT Summary 3: Across Trial Averages
if PLOT_Summary3
    % PLOT Average Differences
    figure()
    plot((1:((ssWindow*2)+1))/50000, alldiffs'); hold on
    plot((1:((ssWindow*2)+1))/50000, nanmean(alldiffs), 'k', 'LineWidth', 3)
    hline(0, '--k')
    ylim([-40 40])
    xlim([0 length(ssChunkA)/50000])
    title('CS+!CS ss Firing Rate Differences')
    vline(mean(xlim), '--k')
    vline(mean(xlim)-.120, '--k')


    % PLOT Good CS Locations
    figure()
    csSummary = tight_subplot(2,1,[.01 .01],[.03 .03],[.01 .01]);
    axes(csSummary(1));
    plot(cycleTimeVecB, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
    plot(cycleTimeVecB, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
    legend('T Vel', 'H Vel')
    ylim([-20 20])
    yticks([])
    xticks([])
    vline(allgoodcsLocs/50000, 'k')
    hline(0, ':k')
    title('good cs locations relative to cycle')
    axes(csSummary(2));
    hist(allgoodcsLocs/50000, 20)
    yticks([])
    xlim([0 max(cycleTimeVecB)])

    % PLOT all cs
    figure()
    csSummary = tight_subplot(2,1,[.01 .01],[.03 .03],[.01 .01]);
    axes(csSummary(1));
    plot(cycleTimeVecB, nanmean(cycleMat_tVel), 'r', 'LineWidth', 2); hold on
    plot(cycleTimeVecB, nanmean(cycleMat_hVel), 'b', 'LineWidth', 2);
    legend('T Vel', 'H Vel')
    %vline(allcs/50000, 'k');
    yticks([])
    xticks([])
    title(tempTable.name(i))
    axes(csSummary(2));
    hist(allcs/50000, 20)
    yticks([])
end
