function vars = getScaleFactors_APP(app, vars)

%% SETUP
try
    a = vars.mag1;
catch
    vid = [];
    mag1 = [];
    mag2 = [];
end

freq = vars.CaliStimFreq;

%% LOAD VIDEOS

% Camera 1
try
    A = load(fullfile(cd, 'videoresults_cam1.mat'));
catch
    error('Camera 1 Results Not Found: videoresults_cam1.mat')
end
rawFrameData_cam1 = A.frameData;

% Camera 2
try
    B = load(fullfile(cd, 'videoresults_cam2.mat'));
catch
    error('Camera 2 Results Not Found: videoresults_cam2.mat')
end
rawFrameData_cam2 = B.frameData;

vid.pos_data = calceyeangle_APP(rawFrameData_cam1, rawFrameData_cam2); % old
vid.percent_frames_missed = sum(int64(isnan(vid.pos_data)))*100/length(vid.pos_data); % old

%% sort out time stamps

if app.Camera2Button.Value
    % Camera 2 (default)
    vid.time = [rawFrameData_cam1.time2];
elseif app.Camera1Button.Value
     % Camera 1
    vid.time = [rawFrameData_cam1.time1];
else
    % Median Times between frames
    vid.time = median([rawFrameData_cam1.time1; rawFrameData_cam1.time2]);
end
vid.time = vid.time-vid.time(1);

