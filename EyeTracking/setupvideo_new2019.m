function vid = setupvideo_new2019(pos)

imaqreset;

vid(1) = videoinput('winvideo',1,'MJPG_1280x1024'); % default: MJPG_1024x768
vid(2) = videoinput('winvideo',2,'MJPG_1280x1024'); % MJPG_1920x1080

% Set up the camera
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
triggerconfig(vid,'manual');

% Get a grayscale image
set(vid,'ReturnedColorSpace','grayscale');

%% Set exposure and gain
for i = 1:2
src = getselectedsource(vid(i));
src.Exposure = -10;
%src.Gain = 100;
% src.BacklightCompensation = 'off';
frameRates = set(src, 'FrameRate');
src.FrameRate = frameRates{1}; % Highest frame rate = 30 fps
end


%% Set new video size
if exist('pos','var') 
   pos1 = pos;
   pos2 = pos;
   set(vid(1), 'ROIPosition',pos1);
   set(vid(2), 'ROIPosition',pos2);
end
