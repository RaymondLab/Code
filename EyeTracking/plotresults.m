function plotresults(results)

%% Plot raw data
clf;
alldata = [results.pupil1(:,1) results.cr1a(:,1:2)...
    results.pupil2(:,1) results.cr2b(:,1:2)];
ylims = [min(alldata(:)) max(alldata(:))];
h(1)=subplot(2,1,1);
hp(3) = plot(results.time1, results.cr1a(:,2),'Color',[.4 .4 .4]); hold on;
hp(1) = plot(results.time1, results.pupil1(:,1),'r-'); hold on
hp(2) = plot(results.time1, results.cr1a(:,1),'k-');
xlim([results.time2(1+1) results.time2(end-1)]); box off
ylim(ylims)
ylabel('Cam1 pos (pix)')
set(gca,'XTick',[],'XColor','w')

h(2)=subplot(2,1,2);
plot(results.time2,results.cr2b(:,2),'Color',[.4 .4 .4]); hold on;
plot(results.time2, results.pupil2(:,1),'r-'); hold on;
plot(results.time2,results.cr2b(:,1),'k-');
xlim([results.time2(1) results.time2(end)]); box off
ylim(ylims)
xlabel('Time (s)')
ylabel('Cam2 pos (pix)')

legend(hp,{'pupilx','crx','cry'})
linkaxes(h,'x')