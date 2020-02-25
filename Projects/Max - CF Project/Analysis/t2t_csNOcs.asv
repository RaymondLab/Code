function [csInfo, z] = t2t_csNOcs(csInfo, z, window)


%% Find Good Cycles/Trials 
for i = 1:length(csInfo)
    
    if ~csInfo(i).usable
        continue
    end
    
    % CONDITION 1: Spike cannot take place before the min(window)
    if csInfo(i).timeRel2Cycle_sec < window(1)
        csInfo(i).usable = 0;
        continue       
    end
    
    % CONDITION 2: Spike cannot take place after the max(window)
    if csInfo(i).timeRel2Cycle_sec > window(2)
        csInfo(i).usable = 0;
        continue
    end
end

for i = 1:length(csInfo)

    if ~csInfo(i).usable
        continue
    end
    
    % CONDITION 3: Spike cannot exist in the 'window' in the following trial
    currentCycle = csInfo(i).cycleNum;
    if any([csInfo(find([csInfo.cycleNum] == currentCycle+1)).usable])
        csInfo(i).usable = 0;
        continue
    end

    
    % CONDITION 4: There can only be one good spike in the current window 
    if sum([csInfo(find([csInfo.cycleNum] == currentCycle)).usable]) > 1
        multiGood = find([csInfo.cycleNum] == currentCycle);
        for j = multiGood
            csInfo(j).usable = 0;
        end
        continue
    end
    
    % CONDITION 5: There can not be a spike in the same cycle, but before current window
    if size([csInfo(find([csInfo.cycleNum] == currentCycle))], 2) > 1
        
        multiSpike = find([csInfo.cycleNum] == currentCycle);
        for j = multiGood
            if csInfo(j).timeRel2Cycle_sec < window(1)
                csInfo(j).usable = 0;
            end
        end
    end
end
    





% Condition 1
z.csWindow_good = (z.sr_e * window(1)):(z.sr_e * window(2));
conds(:,1) = sum(z.cycleMat_cs(:,z.csWindow_good),2);
conds(:,1) = conds(:,1) == 1;

% Condition 2
z.csWindow_bad = 1:min(z.csWindow_good);
conds(:,2)  = ~any(z.cycleMat_cs(:,z.csWindow_bad),2);

% Condition 3
z.csWindow_bad2 = z.csWindow_good;
conds(:,3)  = ~any(z.cycleMat_cs(:,z.csWindow_bad2),2);
conds(:,3)  = [conds(2:end,3); 0];

disp(find(~any(~conds,2)));
goodCycles = find(~any(~conds,2));

%% Mark which CS are relavent 
goodCSs = [];
for i = 1:length(goodCycles)
    % Use only the first spike ( we know it will be the first spike
    % given our window parameters )
    goodCSs(end+1) = find([csInfo(:).cycleLoc] == goodCycles(i), 1);
end

for i = 1:length(csInfo)
    if i ~= goodCSs
        csInfo(i).usable = 0;
    end 
end