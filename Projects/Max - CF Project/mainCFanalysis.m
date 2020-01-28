function [ss_times_diff, alldiffs, allgoodcsLocs, allcs, allCycles_ss, z] = mainCFanalysis(tableRow, allFiles, expmtFreq, learningType, condition, preProcess, ss_fr_calc, plots )

%% Open the File
renamedFile = strrep(tableRow.name, '.', '_');
expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
load(fullfile(expmtRow(1).folder, expmtRow(1).name));
recData = behaviorEphysAligned;

%% Get Useful values
z.sr_e = recData(10).samplerate;
z.cycleLen_e = z.sr_e * (1/expmtFreq);
z.cycleTime_e = 0:1/z.sr_e:(z.cycleLen_e-1)/z.sr_e;
z.segTime_e = dattime(recData(10));
z.startpt_e = findstartpt(recData, 10, learningType, expmtFreq);

z.sr_b = recData(7).samplerate;
z.cycleLen_b = z.sr_b * (1/expmtFreq);
z.cycleTime_b = 0:1/500:(z.cycleLen_b-1)/500;
z.startpt_b = findstartpt(recData, 7, learningType, expmtFreq);

%% MAKE matrixes
% cs Matrix
csLocs = zeros(length(recData(10).data),1);
recData(9).data(recData(9).data < 0) = [];
for k = 1:length(recData(9).data)
    csLocs(round(recData(9).data(k)*z.sr_e)) = 1;
end
[cycleMat_cs, cycleMean_cs] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, csLocs);

% head and target matrix
[z.cycleMat_tVel, z.cycleMean_tVel] = VOR_breakTrace(z.cycleLen_b, z.startpt_b, recData(7).data);
[z.cycleMat_hVel, z.cycleMean_hVel] = VOR_breakTrace(z.cycleLen_b, z.startpt_b, recData(5).data);

%% PRE PROCESS DATA
removed_A = 0;
removed_B = 0;
removed_C = 0;

% A:  Remove Complex Spikes from Simple Spike Data
if preProcess(1)
    CS_removal_range = .002; % ms
    
    for j = 1:length(recData(9).data)
        deltas = abs(recData(8).data - recData(9).data(j));
        recData(8).data(deltas < CS_removal_range) = [];
        removed_A = removed_A + sum(deltas < CS_removal_range);
    end
    disp(['     Removed_A: ', num2str(removed_A), ' / ', num2str(length(recData(8).data))])
end

% B:  Remove Complex Spike Spikelets from Simple Spike Data
if preProcess(2)
    post_CS_removal_window = .005; % ms
    
    for j = 1:length(recData(9).data)
        deltas = recData(8).data - recData(9).data(j);
        recData(8).data(deltas < post_CS_removal_window & deltas > 0) = [];
        deltas(deltas < 0) = [];
        removed_B = removed_B + sum(deltas < post_CS_removal_window);
    end
    disp(['     Removed_B: ', num2str(removed_B), ' / ', num2str(length(recData(8).data))])
end

% C:  Remove Simple Spikes that are too close together
if preProcess(3)
    SS_interval_minimum = .002;
    
    ss_times_diff = diff(recData(8).data);
    recData(8).data([false; ss_times_diff < SS_interval_minimum]) = [];
    removed_C = sum(ss_times_diff < SS_interval_minimum);
    disp(['     Removed_C: ', num2str(removed_C), ' / ', num2str(length(recData(8).data))])
end

totalRemoved = removed_A+removed_B+removed_C;
percentRemoved = round(totalRemoved/length(recData(8).data)*1000)/10;
disp(['     Removed: ', num2str(totalRemoved), ' | ', num2str(percentRemoved), '%'])

%% MAKE ss continuous firing rate

switch ss_fr_calc
    case 'spikeDensityFunction'
        segment_ssfr = plotSpikeDensityfunction(recData(8).data, kernel_sd);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, segment_ssfr);
        z.bin_size_e = 1;
        
    case 'InstFiringRate'
        binned = zeros(round(recData(8).data(end)*z.sr_e),1);
        for x = 1:length(recData(8).data)
            binned(round(recData(8).data(x)*z.sr_e)) = 1;
        end
        
        z.bin_size_e = z.sr_e * bin_ifr;
        segment_ssfr = mean(vec2mat(binned, z.bin_size_e), 2);
        z.cycleLen_ss = floor(z.cycleLen_e/z.bin_size_e);
        z.startpnt_ss = floor(z.startpt_e/z.bin_size_e);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(cycleLen_ss, startpnt_ss, segment_ssfr);
        
    case 'RecipInterval'
        tic
        z.bin_size_e = 1;
        segment_ssfr = nan(length(recData(10).data),1);
        
        data = recData(8).data;
        AAA = data(2:end) - data(1:end-1);
        BBB = AAA(1:end-1) - AAA(2:end);

        for w = 1:length(BBB)
            if BBB(w) > 0
                segment_ssfr(round(data(w+1)*z.sr_e:data(w+2)*z.sr_e)) = 1/AAA(w);
            else
                start = data(w+1)*z.sr_e;
                middle  = data(w+1)*z.sr_e + AAA(w)*z.sr_e;
                stop = data(w+2)*z.sr_e;
                
                segment_ssfr(round(start : middle)) = 1/AAA(w);
                segment_ssfr(round(middle+1 : stop)) = 1/AAA(w+1);
            end
        end
        
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, segment_ssfr);
end

