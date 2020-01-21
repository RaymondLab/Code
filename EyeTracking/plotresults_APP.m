function hp = plotresults_APP(app, results, hp, i)

alldata = [results.pupil(:,1) results.cra(:,1:2)...
           results.crb(:,1:2)];
ylims = [min(alldata(:))*1.1 max(alldata(:))*1.1];

if i == 15
    
    hold(app.UIAxes3, 'on')
    hp(1) = plot(app.UIAxes3, results.time1, results.pupil(:,1),'r-');
    hp(2) = plot(app.UIAxes3, results.time1, results.crb(:,1), 'c-');
    hp(3) = plot(app.UIAxes3, results.time1, results.cra(:,1),'b-');
        
    xlim(app.UIAxes3, [results.time1(1+1) results.time1(end-1)]);
    ylim(app.UIAxes3, ylims)
    ylabel(app.UIAxes3, 'Horiz Pos (pix)')
    hold(app.UIAxes3, 'off')


    hold(app.UIAxes3_2, 'on')
    hp(5) = plot(app.UIAxes3_2, results.time1,max(results.pupil(:,3:4),[],2),'r-');
    hp(6) = plot(app.UIAxes3_2, results.time1,results.crb(:,3),'c-');
    hp(7) = plot(app.UIAxes3_2, results.time1,results.cra(:,3),'b-');

    xlim(app.UIAxes3_2, [results.time1(1) results.time1(end)]);
    xlabel(app.UIAxes3_2, 'time1 (s)')
    hold(app.UIAxes3_2, 'off')
    
else
    
     set(hp(1), 'XData', results.time1)
     set(hp(1), 'YData', results.pupil(:,1))
     
     set(hp(2), 'XData', results.time1)
     set(hp(2), 'YData', results.pupil(:,2))
     
     set(hp(3), 'XData', results.time1)
     set(hp(3), 'YData', results.cra(:,1))
     
     set(hp(5), 'XData', results.time1)
     set(hp(5), 'YData', max(results.pupil(:,3:4),[],2))
     
     set(hp(6), 'XData', results.time1)
     set(hp(6), 'YData', results.crb(:,3))
     
     set(hp(7), 'XData', results.time1)
     set(hp(7), 'YData', results.cra(:,3))


end