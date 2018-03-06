                                                                                                                                                                                                                  %% runSETUP
% Run a mouse video eye tracking calibration session
% Hannah Payne
% Raymond Lab, Stanford University 2013
% hpayne@stanford.edu
%                            
% NOTES
% 1. If two cameras are not detected - unplug and replug both USBS one at a
% time, and restart matlab
% 2. If frame rate is < 30 fps, go into Logitech Quick cam, uncheck
% RightLight, go advanced settings, uncheck all "autos"
%
% If issue with webcam, (Tecknet), try reinstalling drivers
% http://www.tecknet.co.uk/support/c018.html

%% Set up video cams
% cameraType = 'tecknet'; %'logitech'
cameraType = 'logitech'; %'logitech'

close all; imaqreset; warning off
delete(imaqfind)

% Make video objects

%============CAMERA: LOGITECH C310=================
if strcmp(cameraType,'logitech')
    res  = [1280 960];
    
    % Set the size of the ROI and vertical offset here %
    boxsize = 500;
    boxoffset = 300; %300
    roiinitial = [(res-boxsize)/2 boxsize boxsize]+[boxoffset 0 0 0];
    vid = setupvideo(roiinitial); pause(.1)
    
    % Show preview until figure closed
    [img1, img2] = eyecam(vid); % ***Run "eyecam(vid);" to see preview at any point ***%

    % Prompt for ROI around one eye
    %- first click on camera image from the left
    % side, then click-drag to select rectangle
    vid = setROI(vid,img1, img2, res, boxsize, boxoffset);
    
else
    
    % =================TECHNET===================
    res  = [1920 1080];
    boxsize = 400;
    boxoffset = 000; % 3/1
    roiinitial = [(res-boxsize)/2 boxsize boxsize]+[0 boxoffset 0 0];
    
    vid = setupvideoTecknet(roiinitial);pause(.1)
    % Show preview until figure closed
    [img1, img2] = eyecam(vid, 0, 0, cameraType); % ***Run "eyecam(vid);" to see preview at any point ***%
    
    % Prompt for ROI around one eye
    %- first click on camera image from the left
    % side, then click-drag to select rectangle
    vid = setROITecknet(vid, img1, img2, res, boxsize, boxoffset);
    
    
%     roi = setROITecknet(vid, img1, img2, boxsize, boxoffset);
%     roi2 = roi + [res/2-200 0 0];
%     roi2(3) = 2*(res(1)/2-roi2(1)); % Ensure new image is still centered
%     close gcf
%     vid = setupvideoTecknet(roi2); % Set up new video
    
end

%% *** RUN THE CALIBRATION DATA COLLECTION ***
disp('Make sure you are in the right path!!!! ');
if exist(fullfile(cd,'img1.tiff'),'file')
    warning('Overwrite')
    delete(fullfile(pwd, 'img1.tiff'),fullfile(pwd,'img2.tiff'))
end

close all
eyetrackon = 1;
nframes = 30*120; % 30*nseconds
% eyecam(vid,eyetrackon,nframes); % results = time stamps, images are saves as img1 and 2
eyecam(vid,eyetrackon,nframes, cameraType); % results = time stamps, images are saves as img1 and 2
warning on

%% Set settings for video analysis (can be done offline)
setupEyeAnalysis

% return

%% Run video analysis using settings from above (can be run later)
% Locate pupil and CRS
eyeAnalysis

% Save results
saveas(1,'eyetrack1.jpg')
saveas(2,'eyetrack2.jpg')

%% Analyze calibration to get scale factors
findmagscaleVel

% Make sure angle between cameras is set correctly here:
% C:\Users\Public\Code\eyetrack\files\calceyeangle.m
%     theta = 40;