z.segTime_ssfr = linspace(0,recData(8).data(end), length(segment_ssfr));
z.segLength_ss = length(segment_ssfr);
z.cycleTime_ss = linspace(0, 1/expmtFreq, length(cycleMean_ss));

%% PLOT 5: FR & Ephys & Spike Locations
if plots(5)
    figure('Position', [2 557 958 439])
    FREphys = tight_subplot(2,1,[.05 .01],[.03 .03],[.01 .01]);
    axes(FREphys(1));
    plot(z.segTime_ssfr, segment_ssfr)
    if ~isempty(recData(9).data)
        vline(recData(9).data);
    end
    axes(FREphys(2));
    plot(z.segTime_e, recData(10).data)
    if ~isempty(recData(9).data)
        vline(recData(9).data);
    end
    linkaxes(FREphys, 'x');
end

%% PLOT 1: Sanity Check
if plots(1)
    figure('Position', [2 557 958 439])
    overviewPlot = tight_subplot(2,3,[.05 .01],[.03 .03],[.01 .01]);
    
    axes(overviewPlot(1));
    plot(z.segTime_ssfr, segment_ssfr);
    xlim([0 10]);
    yticks([]);
    title('Cont. Firing Rate: Segment')
    
    axes(overviewPlot(6));
    plot(z.cycleTime_e, cycleMat_ss'); hold on
    plot(z.cycleTime_e, cycleMean_ss, 'k', 'LineWidth', 5);
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
    plot(z.cycleTime_b, z.cycleMean_tVel, 'r'); hold on
    plot(z.cycleTime_b, z.cycleMean_hVel, 'b');
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
    title(tableRow.name)
    text(1,9, ['Align Val: ', num2str(tableRow.maxAlignVal)] )
    text(1,8, ['Sample Start Point Ephys: ', num2str(z.startpt_e)])
    text(1,7, ['Sample Start Point Behav: ', num2str(z.startpt_b)])
    xlim([0 10])
    ylim([0 10])
end

%% PLOT 2: All Channels
if plots(2)
    figure('Position', [962 32 958 964])
    ephysPlot = tight_subplot(length(recData),1,[.03 .03],[.03 .03],[.03 .03]);
    for j = 1:length(recData)
        
        try
            z.cycleLen_e = (recData(j).samplerate) * 1/expmtFreq;
            z.startpt_e = 1;
            [cycleMat, cycleMean] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, recData(j).data);
        catch
        end
        
        axes(ephysPlot(j))
        
        try
            z.segTime_ssfr = dattime(recData(1,j));
            plot(z.segTime_ssfr, recData(j).data)
            title(recData(j).chanlabel)
        catch
        end
        
        if j == 1
            title([tableRow.name recData(j).chanlabel])
        end
    end
end

%% FIND appropriate Cycles

z.cycleLen_bin = floor(z.cycleLen_e/z.bin_size_e);

% Defaults
z.csWindow_good = (z.sr_e * .201):(z.cycleLen_e/2);
z.csWindow_bad = 1:(z.sr_e * .201);
z.csWindow_bad2 = 1:(z.cycleLen_e/2);

% 300ms window
ssWindow_e = .3 * z.sr_e; 
z.ssWindow_bin = floor(ssWindow_e/z.bin_size_e);
conds = [];

