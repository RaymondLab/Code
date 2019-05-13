%% runSETUP
% Run a mouse video eye tracking calibration session
%
% Hannah Payne
% Raymond Lab, Stanford University 2013
% hpayne@alumni.stanford.edu
%
% NOTES
% - To install cameras, enter: imaqhwinfo('winvideo')
% If an error returns, click the link and install the OS Generic Video
% Interface
% - If two cameras are not detected - unplug and replug both USBS one at a
% time, and restart matlab
% - If frame rate is < 30 fps, go into Logitech Quick cam, uncheck
% RightLight, go advanced settings, uncheck all "autos"

%% Set up video cams
close all; imaqreset; delete(imaqfind); %warning off

%addpath('C:\Users\amins\Desktop\files'); % hobin commented out

% Make video objects
type = 'new'; % {'logitech','new')

switch type
    case 'new'
        res  = [1280 1024];
        boxsize = 500;
        boxoffset = -90;
        roiinitial = [(res-boxsize)/2 boxsize boxsize]+[boxoffset 0 0 0];
        % ########### CLICK AND DRAG METHOD ###############
        %vid = setupvideo_new2019(); pause(.1)
        
        vid = setupvideo_new2019(roiinitial); pause(.1)
        
        % Show preview until figure closed
        [img1, img2] = eyecam(vid); % ***Run "eyecam(vid);" to see preview at any point ***%
        
        % Prompt for ROI around one eye - first click on camera image from the left
        % side, then click-drag to select rectangle
        % vid = setROI(vid,img1, img2, res); %hannah
        vid = setROI(vid,img1, img2, res, boxsize, boxoffset); % hobin

    case 'logitech'
        %res  = [1280 960];
        %boxsize = 500;
        %roiinitial = [(res-boxsize)/2 boxsize boxsize]+[200 0 0 0];
        %vid = setupvideo_logitechC310(roiinitial);
end

%% *** RUN THE EXPERIMENT ***
disp('Make sure you are in the right path!!!! ');
if exist(fullfile(cd,'img1.tiff'),'file')
    warning('Overwrite')
    delete(fullfile(pwd, 'img1.tiff'),fullfile(pwd,'img2.tiff'))
end
close all
eyetrackon = 1; 
nframes = 30*120; % 30*nseconds
eyecam(vid,eyetrackon,nframes); % results = time stamps, images are saves as img1 and 2
warning on
%% Set settings for video analysis
addpath('C:\Users\hobinkim\Desktop\eyetrack-hobin\files');

setupEyeAnalysis

%% Run video analysis using settings from above (can be run later)
% Locate pupil and CR 
%addpath('C:\Users\amins\Desktop\files');
addpath('C:\Users\hobinkim\Desktop\eyetrack-hobin\files');
eyeAnalysis     
% Save results
saveas(1,'eyetrack1.jpg')
saveas(2,'eyetrack2.jpg')

%% Analyze calibration to get scale factors
addpath('C:\Users\hobinkim\Desktop\eyetrack-hobin\files');
findmagscaleVel
%{
%}