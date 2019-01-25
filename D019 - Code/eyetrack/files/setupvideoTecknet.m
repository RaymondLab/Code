function vid = setupvideoTecknet(pos)

imaqreset;

% If there are any problems with vieso set up:
imaqhwinfo('winvideo');
a=imaqhwinfo('winvideo',1);  a.SupportedFormats';

vid(1) = videoinput('winvideo',1,'RGB24_1280x960');
vid(2) = videoinput('winvideo',2,'MJPG_1920x1080'); 'YUY2_1920x1080'
vid(1) = videoinput('winvideo',1,'YUY2_1920x1080'); 'YUY2_1920x1080'

% Set up the camera
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
triggerconfig(vid,'manual');

% Get a grayscale image
set(vid,'ReturnedColorSpace','grayscale');

%% Set exposure and gain
src = getselectedsource(vid(1));
src.Exposure = -9;
src.Gain = 50;
src.BacklightCompensation = 'off';
src.WhiteBalanceMode = 'manual';
frameRates = set(src, 'FrameRate');
src.FrameRate = frameRates{1}; % Highest frame rate = 30 fps

% src = getselectedsource(vid(2));
% src.Exposure = -9; % [-8 0]
% src.Gain = 50;
% src.BacklightCompensation = 'off';
% src.WhiteBalanceMode = 'manual';
% src.FrameRate = frameRates{1};

%% Set new video size
if exist('pos','var') 
    set(vid(1), 'ROIPosition',pos);
    set(vid(2), 'ROIPosition',pos);
end