[tscale, ~] = fminsearchbnd(@(x)vidTimeFcn_APP(app, vid.time,vid.pos_data',freq,x),1,.7, 1.4); % old
vid.time = vid.time/tscale;%.995;% old
vid.samplerate = 1/mean(diff(vid.time)); % old

% minTimeStart = min([rawFrameData_cam1(1).time1, rawFrameData_cam1(1).time2]);
% 
% for i = 1:length([rawFrameData_cam1.time1])
%     rawFrameData_cam1(i).time1 = rawFrameData_cam1(i).time1 - minTimeStart;
%     rawFrameData_cam1(i).time2 = rawFrameData_cam1(i).time2 - minTimeStart;
%     rawFrameData_cam2(i).time1 = rawFrameData_cam2(i).time1 - minTimeStart;
%     rawFrameData_cam2(i).time2 = rawFrameData_cam2(i).time2 - minTimeStart;
% end

% %% upsample video - clunky writing
% maxTime = ceil(max([rawFrameData_cam1(end).time1*1000, rawFrameData_cam2(end).time2*1000]));
% 
% % preallocate
% nanVec = nan(maxTime,1);
% rawFrameData_cam1_us.cr1_x = nanVec;
% rawFrameData_cam1_us.cr1_y = nanVec;
% rawFrameData_cam1_us.cr1_r = nanVec;
% rawFrameData_cam1_us.cr2_x = nanVec;
% rawFrameData_cam1_us.cr2_y = nanVec;
% rawFrameData_cam1_us.cr2_r = nanVec;
% rawFrameData_cam1_us.pupil_x = nanVec;
% rawFrameData_cam1_us.pupil_y = nanVec;
% rawFrameData_cam1_us.pupil_r1 = nanVec;
% rawFrameData_cam1_us.pupil_r2 = nanVec;
% rawFrameData_cam1_us.pupil_angle = nanVec;
% 
% nanVec = nan(maxTime,1);
% rawFrameData_cam2_us.cr1_x = nanVec;
% rawFrameData_cam2_us.cr1_y = nanVec;
% rawFrameData_cam2_us.cr1_r = nanVec;
% rawFrameData_cam2_us.cr2_x = nanVec;
% rawFrameData_cam2_us.cr2_y = nanVec;
% rawFrameData_cam2_us.cr2_r = nanVec;
% rawFrameData_cam2_us.pupil_x = nanVec;
% rawFrameData_cam2_us.pupil_y = nanVec;
% rawFrameData_cam2_us.pupil_r1 = nanVec;
% rawFrameData_cam2_us.pupil_r2 = nanVec;
% rawFrameData_cam2_us.pupil_angle = nanVec;
% 
% % fill in values
% for i = 1:length([rawFrameData_cam1.time1])
%     
%     indx = (floor(rawFrameData_cam1(i).time1*1000)+1);
%     
%     rawFrameData_cam1_us.cr1_x(indx)  = rawFrameData_cam1(i).cr1_x;
%     rawFrameData_cam1_us.cr1_y(indx)  = rawFrameData_cam1(i).cr1_y;
%     rawFrameData_cam1_us.cr1_r(indx)  = rawFrameData_cam1(i).cr1_r;
%     rawFrameData_cam1_us.cr2_x(indx)  = rawFrameData_cam1(i).cr2_x;
%     rawFrameData_cam1_us.cr2_y(indx)  = rawFrameData_cam1(i).cr2_y;
%     rawFrameData_cam1_us.cr2_r(indx)  = rawFrameData_cam1(i).cr2_r;
%     rawFrameData_cam1_us.pupil_x(indx)  = rawFrameData_cam1(i).pupil_x;
%     rawFrameData_cam1_us.pupil_y(indx)  = rawFrameData_cam1(i).pupil_y;
%     rawFrameData_cam1_us.pupil_r1(indx)  = rawFrameData_cam1(i).pupil_r1;
%     rawFrameData_cam1_us.pupil_r2(indx)  = rawFrameData_cam1(i).pupil_r2;
%     rawFrameData_cam1_us.pupil_angle(indx)  = rawFrameData_cam1(i).pupil_angle;
% end
% 
% for i = 1:length([rawFrameData_cam2.time2]) 
%     
%     indx = (floor(rawFrameData_cam2(i).time2*1000)+1);
% 
%     rawFrameData_cam2_us.cr1_x(indx)  = rawFrameData_cam2(i).cr1_x;
%     rawFrameData_cam2_us.cr1_y(indx)  = rawFrameData_cam2(i).cr1_y;
%     rawFrameData_cam2_us.cr1_r(indx)  = rawFrameData_cam2(i).cr1_r;
%     rawFrameData_cam2_us.cr2_x(indx)  = rawFrameData_cam2(i).cr2_y;
%     rawFrameData_cam2_us.cr2_y(indx)  = rawFrameData_cam2(i).cr2_y;
%     rawFrameData_cam2_us.cr2_r(indx)  = rawFrameData_cam2(i).cr2_r;
%     rawFrameData_cam2_us.pupil_x(indx)  = rawFrameData_cam2(i).pupil_x;
%     rawFrameData_cam2_us.pupil_y(indx)  = rawFrameData_cam2(i).pupil_y;
%     rawFrameData_cam2_us.pupil_r1(indx)  = rawFrameData_cam2(i).pupil_r1;
%     rawFrameData_cam2_us.pupil_r2(indx)  = rawFrameData_cam2(i).pupil_r2;
%     rawFrameData_cam2_us.pupil_angle(indx)  = rawFrameData_cam2(i).pupil_angle;
% end
% 
% % fill missing values
% rawFrameData_cam1_us.cr1_x = fillmissing(rawFrameData_cam1_us.cr1_x,'spline');
% rawFrameData_cam1_us.cr1_y = fillmissing(rawFrameData_cam1_us.cr1_y,'spline');
% rawFrameData_cam1_us.cr1_r = fillmissing(rawFrameData_cam1_us.cr1_r,'spline');
% rawFrameData_cam1_us.cr2_x = fillmissing(rawFrameData_cam1_us.cr2_x,'spline');
% rawFrameData_cam1_us.cr2_y = fillmissing(rawFrameData_cam1_us.cr2_y,'spline');
% rawFrameData_cam1_us.cr2_r = fillmissing(rawFrameData_cam1_us.cr2_r,'spline');
% rawFrameData_cam1_us.pupil_x = fillmissing(rawFrameData_cam1_us.pupil_x,'spline');
% rawFrameData_cam1_us.pupil_y = fillmissing(rawFrameData_cam1_us.pupil_y,'spline');
% rawFrameData_cam1_us.pupil_r1 = fillmissing(rawFrameData_cam1_us.pupil_r1,'spline');
% rawFrameData_cam1_us.pupil_r2 = fillmissing(rawFrameData_cam1_us.pupil_r2,'spline');
% rawFrameData_cam1_us.pupil_angle = fillmissing(rawFrameData_cam1_us.pupil_angle,'spline');
% 
% rawFrameData_cam2_us.cr1_x = fillmissing(rawFrameData_cam2_us.cr1_x,'spline');
% rawFrameData_cam2_us.cr1_y = fillmissing(rawFrameData_cam2_us.cr1_y,'spline');
% rawFrameData_cam2_us.cr1_r = fillmissing(rawFrameData_cam2_us.cr1_r,'spline');
% rawFrameData_cam2_us.cr2_x = fillmissing(rawFrameData_cam2_us.cr2_x,'spline');
% rawFrameData_cam2_us.cr2_y = fillmissing(rawFrameData_cam2_us.cr2_y,'spline');
% rawFrameData_cam2_us.cr2_r = fillmissing(rawFrameData_cam2_us.cr2_r,'spline');
% rawFrameData_cam2_us.pupil_x = fillmissing(rawFrameData_cam2_us.pupil_x,'spline');
% rawFrameData_cam2_us.pupil_y = fillmissing(rawFrameData_cam2_us.pupil_y,'spline');
% rawFrameData_cam2_us.pupil_r1 = fillmissing(rawFrameData_cam2_us.pupil_r1,'spline');
% rawFrameData_cam2_us.pupil_r2 = fillmissing(rawFrameData_cam2_us.pupil_r2,'spline');
% rawFrameData_cam2_us.pupil_angle = fillmissing(rawFrameData_cam2_us.pupil_angle,'spline');
% rawFrameData_cam2_us.time = rawFrameData_cam1_us.time;
% 
% % make time vectors
% rawFrameData_cam1_us.time = 0:(1/1000):(length(rawFrameData_cam1_us.cr1_x)-1)/1000;
% 
% % calculate position
% vid.pos_data_upsampled = calceyeangle_APP(rawFrameData_cam1_us, rawFrameData_cam2_us);
% 
% % TODo
% % vid.percent_frames_missed = sum(int64(isnan(vid.pos_data)))*100/length(vid.pos_data);
% vid.percent_frames_missed = 0;
% 
% vid.time_upsampled = rawFrameData_cam1_us.time;

%% SETUP MAGNET

% Load Magnet Data
[~, filenameroot]= fileparts(cd);
fullfilename = fullfile(cd,[filenameroot '.smr']);

if app.LeftButton.Value
    % Left Eye (default)
    rawMagnetData = importSpike(fullfilename,[4 5 6 10]);
else
    % Right Eye
    rawMagnetData = importSpike(fullfilename,[4 7 8 10]);
end

% Select Proper Magnet window/segment
lightpulses = rawMagnetData(end).data;
segmentStart = lightpulses(1);
segmentEnd = segmentStart+vid.time(end);

rawMagnetData = resettime(datseg(rawMagnetData,[segmentStart segmentEnd]));

mag1.pos_data = double(rawMagnetData(2).data);
mag1.samplerate = rawMagnetData(1).samplerate;
mag1.time = dattime(rawMagnetData(2));

mag2.pos_data = double(rawMagnetData(3).data);
mag2.samplerate = rawMagnetData(2).samplerate;
mag2.time = dattime(rawMagnetData(3));

%% Upsample Video Traces OLD METHOD
vid.pos_data_upsampled = interp1(vid.time,vid.pos_data,mag1.time(:),'linear');
vid.pos_data_upsampled = inpaint_nans(vid.pos_data_upsampled);
vid.time_upsampled = mag1.time;

%% DESACCADE 
windowPre = app.SaccadeWindowmsEditField.Value;
windowPost = app.SaccadeWindowEditField_2.Value;
minDataLength = app.MinimumGoodDataLengthEditField.Value;

% Magnet Channel 1
mag1.saccadeThresh = app.SaccadeThresholdMagnetChan1EditField.Value;
[mag1.saccades, ~, mag1.vel_data] = desaccadeVel_A(mag1.pos_data, mag1.samplerate, 1, windowPre, windowPost, mag1.saccadeThresh, minDataLength);
title('Magnet Channel 1 (Unscaled!)')

% Manget Channel 2
mag2.saccadeThresh = app.SaccadeThresholdMagnetChan2EditField.Value;
[mag2.saccades, ~, mag2.vel_data] = desaccadeVel_A(mag2.pos_data, mag2.samplerate, 1, windowPre, windowPost, mag2.saccadeThresh, minDataLength);
title('Magnet Channel 2 (Unscaled!)')

% Video
vid.saccadeThresh = app.SaccadeThresholdVideoEditField.Value;
[vid.saccades_upsampled , ~, vid.vel_data_upsampled]  = desaccadeVel_A(vid.pos_data_upsampled, mag1.samplerate, 1, windowPre, windowPost, vid.saccadeThresh, minDataLength);
title('Video')

%% SINE FIT

% Magnet Channel 1
mag1Vel = mag1.vel_data;
mag1Vel(mag1.saccades) = nan;
[mag1.vel_amp, mag1.vel_phase, ~, mag1.vel_fit, mag1.vel_fitr2] = fit_sineWave(mag1Vel, mag1.samplerate, freq);

% Manget Channel 2
mag2Vel = mag2.vel_data;
mag2Vel(mag2.saccades) = nan;
[mag2.vel_amp, mag2.vel_phase, ~, mag2.vel_fit, mag2.vel_fitr2] = fit_sineWave(mag2Vel, mag2.samplerate, freq);

% Video
vidVel = vid.vel_data_upsampled;
vidVel(vid.saccades_upsampled) = nan;
[vid.vel_amp,  vid.vel_phase,  ~, vid.vel_fit, vid.vel_fitr2] = fit_sineWave(vidVel, mag1.samplerate, freq);

%% SCALE FACTOR

% Magnet Channel 1
scaleCh1 = vid.vel_amp/mag1.vel_amp;
mag1.vel_scale = scaleCh1;

% Manget Channel 2
scaleCh2 = vid.vel_amp/mag2.vel_amp;
mag2.vel_scale = scaleCh2;

%% Print information to user

% Magnet Channel 1
fprintf('Chan 1: Scale = %.2f\n',mag1.vel_scale)
fprintf('Chan 1: Fit Amp = %.2f\n',mag1.vel_amp)
fprintf('Chan 1: Fit Phase = %.2f\n',mag1.vel_phase)
fprintf('Chan 1: Fit r^2 = %.2f\n',mag1.vel_fitr2)
fprintf('Chan 1: Saccade = %.2f\n\n',mean(mag1.saccades))

% Manget Channel 2
fprintf('Chan 2: Scale = %.2f\n',mag2.vel_scale)
fprintf('Chan 2: Fit Amp = %.2f\n',mag2.vel_amp)
fprintf('Chan 2: Fit Phase = %.2f\n',mag2.vel_phase)
fprintf('Chan 2: Fit r^2 = %.2f\n',mag2.vel_fitr2)
fprintf('Chan 2: Saccade = %.2f\n\n',mean(mag2.saccades))

%% SAVE DATA

mag1Amp = mag1.vel_amp;
r2mag1 = mag1.vel_fitr2;
threshMagChan1 = mag1.saccadeThresh;
mag1Phase = mag1.vel_phase;

mag2Amp = mag2.vel_amp;
r2mag2 = mag2.vel_fitr2;
threshMagChan2 = mag2.saccadeThresh;
mag2Phase = mag2.vel_phase;

vidAmp = vid.vel_amp;
r2vid = vid.vel_fitr2;
threshVid = vid.saccadeThresh;

save(fullfile(cd, [filenameroot '.mat']),'scaleCh1', 'scaleCh2',...
    'vidAmp','mag1Amp','mag1Phase','mag2Amp','mag2Phase',...
    'r2mag1','r2mag2','r2vid','threshVid','threshMagChan1','threshMagChan2', 'freq');

saveAnalysisInfo_APP;

end

%{
TODO
- bottom plots
- Remaining buttons
- Send fmind function to andrew
%}

