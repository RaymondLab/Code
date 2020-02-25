function [goodCycles, goodCS, z] = t2t_NOcsNOcs(csTimes, cycleMat_cs, z)


%% Find Good Cycles/Trials 
% Condition 1: NO cs in 0-1000ms
z.csWindow_bad = 1:(z.sr_e * 1);
conds(:,1) = ~any(cycleMat_cs(:,z.csWindow_bad),2);

% Condition 2: NO cs in 0-1000ms of next cycle
conds(:,2) = [conds(2:end,1); 0];
disp(find(~any(~conds,2)))
goodCycles = ~any(~conds,2);

disp(find(~any(~conds,2)));
goodCycles = ~any(~conds,2);


%% Find 'Good CS'
cycleCSCount = sum(cycleMat_cs,2);
goodCS = zeros(1,length(csTimes));

for i = 1:length(goodCycles)
    if goodCycles(i)
        fff = sum(cycleCSCount(1:max(i-1,1)));
        goodCS(fff+1) = 1;
    end
end

end