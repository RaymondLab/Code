function [VelSineFit, amp, phase] = desaccadeAndSineFit(eye_pos_raw)

%% PARAMETERS
samplerate = 1000;
presaccade = 50;
postsaccade = 50;
freq = 1;

segLength = length(eye_pos_raw);
segTime = (1:segLength)/samplerate;
eyeVel = diff(eye_pos_raw);

params.saccadeThresh = 10000;
params.NoiseAnalysis = 0;

%% REMOVE OBVIOUS SACACDES/ARTIFACTS
y1 = sin(2*pi*freq*segTime(:));
y2 = cos(2*pi*freq*segTime(:));
constant = ones(segLength,1);
vars = [y1 y2 constant];
keep = abs(eyeVel) < 5*std(abs(eyeVel)) + mean(abs(eyeVel));
b = regress(eyeVel(keep), vars(keep,:));
fit1 = vars *b;

%% DESACCADE
[omitH, omitCenters, eye_pos_filt, eye_vel_pfilt] = desaccadeVel3(eye_pos_raw, samplerate, presaccade, postsaccade, freq, params, fit1);

%% MAKE SINEFIT
[b,~,~,~,stat] = regress(eye_vel_pfilt(~omitH), vars(~omitH,:));
amp = sqrt(b(1)^2+b(2)^2);
phase = rad2deg(atan2(b(2), b(1)));
VelSineFit = sin(2*pi*freq*segTime + deg2rad(phase+180))*amp;


end
