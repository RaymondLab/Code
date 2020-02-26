function [csInfo, z] = t2t_csNOcs(csInfo, z, window)

z.csWindow_good = window;
z.csWindow_bad = [0 window(1)];
z.csWindow_bad2 = window;

%% Find Good Cycles/Trials 
for i = 1:length(csInfo)
    
    currentCycle = csInfo(i).cycleNum;
    if ~csInfo(i).usable
        continue
    end
    
    % CONDITION 1: Good Spike cannot take place before the min(window)
    if csInfo(i).timeRel2Cycle_sec < window(1)
        csInfo(i).usable = 0;
        
        % CONDITION 1a: All other spikes in this cycle are invalid
        if size([csInfo(find([csInfo.cycleNum] == currentCycle))], 2) > 1
            relSpikes = find([csInfo.cycleNum] == currentCycle);
            for j = relSpikes
                csInfo(j).usable = 0;
            end
        end
        
        continue
    end
    
    % CONDITION 2: Good Spike cannot take place after the max(window)
    if csInfo(i).timeRel2Cycle_sec > window(2)
        csInfo(i).usable = 0;
        continue
    end
    
    % CONDITION 3: Good Spikes cannot have a spike(s) in the 'window' in the following trial
    if size([csInfo(find([csInfo.cycleNum] == currentCycle+1))], 2) > 0
        relSpikes = find([csInfo.cycleNum] == currentCycle+1);
        for j = relSpikes
            if csInfo(j).timeRel2Cycle_sec > window(1) && csInfo(j).timeRel2Cycle_sec < window(2)
                csInfo(i).usable = 0;
                continue
            end
        end
    end
    
    % CONDITION 4: There can only be one good spike in the current window 
    if size([csInfo(find([csInfo.cycleNum] == currentCycle))], 2) > 1
        relSpikes = find([csInfo.cycleNum] == currentCycle);
        for j = relSpikes(2:end)
            if csInfo(j).timeRel2Cycle_sec > window(1) && csInfo(j).timeRel2Cycle_sec < window(2)
                csInfo(i).usable = 0;
                continue
            end
        end
    end
end
