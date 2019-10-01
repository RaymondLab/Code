function hp = plotresults_APP(app, results, hp, i)


alldata = [results.pupil1(:,1) results.cr1a(:,1:2)...
           results.pupil2(:,1) results.cr2b(:,1:2)];
ylims = [min(alldata(:)) max(alldata(:))];

%% First plot
if i == 120

    % Camera 1
    hold(app.UIAxes3, 'on')
    hp(1) = plot(app.UIAxes3, results.time1, results.cr1a(:,2),'b-');
    hp(2) = plot(app.UIAxes3, results.time1, results.pupil1(:,1),'m-');
    hp(3) = plot(app.UIAxes3, results.time1, results.cr1a(:,1),'k-');

    xlim(app.UIAxes3, [results.time2(1+1) results.time2(end-1)]);
    ylim(app.UIAxes3, ylims)
    ylabel(app.UIAxes3, 'Cam1 pos (pix)')
    hold(app.UIAxes3, 'off')


    % Camera 2
    hold(app.UIAxes3_2, 'on')
    hp(4) = plot(app.UIAxes3_2, results.time2,results.cr2b(:,2),'b-');
    hp(5) = plot(app.UIAxes3_2, results.time2, results.pupil2(:,1),'m-');
    hp(6) = plot(app.UIAxes3_2, results.time2,results.cr2b(:,1),'k-');

    xlim(app.UIAxes3_2, [results.time2(1) results.time2(end)]);
    ylim(app.UIAxes3_2, ylims)
    xlabel(app.UIAxes3_2, 'Time (s)')
    ylabel(app.UIAxes3_2, 'Cam2 pos (pix)')
    hold(app.UIAxes3_2, 'off')
    
else
    set(hp(1), 'XData', results.time1)
    set(hp(1), 'YData', results.cr1a(:,2))
    
    set(hp(2), 'XData', results.time1)
    set(hp(2), 'YData', results.pupil1(:,1))
    
    set(hp(3), 'XData', results.time1)
    set(hp(3), 'YData', results.cr1a(:,1))
    
    set(hp(4), 'XData', results.time2)
    set(hp(4), 'YData', results.cr2b(:,2))
    
    set(hp(5), 'XData', results.time2)
    set(hp(5), 'YData', results.pupil2(:,1))
    
    set(hp(6), 'XData', results.time2)
    set(hp(6), 'YData', results.cr2b(:,1))
end