function vid = setupvideoTecknet(pos)

imaqreset;

% If there are any problems with video set up:
imaqhwinfo('winvideo');
a=imaqhwinfo('winvideo',1);  a.SupportedFormats';

vid(1) = videoinput('winvideo',1,'MJPG_1920x1080');
vid(2) = videoinput('winvideo',2,'MJPG_1920x1080'); %'YUY2_1920x1080'

% Set up the camera
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
triggerconfig(vid,'manual');

% Get a grayscale image
set(vid,'ReturnedColorSpace','grayscale');

%% Set exposure and gain
for i = 1:2
    src = getselectedsource(vid(i));
    src.Exposure = -6; %-5
    src.Brightness = 0; %4
    src.Saturation = 0;
    src.Sharpness = 2;
    src.ExposureMode = 'Manual';
    src.WhiteBalanceMode = 'manual';
    src.FrameRate = '30.0000'; % Highest frame rate = 30 fps
    src.BacklightCompensation = 'off';
    src.VerticalFlip = 'on';
    src.HorizontalFlip = 'on';
    
    if exist('pos','var')        
        set(vid(i), 'ROIPosition',pos);
    end
    
end

%% Set new video size

