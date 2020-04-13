function vars = getScaleFactors_APP(app, vars)

%%
try
    a = vars.mag1;
catch
    vid = [];
    mag1 = [];
    mag2 = [];
    head = [];
end

freq = vars.CaliStimFreq;
%% LOAD MAGNET
[~, filenameroot]= fileparts(cd);
fullfilename = fullfile(cd,[filenameroot '.smr']);

if app.LeftEyeCheckBox.Value
    % Left Eye (default)
    vars.magnetData = importSpike(fullfilename,[4 5 6 10]);
else
    % Right Eye
    vars.magnetData = importSpike(fullfilename,[4 7 8 10]);
end

%% LOAD VIDEO
A = load(fullfile(cd, 'videoresults_cam1.mat'));
B = load(fullfile(cd, 'videoresults_cam2.mat'));

vars.frameData_cam1 = A.frameData;
vars.frameData_cam2 = B.frameData;

vid.pos_data = calceyeangle_APP(vars.frameData_cam1, vars.frameData_cam2);

vid.percent_frames_missed = sum(int64(isnan(vid.pos_data)))*100/length(vid.pos_data);

if app.Camera2TimestampsCheckBox.Value
    % Camera 2 (default)
    vid.time = [vars.frameData_cam1.time2];
else
    % Camera 1
    vid.time = [vars.frameData_cam1.time1];
