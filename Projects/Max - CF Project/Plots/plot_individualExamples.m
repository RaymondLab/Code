function plot_individualExamples(z, csLoc_cycle, ssWindow_e, segInfo, cycleMat_ss, k, ssChunkA, ssChunkB, ssChunkDiff)

figure()
cycleExample = tight_subplot(4,1,[.04 .03],[.03 .03],[.01 .01]);


axes(cycleExample(1));
plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'r', 'LineWidth', 2); hold on
plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'b', 'LineWidth', 2);
vline(csLoc_cycle, '-k')
vline((csLoc_cycle)-ssWindow_e, '--k')
vline((csLoc_cycle)+ssWindow_e, '--k')
xticks([])
yticks([])
hline(0, ':k')
title(segInfo.name)
legend({'Target Vel', 'Head Vel'})

% Whole cycle sub-figure
axes(cycleExample(2));
plot(z.cycleTime_ss, cycleMat_ss(k  ,:), 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 2); hold on
plot(z.cycleTime_ss, cycleMat_ss(k+1,:), 'Color', [0, 0.5, 0], 'LineWidth', 2);
vline(csLoc_cycle, '-k')
vline((csLoc_cycle)-ssWindow_e, '--k')
vline((csLoc_cycle)+ssWindow_e, '--k')
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
plot( z.chunkTime, ssChunkDiff, 'Color', [0.9100    0.4100    0.1700], 'LineWidth', 3); hold on
plot( z.chunkTime, ssChunkDiff, 'Color', [0, 0.5, 0], 'LineWidth', 3, 'LineStyle', '--');

title('Cycle N+1 - Cycle N')
hline(0, ':k')
vline(mean(xlim), 'k')
vline(mean(xlim)-.12, 'k')
end