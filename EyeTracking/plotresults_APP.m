function plotresults_APP(app, results)

%% Plot raw data
%clf;
alldata = [results.pupil1(:,1) results.cr1a(:,1:2)...
           results.pupil2(:,1) results.cr2b(:,1:2)];
ylims = [min(alldata(:)) max(alldata(:))];

%% Camera 1
hold(app.UIAxes3, 'on')
hp(3) = plot(app.UIAxes3, results.time1, results.cr1a(:,2),'b-');
hp(1) = plot(app.UIAxes3, results.time1, results.pupil1(:,1),'r-');
hp(2) = plot(app.UIAxes3, results.time1, results.cr1a(:,1),'k-');

xlim(app.UIAxes3, [results.time2(1+1) results.time2(end-1)]);
ylim(app.UIAxes3, ylims)
ylabel(app.UIAxes3, 'Cam1 pos (pix)')
hold(app.UIAxes3, 'off')


%% Camera 2
hold(app.UIAxes3_2, 'on')

plot(app.UIAxes3_2, results.time2,results.cr2b(:,2),'b-');
plot(app.UIAxes3_2, results.time2, results.pupil2(:,1),'r-');
plot(app.UIAxes3_2, results.time2,results.cr2b(:,1),'k-');

xlim(app.UIAxes3_2, [results.time2(1) results.time2(end)]);
ylim(app.UIAxes3_2, ylims)
xlabel(app.UIAxes3_2, 'Time (s)')
ylabel(app.UIAxes3_2, 'Cam2 pos (pix)')
hold(app.UIAxes3_2, 'off')


%legend(app.UIAxes3_2, hp,{'Pupil - X','Corneal Reflection - X','Corneal Reflection - Y'})

