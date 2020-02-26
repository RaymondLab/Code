function plot_summary1(csInfo, z, titlez)

%% Set up
csInfo_good = csInfo(logical([csInfo.usable]));
figure('Position', [2 42 958 1074])
Summary = tight_subplot(3,1,[.03 .03],[.03 .03],[.03 .03]);

%% FIG A: Stim, and CSs
axes(Summary(1))
histogram([csInfo.timeRel2Cycle_sec], linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'k'); hold on
histogram([csInfo_good.timeRel2Cycle_sec], linspace(0,max(z.cycleTime_b), 50), 'FaceColor', 'c');

yyaxis right
plot(z.cycleTime_b, nanmean(z.cycleMat_tVel), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2); hold on
plot(z.cycleTime_b, nanmean(z.cycleMat_hVel), 'Color', [0, 0.4470, 0.7410] , 'LineWidth', 2);

title(titlez)
legend('Binned CS: All', 'Binned CS: Relevant', 'T Vel', 'H Vel')
xlim([0 max(z.cycleTime_b)])
xticklabels(xticks)

%% FIG B: Simple Spike Firing
axes(Summary(2)); hold on
plot(z.cycleTime_ss, nanmean(z.cycleMat_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);
ssMeanfr = nanmean(z.cycleMat_ss(:));
ylim([30 110])
% good in cycle N
rectangle('Position',[min(z.csWindow_good),ssMeanfr,(max(z.csWindow_good)-min(z.csWindow_good)),max(ylim)], ...
          'FaceColor',[.85 .85 .95], 'EdgeColor', [.85 .85 .95])
% bad in cycle N
rectangle('Position',[min(z.csWindow_bad),ssMeanfr,(max(z.csWindow_bad)-min(z.csWindow_bad)),max(ylim)], ...
          'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])
% Bad in cycle 2
rectangle('Position',[min(z.csWindow_bad2),min(ylim),(max(z.csWindow_bad2)-min(z.csWindow_bad2)),abs(ssMeanfr-min(ylim))], ...
          'FaceColor',[.95 .85 .85], 'EdgeColor', [.95 .85 .85])

plot(z.cycleTime_ss, nanmean(z.cycleMat_ss, 1),'Color', [0.4940, 0.1840, 0.5560], 'LineWidth', 1);

hline(ssMeanfr, ':k');
legend('Average ss firing rate: All cycles in All Segements')
xlim([0 max(z.cycleTime_b)])
xticklabels(xticks)

%% FIG C: Average of Differences
axes(Summary(3)); hold on
legendText = ['Average Cycle ss fr Difference | ', num2str(size(csInfo_good, 2)), ' Example(s)'];
try
    alldiffsMean = nanmean([csInfo_good.chunkDiff],2);
    color = [0.4940, 0.1840, 0.5560];
    plot(z.chunkTime, alldiffsMean, 'Color', color, 'LineWidth', 1);
    xlim([0 max(z.chunkTime)])
catch
end

legend(legendText)

ylim([-100 100])
hline(0, ':k')
vline(mean(xlim), ':k');
vline(mean(xlim)-.120, ':k');
xticklabels(xticks)

end