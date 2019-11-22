function hp = plotresults_APP(app, results, hp, i)

alldata = [results.pupil1(:,1) results.cr1a(:,1:2)...
           results.pupil2(:,1) results.cr2b(:,1:2)];
ylims = [min(alldata(:))*1.1 max(alldata(:))*1.1];

if i == 120
    
    hold(app.UIAxes3, 'on')
    hp(1) = plot(app.UIAxes3, results.time1, results.pupil1(:,1),'r-');
    hp(2) = plot(app.UIAxes3, results.time2, results.pupil2(:,1),'m-');
    hp(3) = plot(app.UIAxes3, results.time1, results.cr1a(:,1),'b-');
    hp(4) = plot(app.UIAxes3, results.time2, results.cr2b(:,1),'c-');
        
    xlim(app.UIAxes3, [results.time2(1+1) results.time2(end-1)]);
    ylim(app.UIAxes3, ylims)
    ylabel(app.UIAxes3, 'Horiz Pos (pix)')
    hold(app.UIAxes3, 'off')


    hold(app.UIAxes3_2, 'on')
    hp(5) = plot(app.UIAxes3_2, results.time1,max(results.pupil1(:,3:4),[],2),'r-');
    hp(6) = plot(app.UIAxes3_2, results.time2,max(results.pupil2(:,3:4),[],2),'m-');  
    hp(7) = plot(app.UIAxes3_2, results.time1,results.cr1a(:,3),'b-');
    hp(8) = plot(app.UIAxes3_2, results.time2,results.cr2b(:,3),'c-');  

    xlim(app.UIAxes3_2, [results.time2(1) results.time2(end)]);
    xlabel(app.UIAxes3_2, 'Time (s)')
    hold(app.UIAxes3_2, 'off')
    
else
    
     set(hp(1), 'XData', results.time1)
     set(hp(1), 'YData', results.pupil1(:,1))
     
     set(hp(2), 'XData', results.time2)
     set(hp(2), 'YData', results.pupil2(:,1))
     
     set(hp(3), 'XData', results.time1)
     set(hp(3), 'YData', results.cr1a(:,1))
     
     set(hp(4), 'XData', results.time2)
     set(hp(4), 'YData', results.cr2b(:,1))
     
     set(hp(5), 'XData', results.time1)
     set(hp(5), 'YData', max(results.pupil1(:,3:4),[],2))
     
     set(hp(6), 'XData', results.time2)
     set(hp(6), 'YData', max(results.pupil2(:,3:4),[],2))
     
     set(hp(7), 'XData', results.time1)
     set(hp(7), 'YData', results.cr1a(:,3))
     
     set(hp(8), 'XData', results.time2)
     set(hp(8), 'YData', results.cr2b(:,3))

end