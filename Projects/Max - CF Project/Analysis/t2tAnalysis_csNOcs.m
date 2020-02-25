function [goodCycles, csLocs, z] = t2tAnalysis_csNOcs(z, p, cycleMat_cs, chunkLen)

% 300ms window
z.ssWindow_e = .3 * z.sr_e; 
conds = [];

%% Condition 1: 1 cs in 200-1000ms
z.csWindow_good = (z.sr_e * .201):(z.cycleLen_e/2);
conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
conds(:,1) = conds(:,1) == 1;

%% Condition 2: NO cs in 0-200ms
z.csWindow_bad = 1:(z.sr_e * .201);
conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);

%% Condition 3: NO cs in 0-1000ms of next cycle
z.csWindow_bad2 = 1:(z.cycleLen_e/2);
conds(:,3)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
conds(:,3)  = [conds(2:end,3); 0];



disp(find(~any(~conds,2)))
goodCycles = ~any(~conds,2);