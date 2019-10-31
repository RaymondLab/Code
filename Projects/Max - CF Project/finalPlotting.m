%% Setup
clear;clc;close all
[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\*']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];

%% Choose Parameters and filter 

tempTable = dataTable;


stimType        = 'sine'; % sine, step
tempTable(~contains(tempTable.sineStep, {stimType}),:) = [];

expmtFreq       = .5;
tempTable(~(tempTable.freq == expmtFreq),:) = [];

learningType    = 'x2'; % VOR, OKR, x0, x2 
tempTable(~contains(tempTable.learningType, {learningType}),:) = [];

tempTable(~(tempTable.sortedCS == 1),:) = [];


disp(['Files Found: ', num2str(height(tempTable))]);
plotAllChans = 1;
allFiles(~contains({allFiles.name}, {'aligned'})) = [];

%% 
for i = 1:height(tempTable)
    %% Open the File
    renamedFile = strrep(tempTable.name{i}, '.', '_');
    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
    fullFileName = fullfile(expmtRow.folder, expmtRow.name);
    load(fullFileName)
    
    
    %% MAKE cs matrix
    csLocs = zeros(length(behaviorEphysAligned(10).data),1);
    for k = 1:length(behaviorEphysAligned(9).data)
        csLocs(round(behaviorEphysAligned(9).data(k)*behaviorEphysAligned(10).samplerate)) = 1;
    end
    cycleLength = (behaviorEphysAligned(10).samplerate) * 1/expmtFreq;
    startpt = findstartpt(behaviorEphysAligned, 10, learningType, expmtFreq);
    [cycleMat_cs, cycleMean_cs] = VOR_breakTrace(cycleLength, startpt, csLocs);

    
    %% MAKE ss continuous firing rate
    kernel_sd = .05;
    sdf = plotSpikeDensityfunction(behaviorEphysAligned(8).data, kernel_sd);
    [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLength, startpt, sdf);
    cycleLen = size(cycleMat_ss,2);
    cycleTimeVec = 0:1/50000:(cycleLen-1)/50000;
    
    
    %% PLOT ss continuous firing rate
    timeVec = [0:1/50000:(length(sdf)-1)/50000]';
    timeVec = round(timeVec*100000)/100000;
    figure();
    plot(timeVec, sdf)
    title([tempTable.name(i), 'Continuous Firing Rate: Whole Segment'])
    
    figure(); plot(cycleTimeVec, cycleMat_ss'); hold on
    plot(cycleTimeVec, cycleMean_ss, 'k', 'LineWidth', 5)
    title([tempTable.name(i), 'Continuous Firing Rate: Cycles'])
    
    
    %% PLOT Stim
    figure()
    timeVec = dattime(behaviorEphysAligned(1,7));
    plot(timeVec, behaviorEphysAligned(1,7).data, 'r'); hold on
    plot(timeVec, behaviorEphysAligned(1,5).data, 'b');
    xlim([0 8])
    ylim([-80 80])
    title([tempTable.name(i), 'Stim'])
    legend('T Vel', 'H Vel')
    
    
    %% PLOT each channel
    if plotAllChans
        figure()
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
            
            if j == 10
                figure()
                plot(timeVec, behaviorEphysAligned(1,10).data)
                vline(behaviorEphysAligned(1,8).data(50:100))
                xlim([behaviorEphysAligned(1,8).data(50) behaviorEphysAligned(1,8).data(100)])
                title([tempTable.name(i), 'Simple Spike Locations'])
            end
            if j == 10
                figure()
                plot(timeVec, behaviorEphysAligned(1,10).data)
                vline(behaviorEphysAligned(1,9).data)
                xlim([0 20])
                title([tempTable.name(i), ': Complex Spike Locations'])
            end
        end
    end
    
    %% PLOT 120ms difference
    

    % First 25% of cycle
    csWindow = 1: (.25 * cycleLen); 
    % 120ms window
    ssWindow = .120 * 50000; 

    for k = 1:size(cycleMat_ss, 1)-1
        
        % If your cycle contains 1 CS and in the proper location
        if sum(cycleMat_cs(k,csWindow)) == 1 %&& sum(cycleMat_cs(k,:)) == 1
            % If your NEXT cycle does NOT contain any CS
            if ~any(cycleMat_cs(k+1,:))
                csLoc = find(cycleMat_cs(k,csWindow));
                disp(k)
                
                if csLoc < max(ssWindow)
                    vecSecondHalf = cycleMat_ss(k,1:csLoc);
                    prevCycleChunkLength = (ssWindow - length(vecSecondHalf))-1;
                    vecFirstHalf = cycleMat_ss(k-1, end-prevCycleChunkLength:end);
                    ssChunkA = [vecFirstHalf vecSecondHalf];
                    
                    vecSecondHalf = cycleMat_ss(k+1,1:csLoc);
                    prevCycleChunkLength = (ssWindow - length(vecSecondHalf))-1;
                    vecFirstHalf = cycleMat_ss(k, end-prevCycleChunkLength:end);
                    ssChunkB = [vecFirstHalf vecSecondHalf];
                else
                    ssChunkA = cycleMat_ss(k,csLoc-(ssWindow-1):csLoc);
                    ssChunkB = cycleMat_ss(k+1,csLoc-(ssWindow-1):csLoc);
                end
                figure();
                plot(cycleTimeVec, cycleMat_ss(k  ,:), 'b'); hold on
                plot(cycleTimeVec, cycleMat_ss(k+1,:), 'r');
                vline(csLoc/50000, '-k')
                vline((csLoc/50000)-ssWindow/50000, '--k')
                legend({'Cycle N', 'Cycle N+1'})
                title([tempTable.name(i), ': CS -> !CS Cycles'])
                text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(k)])
                
                figure();
                plot( 1:ssWindow, ssChunkA, 'b'); hold on
                plot( 1:ssWindow, ssChunkB, 'r')
                legend({'Cycle N', 'Cycle N+1'})
                title([tempTable.name(i), '120ms Prior to CS'])
                text(3000,max(ylim)*.95, ['Cycle ', num2str(k)])
                
                
            end
        end
        
    end
    

end