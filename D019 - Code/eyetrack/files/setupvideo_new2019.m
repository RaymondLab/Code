function vid = setupvideo_new2019(pos)

imaqreset;

%vid(1) = videoinput('winvideo',1,'MJPG_1280x1024');
%vid(2) = videoinput('winvideo',2,'MJPG_1280x1024');
vid(1) = videoinput('winvideo',1,'YUY2_640x480') 
vid(2) = videoinput('winvideo',2,'YUY2_640x480')
pos = [60 60 60 60]

imaqhwinfo('winvideo',1)
imaqhwinfo('winvideo',2)

get(getselectedsource(vid(1)))
get(getselectedsource(vid(2)))

get(getselectedsource(vid(2)))

preview(vid(1))
preview(vid(2))


% Set up the camera
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
triggerconfig(vid,'manual');

% Get a grayscale image
set(vid,'ReturnedColorSpace','grayscale');

%% Set exposure and gain
src1 = getselectedsource(vid(1));
% src.Exposure = -9;
% src.Gain = 50;
% src.BacklightCompensation = 'off';
% src.WhiteBalanceMode = 'manual';
frameRates = set(src1, 'FrameRate');
src1.FrameRate = frameRates{1}; % Highest frame rate = 30 fps

src2 = getselectedsource(vid(2));
% src.Exposure = -9;
% src.Gain = 50;
% src.BacklightCompensation = 'off';
% src.WhiteBalanceMode = 'manual';
src2.FrameRate = frameRates{1};

%% Set new video size
if exist('pos','var') 
    set(vid(1), 'ROIPosition',pos);
    set(vid(2), 'ROIPosition',pos);
    
    disp(vid(1)) % hobin
    disp(vid(2)) % hobin
end
