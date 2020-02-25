function plot_singleFileSanityCheck(recData, z, segInfo, segment_ssfr, p, cycleMat_ss, cycleMean_ss)


figure('Position', [1 41 1920 1083]);
overviewPlot = tight_subplot(3,3,[.05 .01],[.03 .03],[.01 .01]);

axes(overviewPlot(1));
plot(z.segTime_ssfr, segment_ssfr);
xlim([0 10]);
yticks([]);
title('Cont. Firing Rate: Segment')

axes(overviewPlot(6));
plot(z.cycleTime_e, cycleMat_ss'); hold on
plot(z.cycleTime_e, cycleMean_ss, 'k', 'LineWidth', 5);
title('Cont. Firing Rate: Cycles');
stdev = nanstd(segment_ssfr);

thresh = stdev*5 + nanmean(segment_ssfr);
mad = nanmedian(abs(segment_ssfr - nanmedian(segment_ssfr)))*20+ nanmedian(segment_ssfr);
hline(500)
%ylim([0 mad*1.75])
%yticks([]);
%         figure()
%         hist(segment_ssfr, 100)
%         xlim([0 500])

axes(overviewPlot(3));
btimeVec = dattime(recData(1,7));
plot(z.cycleTime_b, z.cycleMean_tVel, 'r'); hold on
plot(z.cycleTime_b, z.cycleMean_hVel, 'b');
yticks([]);
title('Stim')
legend('T Vel', 'H Vel')

axes(overviewPlot(2));
plot(dattime(recData(10)), recData(10).data)
vline(recData(8).data(50:53))
xlim([recData(8).data(50) recData(8).data(53)])
yticks([]);
title('Simple Spikes')
try
    axes(overviewPlot(5));
    plot(dattime(recData(10)), recData(1,10).data)
    vline(recData(1,9).data(1:4))
    xlim([recData(1,9).data(1) recData(1,9).data(4)])
    yticks([]);
    title('Complex Spikes')
catch
end

axes(overviewPlot(4));
title(segInfo.name)
text(1,9, ['Align Val: ', num2str(segInfo.maxAlignVal)] )
text(1,8, ['Sample Start Point Ephys: ', num2str(z.startpt_e/z.sr_e)])
text(1,7, ['Sample Start Point Behav: ', num2str(z.startpt_b/z.sr_b)])
xlim([0 10])
ylim([0 10])

axes(overviewPlot(7));
title('Start Time Check')
btimeVec = dattime(recData(1,7));
plot(z.segTime_b, recData(7).data, 'r'); hold on
plot(z.segTime_b, recData(5).data, 'b');
yticks([]);

xlim([0 2])
ylim([-30 30])
vline(z.startpt_b/z.sr_b, '--k')
vline(z.startpt_e/z.sr_e, 'c')
hline(0, 'k')
legend('T Vel', 'H Vel')

axes(overviewPlot(8));
polarplot(deg2rad(z.ssfr_phase), z.ssfr_amp, '*k')

