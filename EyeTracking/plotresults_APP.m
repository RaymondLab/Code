function hp = plotresults_APP(app, frameData, hp, i)

timeLen = length([frameData.time1]);

if i == 15
    
    % Pupil Horizontal Position
    hold(app.UIAxes3, 'on')
    hp(1) = plot(app.UIAxes3, [frameData.pupil_x],'r-');
        
    xlim(app.UIAxes3, [0 timeLen]);
    ylim(app.UIAxes3, [nanmin([frameData.pupil_x])*.9 nanmax([frameData.pupil_x])*1.1])
    ylabel(app.UIAxes3, 'Pupil H Pos')
    hold(app.UIAxes3, 'off')

    % CRs Horizontal Position
    hold(app.UIAxes3_2, 'on')
    hp(2) = plot(app.UIAxes3_2, [frameData.cr1_x] - nanmean([frameData.cr1_x]), 'b-');
    hp(3) = plot(app.UIAxes3_2, [frameData.cr2_x] - nanmean([frameData.cr2_x]), 'c-');
    plot(app.UIAxes3_2, 1:timeLen, zeros(1, timeLen), ':k') 
    plot(app.UIAxes3_2, 1:timeLen, zeros(1, timeLen)-5, ':k') 
    plot(app.UIAxes3_2, 1:timeLen, zeros(1, timeLen)-10, ':k') 
    plot(app.UIAxes3_2, 1:timeLen, zeros(1, timeLen)+5, ':k') 
    plot(app.UIAxes3_2, 1:timeLen, zeros(1, timeLen)+10, ':k') 
    xlim(app.UIAxes3_2, [0 timeLen]);
    ylim(app.UIAxes3_2, [-15 15])
    ylabel(app.UIAxes3_2, 'CR H Pos')
    hold(app.UIAxes3_2, 'off')
    

    % Pupil and CRs maximum radii
    hold(app.UIAxes3_3, 'on')
    hp(5) = plot(app.UIAxes3_3, max([frameData.pupil_r1,frameData.pupil_r1]),'r-');
    hp(6) = plot(app.UIAxes3_3, [frameData.cr1_r],'b-');
    hp(7) = plot(app.UIAxes3_3, [frameData.cr2_r],'c-');

    xlim(app.UIAxes3_3, [0 timeLen]);
    xlabel(app.UIAxes3_3, 'Frame #')
    ylabel(app.UIAxes3_3, 'Radii')
    hold(app.UIAxes3_3, 'off')
    
else
    
    set(hp(1), 'YData', [frameData.pupil_x])
    set(hp(2), 'YData', [frameData.cr1_x] - nanmean([frameData.cr1_x]))
    set(hp(3), 'YData', [frameData.cr2_x] - nanmean([frameData.cr2_x]))
    set(hp(5), 'YData', max([frameData.pupil_r1,frameData.pupil_r1]))
    set(hp(6), 'YData', [frameData.cr1_r])
    set(hp(7), 'YData', [frameData.cr2_r])
    ylim(app.UIAxes3, [nanmin([frameData.pupil_x])*.9 nanmax([frameData.pupil_x])*1.1])

end