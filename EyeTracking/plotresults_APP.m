function hp = plotresults_APP(app, results, frameData, hp, i)

pupil = vec2mat([frameData.pupil],5);
pupil(end,:) = [];
pupil(:,1) = pupil(:,1)- pupil(1,1);

cr1 = vec2mat([frameData.cr1],3);
cr1(end,:) = [];
cr1(:,1) = cr1(:,1)- cr1(1,1);

cr2 = vec2mat([frameData.cr2],3);
cr2(end,:) = [];
cr2(:,1) = cr2(:,1)- cr2(1,1);

crData = [pupil(:,1) cr1(:,1) cr2(:,1)];


% TEMP
while length(results.time1) > length(results.pupil)
    results.time1(end) = [];
end


if i == 15
    
    % Pupil Horizontal Position
    hold(app.UIAxes3, 'on')
    hp(1) = plot(app.UIAxes3, pupil(:,1),'r-');
        
    xlim(app.UIAxes3, [0 length(results.time1)]);
    ylim(app.UIAxes3, [min(pupil(:,1))*1.1 max(pupil(:,1))*1.1])
    ylabel(app.UIAxes3, 'Pupil H Pos')
    hold(app.UIAxes3, 'off')

    % CRs Horizontal Position
    hold(app.UIAxes3_2, 'on')
    hp(2) = plot(app.UIAxes3_2, cr1(:,1), 'c-');
    hp(3) = plot(app.UIAxes3_2, cr2(:,1), 'b-');
    plot(app.UIAxes3_2, linspace(0, length(results.time1), length(results.time1)), zeros(1, length(results.time1)), ':k') 
    plot(app.UIAxes3_2, linspace(0, length(results.time1), length(results.time1)), zeros(1, length(results.time1))-5, ':k') 
    plot(app.UIAxes3_2, linspace(0, length(results.time1), length(results.time1)), zeros(1, length(results.time1))-10, ':k') 
    plot(app.UIAxes3_2, linspace(0, length(results.time1), length(results.time1)), zeros(1, length(results.time1))+5, ':k') 
    plot(app.UIAxes3_2, linspace(0, length(results.time1), length(results.time1)), zeros(1, length(results.time1))+10, ':k') 
    xlim(app.UIAxes3_2, [0 length(results.time1)]);
    ylim(app.UIAxes3_2, [-15 15])
    ylabel(app.UIAxes3_2, 'CR H Pos')
    hold(app.UIAxes3_2, 'off')
    

    % Pupil and CRs maximum radii
    hold(app.UIAxes3_3, 'on')
    hp(5) = plot(app.UIAxes3_3, max(pupil(:,3:4),[],2),'r-');
    hp(6) = plot(app.UIAxes3_3, cr1(:,3),'c-');
    hp(7) = plot(app.UIAxes3_3, cr2(:,3),'b-');

    xlim(app.UIAxes3_3, [0 length(results.time1)]);
    xlabel(app.UIAxes3_3, 'Frame #')
    ylabel(app.UIAxes3_3, 'Radii')
    hold(app.UIAxes3_3, 'off')
    
else
    
    set(hp(1), 'YData', pupil(:,1))
    set(hp(2), 'YData', cr1(:,1))
    set(hp(3), 'YData', cr2(:,1))
    set(hp(5), 'YData', max(pupil(:,3:4),[],2))
    set(hp(6), 'YData', cr1(:,3))
    set(hp(7), 'YData', cr2(:,3))
    ylim(app.UIAxes3, [min(pupil(:,1))*1.1 max(pupil(:,1))*1.1])

end