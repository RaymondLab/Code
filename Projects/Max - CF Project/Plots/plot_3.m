function plot_3(z)

figure()
Summary = tight_subplot(3,1,[.03 .03],[.03 .03],[.03 .03]);

% Stim, and CSs
axes(Summary(1))
histogram(allcs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'k'); hold on
histogram(allgoodcsLocs/z.sr_e, linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'c');
yyaxis right
plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2); hold on
plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'Color', [0, 0.4470, 0.7410] , 'LineWidth', 2);
title([metainfoTitle, ' All Cells'])
legend('Binned CS: All', 'Binned CS: Relevant', 'T Vel', 'H Vel')
xlim([0 max(z.cycleTime_b)])
xticklabels(xticks)

% Simple Spike Firing
axes(Summary(2)); hold on
plot(z.cycleTime_ss, nanmean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
ylim([30 110])
% good in cycle N
rectangle('Position',[min(z.csWindow_good)/z.sr_e,nanmean(allCycles_ss(:)),(max(z.csWindow_good)-min(z.csWindow_good))/z.sr_e,max(ylim)], ...
        'FaceColor',[.85 .85 .95], 'EdgeColor', [.85 .85 .95])
% bad in cycle N
rectangle('Position',[min(z.csWindow_bad)/z.sr_e,nanmean(allCycles_ss(:)),(max(z.csWindow_bad)-min(z.csWindow_bad))/z.sr_e,max(ylim)], ...
        'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
% Bad in cycle 2
rectangle('Position',[min(z.csWindow_bad2)/z.sr_e,min(ylim),(max(z.csWindow_bad2)-min(z.csWindow_bad2))/z.sr_e,abs(nanmean(allCycles_ss(:))-min(ylim))], ...
        'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])

plot(z.cycleTime_ss, nanmean(allCycles_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
hline(nanmean(allCycles_ss(:)), ':k');
legend('Average ss firing rate: All cycles in All Segements')
xticklabels(xticks)

% Average of Differences
axes(Summary(3)); hold on
plot((1:((z.ssWindow_bin*2)+1))/z.sr_e, nanmean(alldiffs), 'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
legend('Average Cycle ss Firing Rate Difference')
xlim([0 z.chunkLength/z.sr_e])
ylim([-100 100])
hline(0, ':k')
vline(mean(xlim), ':k');
vline(mean(xlim)-.120, ':k');
xticklabels(xticks)