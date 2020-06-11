function [goodCycles, goodCS, z] = t2t_2csNOcs(csTimes, cycleMat_cs, z, whichSpike)


%% Find Good Cycles/Trials 

% Condition 1: 1 cs in 200-1000ms
z.csWindow_good = (z.sr_e * .201):(z.cycleLen_e/2);
conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
conds(:,1) = conds(:,1) == 2;

% Condition 2: NO cs in 0-200ms
z.csWindow_bad = 1:(z.sr_e * .201);
conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);

% Condition 3: NO cs in 0-1000ms of next cycle
z.csWindow_bad2 = 1:(z.cycleLen_e/2);
conds(:,3)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
conds(:,3)  = [conds(2:end,3); 0];

disp(find(~any(~conds,2)));
goodCycles = ~any(~conds,2);


%% Find Good CS
cycleCSCount = sum(cycleMat_cs,2);
goodCS = zeros(1,length(csTimes));

for i = 1:length(goodCycles)
    if goodCycles(i)
        fff = sum(cycleCSCount(1:max(i-1,1)));
        goodCS(fff+whichSpike) = 1;
    end
end

end