function vid = setupvideo_new2019(pos)
  % make sure that there are no other connection to other video input
  imaqreset;

  % Videoinput makes sure that the connection between PC and camera exists.
  vid(1) = videoinput('winvideo',1,'MJPG_1280x1024');
  vid(2) = videoinput('winvideo',2,'MJPG_1280x1024');

  % Set up the camera
  set(vid,'FramesPerTrigger',1);
  set(vid,'TriggerRepeat',Inf);

  % Instead of default config, use our 'vid' parameters file.
  % Keep recording forever until we stop it.
  triggerconfig(vid,'manual');

  % Get a grayscale image
  set(vid,'ReturnedColorSpace','grayscale');

  %% Set exposure and gain
  for i = 1:2
    src = getselectedsource(vid(i));
    src.Exposure = -10; % changing the exposure changes the frames per second. Higher exposure == lower frames per second
    frameRates = set(src, 'FrameRate');
    src.FrameRate = frameRates{1}; % Highest frame rate = 30 fps
  end

  %% Set new video size
  % If the user inputted a region of interest, set that region of interest for each video input
  if exist('pos','var')
     pos1 = pos;
     pos2 = pos;
     set(vid(1), 'ROIPosition',pos1);
     set(vid(2), 'ROIPosition',pos2);
     %set(vid, 'ROIPosition', pos);
  end