switch condition
    case 'csNOcs'
        % Condition 1: 1 cs in 200-1000ms
        conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
        conds(:,1) = conds(:,1) == 1;
        % Condition 2: NO cs in 0-200ms
        conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);
        % Condition 3: NO cs in 0-1000ms of next cycle
        conds(:,3)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
        conds(:,3)  = [conds(2:end,3); 0];

    case 'NOcsNOcs'
        % Condition 1: NO cs in 0-1000ms 
        conds(:,1) = ~any(cycleMat_cs(:,z.csWindow_bad),2);
        % Condition 2: NO cs in 0-1000ms of next cycle
        conds(:,2) = [conds(2:end,1); 0];

    case '2csNOcs'
        % Condition 1: 2 cs in 200-1000ms
        conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
        conds(:,1) = conds(:,1) == 2;
        % Condition 2: NO cs in 0-200ms
        conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);
        % Condition 3: NO cs in 0-1000ms of next cycle
        conds(:,3)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
        conds(:,3)  = [conds(2:end,3); 0];

    case 'csNOcs_B' % Variable. 
        % Condition 1
        z.csWindow_good = (z.sr_e * .075):(z.sr_e * .2);
        conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
        conds(:,1) = conds(:,1) == 1;
        % Condition 2
        z.csWindow_bad = 1:min(z.csWindow_good);
        conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);
        % Condition 3
        z.csWindow_bad2 = z.csWindow_good;
        conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
        conds(:,2)  = [conds(2:end,2); 0];
end
disp(find(~any(~conds,2)))
goodCycles = ~any(~conds,2);

alldiffs = [];
allgoodcsLocs = [];
allcs = [];
allCycles_ss = [];

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
                csLoc_cycle = find(cycleMat_cs(k,min(z.csWindow_good):end), 1);
                csLoc_cycle = csLoc_cycle+(min(z.csWindow_good)-1);
        end
        
        csLoc_cycle_bin = floor(csLoc_cycle/z.bin_size_e);
        csLoc_seg = (k-1)*z.cycleLen_e+csLoc_cycle+z.startpt_e-1;
        ssLoc_seg = floor(csLoc_seg/z.bin_size_e);
        try
            ssChunkA  = segment_ssfr((ssLoc_seg-z.ssWindow_bin):(ssLoc_seg+z.ssWindow_bin));
            ssChunkB  = segment_ssfr((ssLoc_seg+z.cycleLen_bin-z.ssWindow_bin):(ssLoc_seg+z.cycleLen_bin+z.ssWindow_bin));
            ssChunkDiff = ssChunkB - ssChunkA;
            z.chunkLength = length(ssChunkA);
            z.chunkTime = linspace(max(z.csWindow_bad)/z.sr_e, max(z.csWindow_good)/z.sr_e, z.chunkLength);
        catch
            continue
        end

        
        %% PLOT individual examples
        if plots(4)
            figure()
            cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);
            
            
            axes(cycleExample(1));
            plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'r', 'LineWidth', 2); hold on
            plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'b', 'LineWidth', 2);
            vline(csLoc_cycle/z.sr_e, '-k')
            vline((csLoc_cycle/z.sr_e)-ssWindow_e/z.sr_e, '--k')
            vline((csLoc_cycle/z.sr_e)+ssWindow_e/z.sr_e, '--k')
            xticks([])
            yticks([])
            hline(0, ':k')
            title(tableRow.name)
            legend({'Target Vel', 'Head Vel'})
            
            % Whole cycle sub-figure
            axes(cycleExample(2));
            plot(z.cycleTime_ss, cycleMat_ss(k  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
            plot(z.cycleTime_ss, cycleMat_ss(k+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
            vline(csLoc_cycle/z.sr_e, '-k')
            vline((csLoc_cycle/z.sr_e)-ssWindow_e/z.sr_e, '--k')
            vline((csLoc_cycle/z.sr_e)+ssWindow_e/z.sr_e, '--k')
            yticks([])
            hline(0, ':k')
            legend({'Cycle N', 'Cycle N+1'})
            title('CS -> !CS Cycles')
            text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(k)])
            
            % 601ms window sub-figure
            axes(cycleExample(3));
            plot( z.chunkTime, ssChunkA, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
            plot( z.chunkTime, ssChunkB, 'Color', [0, 0.5, 0], 'LineWidth', 2);
            
            title('600ms window around CS')
            xticks([])
            hline(0, ':k')
            vline(mean(xlim), 'k')
            
            % Difference sub-figure
            axes(cycleExample(4));
            ssChunkDiff = ssChunkB - ssChunkA;
            plot( z.chunkTime, ssChunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
            plot( z.chunkTime, ssChunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');
            
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

figure();
plot(cycleMat_ss'); hold on
plot(mean(cycleMat_ss), 'k', 'LineWidth', 2)
ylim([0 200])
allCycles_ss = [allCycles_ss; cycleMat_ss];






%% Extra Saving
% switch condition
%     case 'csNOcs'
%         save(fullfile(expmtDataFolder, csLocFilename), 'allgoodcsLocs');
% end