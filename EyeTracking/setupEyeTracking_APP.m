function trackParams = setupEyeTracking_APP(app, trackParams)

%% Load image to test
frame = 1;
[imgLarge] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame);

%% User finds pupil center and analysis ROI
[pupilStartLarge] = testradiipupilmanual_APP(app, imgLarge);
trackParams.pupilStart = [round(pupilStartLarge(1)), round(pupilStartLarge(2))];

disp('Draw an elipse around analysis ROI.')
disp('When finished, press any key.');

roi = drawellipse;

pause
trackParams.pos = createMask(roi);
roi.SemiAxes = roi.SemiAxes -3;
trackParams.pos2 = createMask(roi);
close all;

%% Detect Pupil
ok = 0;
while ~ok && frame<10
    
    % Select ROI
    [img] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame, trackParams.pos);
    
    % Detect Pupil
    try
        [trackParams, frameData] = detectPupilCR_APP(app, img, [], [], trackParams);        

        ok = 1;
    catch msgid
        warning(msgid.message)
        ok = 0;
    end
    
    % Try next frame if bad image
    frame = frame + 1;
end

%% Print radii information for user
disp(' ')
disp(' ')
disp('Radii: ')
disp(['Pupil: ', num2str(max([frameData.pupil_r1, frameData.pupil_r2]))]);
disp(['CR a : ', num2str(frameData.cr1_r)]);
disp(['CR b : ', num2str(frameData.cr2_r)]);
disp(' ')

end