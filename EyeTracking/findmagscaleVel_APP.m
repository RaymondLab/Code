function vars = findmagscaleVel_APP(app, vars)

freq = app.CalibrationStimFrequencyEditField.Value;


%% LOAD MAGNET
pathname = cd;
[~, filenameroot]= fileparts(pathname);
fullfilename = fullfile(pathname,[filenameroot '.smr']);

if app.LeftEyeCheckBox.Value
    % Left Eye (default)
    vars.magnetData = importSpike(fullfilename,[4 5 6 10]);
else
    % Right Eye
    vars.magnetData = importSpike(fullfilename,[4 7 8 10]);
end

%% LOAD VIDEO
A = load(fullfile(pathname, 'videoresults_cam1.mat'));
B = load(fullfile(pathname, 'videoresults_cam2.mat'));

vars.vidResults_cam1 = A.results;
vars.vidResults_cam2 = B.results;

vars.vidResults = A.results;
vars.vidResults.pupil1 = vars.vidResults_cam1.pupil;
vars.vidResults.cr1a = vars.vidResults_cam1.cra;
vars.vidResults.cr1b = vars.vidResults_cam1.crb;
vars.vidResults.pupil2 = vars.vidResults_cam2.pupil;
vars.vidResults.cr2a = vars.vidResults_cam2.cra;
vars.vidResults.cr2b = vars.vidResults_cam2.crb;


[vars.vidH, vars.vidV, ~] = calceyeangle(vars.vidResults);
vars.percent_frames_missed = sum(int64(isnan(vars.vidH)))*100/length(vars.vidH);
if app.Camera2TimestampsCheckBox.Value
    % Camera 2 (default)
    vars.tvid = vars.vidResults.time2;
else
    % Camera 1
    vars.tvid = vars.vidResults.time1;
end
vars.tvid = vars.tvid-vars.tvid(1);
[vars.tscale, temp] = fminsearchbnd(@(x)vidTimeFcn_APP(app, vars.tvid,vars.vidH,freq,x),1,.7, 1.4);
vars.tvid = vars.tvid/vars.tscale;%.995;
vars.samplerate_Video = 1/mean(diff(vars.tvid));


%% Select Proper Segment
vars.lightpulse = vars.magnetData(end).data;
vars.seg(1) = vars.lightpulse(1);
vars.seg(2) = vars.seg(1)+vars.tvid(end);

vars.magnetSeg = resettime(datseg(vars.magnetData,vars.seg));
vars.samplerate_Magnet = vars.magnetSeg(1).samplerate;
vars.magnetSeg(1).data = smooth([diff(smooth(vars.magnetSeg(1).data,25)); 0]*vars.samplerate_Magnet,25); % Convert to velocity
vars.magnetSeg(1).units = 'deg/s'; vars.magnetSeg(1).chanlabel = 'hhvel';

vars.mag1 = vars.magnetSeg(2);
vars.mag1.data = double(vars.mag1.data);
vars.mag2 = vars.magnetSeg(3);
vars.mag2.data = double(vars.mag2.data);
vars.tmag = dattime(vars.mag1);

%% Upsample Video Traces
vars.vidH_upsample = interp1(vars.tvid,vars.vidH,vars.tmag(:),'linear');
vars.vidH_upsample = inpaint_nans(vars.vidH_upsample);
vars.vidV_upsample = interp1(vars.tvid,vars.vidV,vars.tmag(:),'linear');
vars.vidV_upsample = inpaint_nans(vars.vidV_upsample);

%% Desaccade
windowPre = app.SaccadeWindowmsEditField.Value;
windowPost = app.SaccadeWindowEditField_2.Value;
minDataLength = app.MinimumGoodDataLengthEditField.Value;

threshMagChan1 = app.SaccadeThresholdMagnetChan1EditField.Value;
threshMagChan2 = app.SaccadeThresholdMagnetChan2EditField.Value;

threshVid = app.SaccadeThresholdVideoEditField.Value;

[vars.sacLoc_mag1, ~, vars.mag1Vel] = desaccadeVel_A(vars.mag1.data, vars.samplerate_Magnet, 1, windowPre, windowPost, threshMagChan1, minDataLength);
title('Magnet Channel 1 (Unscaled!)')
[vars.sacLoc_mag2, ~, vars.mag2Vel] = desaccadeVel_A(vars.mag2.data, vars.samplerate_Magnet, 1, windowPre, windowPost, threshMagChan2, minDataLength);
title('Magnet Channel 2 (Unscaled!)')
[vars.sacLoc_vid , ~, vars.vidVel]  = desaccadeVel_A(vars.vidH_upsample,vars.samplerate_Magnet, 1, windowPre, windowPost, threshVid, minDataLength);
title('Video')


