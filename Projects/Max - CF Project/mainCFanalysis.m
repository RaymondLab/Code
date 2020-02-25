function [ss_times_diff, chunkDiffs, csLoc_cycle, allcs, cycleMat_ss, z, csInfo] = mainCFanalysis(segData, segInfo, p, expmtFreq, learningType, condition)


%% Get Useful values
z.sr_b = segData(7).samplerate;
z.segTime_b = dattime(segData(7));

z.sr_e = segData(10).samplerate;
z.segTime_e = dattime(segData(10));
z.segLen_s = max(z.segTime_e);

switch segInfo.sineStep{:}
    case 'sine'
        z.cycleLen_e = z.sr_e * (1/expmtFreq);
        z.startpt_e = findstartpt(segData, 10, learningType, expmtFreq);
        
        z.cycleLen_b = z.sr_b * (1/expmtFreq);
        z.startpt_b = findstartpt(segData, 7, learningType, expmtFreq);
    case 'step'

        lowLocs = segData(5).data < -5;
        negStepStarts = find(diff(lowLocs) == 1);
        z.cycleLen_b = 1096;
        z.startpt_b = negStepStarts(1) - 50;
        if z.startpt_b <= 0 
            z.startpt_b = negStepStarts(2) - 50;
        end
        
        z.cycleLen_e = z.cycleLen_b * (z.sr_e / z.sr_b);
        
        z.startpt_e = z.startpt_b * (z.sr_e / z.sr_b);
end

z.cycleTime_e = 0:1/z.sr_e:(z.cycleLen_e-1)/z.sr_e;
z.cycleTime_b = 0:1/z.sr_b:(z.cycleLen_b-1)/z.sr_b;
z.cycleLen_sec =  z.cycleLen_e / z.sr_e;

%% MAKE matrixes
% cs Matrix
csLocs = zeros(length(segData(10).data),1);
segData(9).data(segData(9).data < 0) = [];
for k = 1:length(segData(9).data)
    csLocs(round(segData(9).data(k)*z.sr_e)) = 1;
end
[z.cycleMat_cs, z.cycleMean_cs] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, csLocs);

% head and target matrix
[z.cycleMat_tVel, z.cycleMean_tVel] = VOR_breakTrace(z.cycleLen_b, z.startpt_b, segData(7).data);
[z.cycleMat_hVel, z.cycleMean_hVel] = VOR_breakTrace(z.cycleLen_b, z.startpt_b, segData(5).data);

%% PRE PROCESS DATA
removed_A = 0;
removed_B = 0;
removed_C = 0;

% A:  Remove Complex Spikes from Simple Spike Data
if p.preProcess(1)
    CS_removal_range = .002; % ms
    
    for j = 1:length(segData(9).data)
        deltas = abs(segData(8).data - segData(9).data(j));
        segData(8).data(deltas < CS_removal_range) = [];
        removed_A = removed_A + sum(deltas < CS_removal_range);
    end
    disp(['     Removed_A: ', num2str(removed_A), ' / ', num2str(length(segData(8).data))])
end

% B:  Remove Complex Spike Spikelets from Simple Spike Data
if p.preProcess(2)
    post_CS_removal_window = .005; % ms
    
    for j = 1:length(segData(9).data)
        deltas = segData(8).data - segData(9).data(j);
        segData(8).data(deltas < post_CS_removal_window & deltas > 0) = [];
        deltas(deltas < 0) = [];
        removed_B = removed_B + sum(deltas < post_CS_removal_window);
    end
    disp(['     Removed_B: ', num2str(removed_B), ' / ', num2str(length(segData(8).data))])
end

% C:  Remove Simple Spikes that are too close together
if p.preProcess(3)
    SS_interval_minimum = .002;
    
    ss_times_diff = diff(segData(8).data);
    segData(8).data([false; ss_times_diff < SS_interval_minimum]) = [];
    removed_C = sum(ss_times_diff < SS_interval_minimum);
    disp(['     Removed_C: ', num2str(removed_C), ' / ', num2str(length(segData(8).data))])
end

totalRemoved = removed_A+removed_B+removed_C;
percentRemoved = round(totalRemoved/length(segData(8).data)*1000)/10;
disp(['     Removed: ', num2str(totalRemoved), ' | ', num2str(percentRemoved), '%'])

%% MAKE ss continuous firing rate