end
vid.time = vid.time-vid.time(1);
[vars.tscale, ~] = fminsearchbnd(@(x)vidTimeFcn_APP(app, vid.time,vid.pos_data',freq,x),1,.7, 1.4);
vid.time = vid.time/vars.tscale;%.995;
vid.samplerate = 1/mean(diff(vid.time));

%% Select Proper Segment
vars.lightpulse = vars.magnetData(end).data;
vars.seg(1) = vars.lightpulse(1);
vars.seg(2) = vars.seg(1)+vid.time(end);

vars.magnetSeg = resettime(datseg(vars.magnetData,vars.seg));
mag1.samplerate = vars.magnetSeg(1).samplerate;
mag2.samplerate = vars.magnetSeg(2).samplerate;
vars.magnetSeg(1).data = smooth([diff(smooth(vars.magnetSeg(1).data,25)); 0]*mag1.samplerate ,25); % Convert to velocity
vars.magnetSeg(1).units = 'deg/s'; vars.magnetSeg(1).chanlabel = 'hhvel';

vars.mag1 = vars.magnetSeg(2);
vars.mag1.data = double(vars.mag1.data);
vars.mag2 = vars.magnetSeg(3);
vars.mag2.data = double(vars.mag2.data);

mag1.pos_data = vars.mag1.data;
mag2.pos_data = vars.mag2.data;
mag1.time = dattime(vars.mag1);
mag2.time = dattime(vars.mag2);

%% Upsample Video Traces
vid.pos_data_upsampled = interp1(vid.time,vid.pos_data,mag1.time(:),'spline');
vid.pos_data_upsampled = inpaint_nans(vid.pos_data_upsampled);
vid.time_upsampled = mag1.time;

%% Desaccade
windowPre = app.SaccadeWindowmsEditField.Value;
windowPost = app.SaccadeWindowEditField_2.Value;
minDataLength = app.MinimumGoodDataLengthEditField.Value;
mag1.saccadeThresh = app.SaccadeThresholdMagnetChan1EditField.Value;
mag2.saccadeThresh = app.SaccadeThresholdMagnetChan2EditField.Value;
vid.saccadeThresh = app.SaccadeThresholdVideoEditField.Value;

[mag1.saccades, ~, mag1.vel_data] = desaccadeVel_A(mag1.pos_data, mag1.samplerate, 1, windowPre, windowPost, mag1.saccadeThresh, minDataLength);
title('Magnet Channel 1 (Unscaled!)')
[mag2.saccades, ~, mag2.vel_data] = desaccadeVel_A(mag2.pos_data, mag2.samplerate, 1, windowPre, windowPost, mag2.saccadeThresh, minDataLength);
title('Magnet Channel 2 (Unscaled!)')
[vid.saccades_upsampled , ~, vid.vel_data_upsampled]  = desaccadeVel_A(vid.pos_data_upsampled, mag1.samplerate, 1, windowPre, windowPost, vid.saccadeThresh, minDataLength);
title('Video')

mag1.saccades_all = mag1.saccades | mag2.saccades | vid.saccades_upsampled;
mag2.saccades_all = mag1.saccades | mag2.saccades | vid.saccades_upsampled;
vid.saccades_all = mag1.saccades | mag2.saccades | vid.saccades_upsampled;

%% SINE FIT FOR MAGET AND VIDEO

% Chair
[head.vel_Amp, head.vel_phase, ~, head.vel_fit,  head.vel_fitr2] = fit_sineWave(vars.magnetSeg(1).data, mag1.samplerate, freq);

% MAGNET 1
mag1Vel = mag1.vel_data;
mag1Vel(mag1.saccades) = nan;
[mag1.vel_amp, mag1.vel_phase, ~, mag1.vel_fit, mag1.vel_fitr2] = fit_sineWave(mag1Vel, mag1.samplerate, freq);

% MAGNET 2
mag2Vel = mag2.vel_data;
mag2Vel(mag2.saccades) = nan;
[mag2.vel_amp, mag2.vel_phase, ~, mag2.vel_fit, mag2.vel_fitr2] = fit_sineWave(mag2Vel, mag2.samplerate, freq);

% VIDEO
vidVel = vid.vel_data_upsampled;
vidVel(vid.saccades_upsampled) = nan;
[vid.vel_amp,  vid.vel_phase,  ~, vid.vel_fit, vid.vel_fitr2] = fit_sineWave(vidVel, mag1.samplerate, freq);

%% CALCULATE SCALE FACTOR
scaleCh1 = vid.vel_amp/mag1.vel_amp * (2*(abs(mag1.vel_phase)<90)-1);
mag1.vel_scale = scaleCh1;
vars.scaleCh1 = scaleCh1;

fprintf('Chan 1: Scale = %.2f\n',mag1.vel_scale)
fprintf('Chan 1: Fit Amp = %.2f\n',mag1.vel_amp)
fprintf('Chan 1: Fit r^2 = %.2f\n',mag1.vel_fitr2)
fprintf('Chan 1: Saccade = %.2f\n\n',mean(mag1.saccades))

scaleCh2 = vid.vel_amp/mag2.vel_amp * (2*(abs(mag2.vel_phase)<90)-1);
mag2.vel_scale = scaleCh2;
vars.scaleCh2 = scaleCh2;

fprintf('Chan 2: Scale = %.2f\n',mag2.vel_scale)
fprintf('Chan 2: Fit Amp = %.2f\n',mag2.vel_amp)
fprintf('Chan 2: Fit r^2 = %.2f\n',mag2.vel_fitr2)
fprintf('Chan 2: Saccade = %.2f\n\n',mean(mag2.saccades))

%% SAVE DATA
vidAmp = vid.vel_amp;

r2vid = vid.vel_fitr2;
threshVid = vid.saccadeThresh;

mag1Amp = mag1.vel_amp;
mag1Phase = mag1.vel_phase;
r2mag1 = mag1.vel_fitr2;
threshMagChan1 = mag1.saccadeThresh;

mag2Amp = mag2.vel_amp;
mag2Phase = mag2.vel_phase;
r2mag2 = mag2.vel_fitr2;
threshMagChan2 = mag2.saccadeThresh;

save(fullfile(cd, [filenameroot '.mat']),'scaleCh1', 'scaleCh2',...
    'vidAmp','mag1Amp','mag1Phase','mag2Amp','mag2Phase',...
    'r2mag1','r2mag2','r2vid','threshVid','threshMagChan1','threshMagChan2', 'freq');

saveAnalysisInfo_APP;

end