%% SINE FIT FOR MAGET AND VIDEO
y1 = sin(2*pi*freq*vars.tmag(:));
y2 = cos(2*pi*freq*vars.tmag(:));
const = ones(size(y1));
vars.vars = [y1 y2 const];

% ------------ Chair -------------
[vars.bHead,~,~,~,~] = regress(vars.magnetSeg(1).data, vars.vars);
headAmp = sqrt(vars.bHead(1)^2+vars.bHead(2)^2);
vars.headAmp = headAmp;
headPhase = rad2deg(atan2(vars.bHead(2),vars.bHead(1)));

% ------------ MAGNET 1------------
[vars.bMag1,~,~,~,stat] = regress(vars.mag1Vel(~vars.sacLoc_mag1), vars.vars(~vars.sacLoc_mag1,:));
mag1Amp = sqrt(vars.bMag1(1)^2+vars.bMag1(2)^2);
vars.mag1Amp = mag1Amp;
mag1Phase = mod((rad2deg(atan2(vars.bMag1(2),vars.bMag1(1))) - headPhase),360)-180;
r2mag1 = stat(1);
vars.r2mag1 = r2mag1;

% ------------ MAGNET 2------------
[vars.bMag2,~,~,~,stat] = regress(vars.mag2Vel(~vars.sacLoc_mag2), vars.vars(~vars.sacLoc_mag2,:));
mag2Amp = sqrt(vars.bMag2(1)^2+vars.bMag2(2)^2);
vars.mag2Amp = mag2Amp;
mag2Phase = mod((rad2deg(atan2(vars.bMag2(2),vars.bMag2(1))) - headPhase),360)-180;
r2mag2 = stat(1);
vars.r2mag2 = r2mag2;

% ------------ VIDEO ------------
[vars.bVid,~,~,~,stat] = regress(vars.vidVel(~vars.sacLoc_vid), vars.vars(~vars.sacLoc_vid,:));
vidAmp = sqrt(vars.bVid(1)^2+vars.bVid(2)^2);
vars.vidAmp = vidAmp;
vidPhase = rad2deg(atan2(vars.bVid(2), vars.bVid(1)));
r2vid = stat(1);
vars.r2vid = r2vid;


%% SAVE SCALE FACTOR
% Add term for 180 deg phase - negate?
if r2mag1>r2mag2
    scaleCh1 = vidAmp/mag1Amp * (2*(abs(mag1Phase)<90)-1); % Change sign if needed
    vars.scaleCh1x = scaleCh1;
    vars.scaleCh1 = scaleCh1;
    scaleCh2 = 0;
    vars.scaleCh2 = scaleCh2;
    vars.chosenMag = vars.mag1.data;
    vars.chosenMagVel = vars.mag1Vel;
    vars.chosenScale = scaleCh1;
    vars.chosenMagSacLoc = vars.sacLoc_mag1;
    vars.scaleCh2x = vidAmp/mag2Amp * (2*(abs(mag2Phase)<90)-1);
    vars.notChosenMagScaleLoc = vars.sacLoc_mag2;
else
    scaleCh1 = 0;
    vars.scaleCh1 = scaleCh1;
    scaleCh2 = vidAmp/mag2Amp * (2*(abs(mag2Phase)<90)-1); % Change sign if needed
    vars.scaleCh2x = scaleCh2;
    vars.scaleCh2 = scaleCh2;
    vars.chosenMag = vars.mag2.data;
    vars.chosenMagVel = vars.mag2Vel;
    vars.chosenScale = scaleCh2;
    vars.chosenMagSacLoc = vars.sacLoc_mag2;
    vars.scaleCh1x = vidAmp/mag1Amp * (2*(abs(mag1Phase)<90)-1);
    vars.notChosenMagScaleLoc = vars.sacLoc_mag1;
end
fprintf('Scale: Chan 1 = %.2f\nScale: Chan 2 = %.2f\n',vars.scaleCh1, vars.scaleCh2)
fprintf('r^2: Chan 1 = %.4f\nr^2: Chan 2 = %.4f\n',r2mag1, r2mag2)
save(fullfile(cd, [filenameroot '.mat']),'scaleCh1', 'scaleCh2',...
    'vidAmp','mag1Amp','mag1Phase','mag2Amp','mag2Phase',...
    'r2mag1','r2mag2','r2vid','threshVid','threshMagChan1','threshMagChan2', 'freq');

end