switch p.ss_fr_calc
    case 'spikeDensityFunction'
        segment_ssfr = calc_spikeDensityFunction(segData(8).data, kernel_sd, z.sr_e);
        [cycleMat_ss, z.cycleMean_ss] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, segment_ssfr);
        z.bin_size_e = 1;
        
    case 'InstFiringRate'
        binned = zeros(round(segData(8).data(end)*z.sr_e),1);
        for x = 1:length(segData(8).data)
            binned(round(segData(8).data(x)*z.sr_e)) = 1;
        end
        
        z.bin_size_e = z.sr_e * bin_ifr;
        segment_ssfr = mean(vec2mat(binned, z.bin_size_e), 2);
        z.cycleLen_ss = floor(z.cycleLen_e/z.bin_size_e);
        z.startpnt_ss = floor(z.startpt_e/z.bin_size_e);
        [cycleMat_ss, z.cycleMean_ss] = VOR_breakTrace(cycleLen_ss, startpnt_ss, segment_ssfr);
        
    case 'RecipInterval'
        segment_ssfr = calc_recipInterval(segData(8).data, length(segData(10).data), z.sr_e);
        [cycleMat_ss, z.cycleMean_ss] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, segment_ssfr);
        z.bin_size_e = 1;
end

z.segTime_ssfr = linspace(0,segData(8).data(end), length(segment_ssfr));
z.segLength_ss = length(segment_ssfr);
z.cycleTime_ss = linspace(0, z.cycleLen_e/z.sr_e, length(z.cycleMean_ss));
[z.ssfr_amp, z.ssfr_phase] = fit_sineWave(segment_ssfr(z.startpt_e:end), z.sr_e, 1/(z.cycleLen_e/z.sr_e));


% PLOT 1: Single File Sanity check
if p.plots(1)
    plot_singleFileSanityCheck(segData, z, segInfo, segment_ssfr, p, cycleMat_ss, z.cycleMean_ss)
end

% PLOT 2: All Channels
if p.plots(2)
    plot_allChanOverview(segData, segInfo, z)
end

% PLOT 5: FR & Ephys & Spike Locations
if p.plots(5)
    plot_ephysFrCsOverview(segData, z, segment_ssfr)
end

%% Organize important CS information

% Update CS times to reflect their time relative to the calculated adjusted
% segment 'start' time'
for f = 1:length(segData(9).data)
    
    csInfo(f).timeAbs_sec = segData(9).data(f);
    csInfo(f).timeRel2Mat_sec = segData(9).data(f) - (z.startpt_e/z.sr_e);
    csInfo(f).timeRel2Cycle_sec = mod(csInfo(f).timeRel2Mat_sec, z.cycleLen_sec);

    csInfo(f).cycleNum = ceil(csInfo(f).timeRel2Mat_sec / z.cycleLen_sec);
    
    % remove CS that are before the start of cycle 1
    if csInfo(f).cycleNum < 1
        csInfo(f).cycleNum = nan;
        csInfo(f).usable = 0;
    % remove CS that are in last cycle or later
    elseif csInfo(f).cycleNum == size(cycleMat_ss,1)
        csInfo(f).usable = 0;
    elseif csInfo(f).cycleNum > size(cycleMat_ss,1)
        csInfo(f).cycleNum = nan;
        csInfo(f).usable = 0;
    else
        csInfo(f).usable = 1;
    end
    
    if csInfo(f).timeAbs_sec > z.segLen_s
        csInfo(f).usable = 0;
    end

end

%% FIND appropriate Cycles & complex spikes
switch condition
    case 'csNOcs'
        window = [.2 1];
        [csInfo, z] = t2t_csNOcs(csInfo, z, window);

    case 'NOcsNOcs'
        %[goodCycles, goodCS, z] = t2t_NOcsNOcs(segData(9).data, z.cycleMat_cs, z); % TODO

    case '2csNOcs'
        whichSpike = 1;
        [csInfo, z] = t2t_2csNOcs(segData(9).data, z.cycleMat_cs, z, whichSpike);

    case 'csNOcs_B' % Variable Window
        window = [.075 .2];
        [csInfo, z] = t2t_csNOcs_B(segData(9).data, z.cycleMat_cs, z, window);

    case 'allcs'
        csInfo = ones(1, length(csTimes));
end

%% Find Chunk Difference
windowSize = .6;
[chunkAs, chunkBs, chunkDiffs] = t2t_ExtractChunks(csInfo, segment_ssfr, z, windowSize);

plot_individualExampleCheck(chunkAs, chunkBs, chunkDiffs, segData, csInfo, z, windowSize)

z.chunkTime = linspace(0, windowSize, size(chunkDiffs, 1));

goodcsInfo = csInfo(csInfo(:,1) == 1,:);

% PLOT individual examples
for i = 1:size(chunkDiffs,2)
    if p.plots(4)
        plot_individualExamples(z, goodcsInfo(i,3), windowSize/2, segInfo, cycleMat_ss, goodcsInfo(i,4), chunkAs(:,i), chunkBs(:,i), chunkDiffs(:,i))
    end
end

%% Retain important values
csLoc_cycle = goodcsInfo(:,3);
allcs = csInfo(:,3);

%% Extra Saving
% switch condition
%     case 'csNOcs'
%         save(fullfile(p.expmtDataFolder, p.csLocFilename), 'allgoodcsLocs');
% end