function [goodCycles, goodCS, z] = t2t_csNOcs_B(csTimes, cycleMat_cs, z, window)


%% Find Good Cycles/Trials 

% Condition 1
z.csWindow_good = (z.sr_e * window(1)):(z.sr_e * window(2));
conds(:,1) = sum(cycleMat_cs(:,z.csWindow_good),2);
conds(:,1) = conds(:,1) == 1;

% Condition 2
z.csWindow_bad = 1:min(z.csWindow_good);
conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad),2);

% Condition 3
z.csWindow_bad2 = z.csWindow_good;
conds(:,2)  = ~any(cycleMat_cs(:,z.csWindow_bad2),2);
conds(:,2)  = [conds(2:end,2); 0];

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