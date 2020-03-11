function trackParams = setupEyeTracking_APP(app, trackParams, frameData)

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
pos = createMask(roi);
close all;

%% Detect Pupil
ok = 0;
while ~ok && frame<10
    
    % Select ROI
    [img] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame, pos);
    
    % Detect Pupil
    try
        [trackParams, frameData] = detectPupilCR_APP(app, 1, img, [], [], trackParams);
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
disp(['Pupil: ', num2str(max(frameData(end).pupil(3:4)))]);
disp(['CR a : ', num2str(frameData(end).cr1(3))]);
disp(['CR b : ', num2str(frameData(end).cr2(3))]);
disp(' ')

%% Save settings
radiiPupil = trackParams.radiiPupil;
minfeatures = trackParams.minfeatures;
radiiCR = trackParams.radiiCR;
CRthresh = trackParams.CRthresh;
CRfilter = trackParams.CRfilter;
CRthresh2 = trackParams.CRthresh2;
CRfilter2 = trackParams.CRfilter2;
imAdjust = trackParams.imAdjust;
pupilStart = trackParams.pupilStart;
manual = trackParams.manual;

save('settings','pos','radiiPupil','minfeatures',...
    'radiiCR','CRthresh','CRfilter','CRthresh2','CRfilter2',...
    'imAdjust','pupilStart','manual')

end