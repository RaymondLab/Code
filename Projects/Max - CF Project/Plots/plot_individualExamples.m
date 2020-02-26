function plot_individualExamples(csInfo, z, segInfo)

%% Set up 
csLoc_cycle = csInfo.timeRel2Cycle_sec;
cycleNum = csInfo.cycleNum;

figure()
cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);

%% Fig A: Stim and CS location 
axes(cycleExample(1));
plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'r', 'LineWidth', 2); hold on
plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'b', 'LineWidth', 2);
vline(csLoc_cycle, '-k')
vline((csLoc_cycle)-(z.comparisonWindowSize/2), '--k')
vline((csLoc_cycle)+(z.comparisonWindowSize/2), '--k')
xticks([])
yticks([])
hline(0, ':k')
title(segInfo.name)
text(mean(xlim),max(ylim)*.95, [num2str(csInfo.timeAbs_sec), 's'])
legend({'Target Vel', 'Head Vel'})

%% Fig B: ss firing rate in cycle N and cycle N+1
axes(cycleExample(2));
plot(z.cycleTime_ss, z.cycleMat_ss(cycleNum  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
plot(z.cycleTime_ss, z.cycleMat_ss(cycleNum+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
vline(csLoc_cycle, '-k')
vline((csLoc_cycle)-(z.comparisonWindowSize/2), '--k')
vline((csLoc_cycle)+(z.comparisonWindowSize/2), '--k')
yticks([])
hline(0, ':k')
legend({'Cycle N', 'Cycle N+1'})
title('CS -> !CS Cycles')
text(mean(xlim),max(ylim)*.95, ['Cycle ', num2str(cycleNum)])

%% FIG C: 601ms window sub-figure
axes(cycleExample(3));
plot( z.chunkTime, csInfo.chunkA, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
plot( z.chunkTime, csInfo.chunkB, 'Color', [0, 0.5, 0], 'LineWidth', 2);

title('600ms window around CS')
xticks([])
hline(0, ':k')
vline(mean(xlim), 'k')

%% Fig D:  Difference sub-figure
axes(cycleExample(4));
plot( z.chunkTime, csInfo.chunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
plot( z.chunkTime, csInfo.chunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');

title('Cycle N+1 - Cycle N')
hline(0, ':k')
vline(mean(xlim), 'k')
vline(mean(xlim)-.12, 'k')
end