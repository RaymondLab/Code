function  findmagscaleVel
% Updated 2/23/15 HP
% Simplest version of calibration: fit sine wave to VOR stimulus for both
% video and magnet channels, scale so the gains are the same.

close all;
magthresh = 5; % 15
vidthresh = 100; % 100
freq = 1;
spike2_file_extension = '.smrx';

%% Load magnet
pathname = cd;
[~, filenameroot]= fileparts(pathname);
fullfilename = fullfile(pathname,[filenameroot spike2_file_extension]);

% Left Eye
magnet = importSpike(fullfilename,[4 5 6 10]);

% Right Eye
% magnet = importSpike(fullfilename,[4 7 8 10]);

%% Load video
A = load(fullfile(pathname, 'videoresults.mat'));
results = A.results;
[vidH, vidV, ~] = calceyeangle(results);

% Timestamp vector
% Camera 1
%tvid = results.time1;
% Camera 2
tvid = results.time2;

tvid = tvid-tvid(1);

function vidAmp = vidTimeFcn(tvid,vidH,freq,tscale)
    varsTemp = [sin(2*pi*freq*tvid(:)/tscale) cos(2*pi*freq*tvid(:)/tscale) ones(size(tvid(:)))];
    yTemp = [0; diff(vidH)]/mean(diff(tvid));
    mask = abs(yTemp)<100;
    bVidTemp = regress(yTemp(mask), varsTemp(mask,:));
    vidAmp = -sqrt(bVidTemp(1)^2+bVidTemp(2)^2);
end

[tscale, temp] = fminsearchbnd(@(x)vidTimeFcn(tvid,vidH,freq,x),1,.7, 1.4);

tvid = tvid/tscale;%.995;

Samplerate_Video = 1/mean(diff(tvid))

%% Subselect and desaccade magnet
lightpulse = magnet(end).data;

if exist(fullfile(pathname,[filenameroot '.xlsx']))
    seg(1) = xlsread(fullfile(pathname,[filenameroot '.xlsx']),'D2:D2');
else
    seg(1) = lightpulse(1);
end

seg(2) = seg(1)+tvid(end)

magnetSeg = resettime(datseg(magnet,seg));
samplerateM = magnetSeg(1).samplerate;
magnetSeg(1).data = smooth([diff(smooth(magnetSeg(1).data,25)); 0]*samplerateM,25); % Convert to velocity
magnetSeg(1).units = 'deg/s'; magnetSeg(1).chanlabel = 'hhvel';

% Filter Magnet Position Traces with 100Hz low pass filter
mag1 = datlowpass(magnetSeg(2),100);
mag2 = datlowpass(magnetSeg(3),100);
tmag = dattime(mag1);

% Upsample Video Traces
vidH_upsample = interp1(tvid,vidH,tmag(:),'linear');
vidH_upsample = inpaint_nans(vidH_upsample);

% Create Velocity Traces
mag1Vel = [diff(mag1.data); 0]*samplerateM;
mag2Vel = [diff(mag2.data); 0]*samplerateM;
vidVel = [diff(vidH_upsample); 0]*samplerateM;

% Desaccade Velocity Traces
mag1_saccademask = ~isnan(desaccade(mag1Vel,samplerateM,magthresh,0));
mag2_saccademask = ~isnan(desaccade(mag2Vel,samplerateM,magthresh,0));
vid_saccademask = ~isnan(desaccade(vidVel,samplerateM,vidthresh,0));

% New Desaccade TEMP!!! For testing

% y1 = sin(2*pi*freq*tmag(:));
% y2 = cos(2*pi*freq*tmag(:));
% const = ones(size(y1));
% vars = [y1 y2 const];
% 
% keep = abs(magnetSeg(2).data) < 5*std(abs(magnetSeg(2).data)) + mean(abs(magnetSeg(2).data));
% b = regress(eyeVel(keep), vars(keep,:));
% fit1 = vars *b;
% 
% params.NoiseAnalysis = 0;
% params.saccadeThresh = 1000;
% [omitH, omitCenters, pos_filt, vel_pfilt] = desaccadeVel3(magnetSeg(2).data, samplerateM, .05, .05, freq, params, fit1);



% Smooth Velocity Traces (For plotting ONLY)
mag1Velplot = smooth(mag1Vel,50);
mag2Velplot = smooth(mag2Vel,50);
vidVelplot = smooth(inpaint_nans(vidVel),50,'moving');

%% Plot Desacadded Traces
ha = tight_subplot(3,1,[.025 .025],[.025 .025],[.015 .01]);

axes(ha(1))
title('Magnet 1 Desaccading, Unscaled'); hold on;
plot(tmag, mag1Velplot,'k'); mag1Velplot(~mag1_saccademask) = NaN;
plot(tmag, mag1Velplot,'b', 'LineWidth', .5); 
ylim([-2 2]);

axes(ha(2))
title('Magnet 2 Desaccading, Unscaled'); hold on;
plot(tmag, mag2Velplot,'k');  mag2Velplot(~mag2_saccademask) = NaN;
plot(tmag, mag2Velplot,'b', 'LineWidth', .5);  
ylim([-2 2]);

axes(ha(3)) 
title('Video Desaccading'); hold on;
plot(tmag, vidVelplot,'k');  vidVelplot(~vid_saccademask) = NaN;
plot(tmag, vidVelplot,'b', 'LineWidth', .5);  
ylim([-25 25]);

%% Do sine fit on magnet and video sine waves
y1 = sin(2*pi*freq*tmag(:));
y2 = cos(2*pi*freq*tmag(:));
const = ones(size(y1));
vars = [y1 y2 const];

% ------------ Chair ------------
[bHead,bint,r,rint,stat] = regress(magnetSeg(1).data, vars);
headAmp = sqrt(bHead(1)^2+bHead(2)^2)
headPhase = rad2deg(atan2(bHead(2),bHead(1)));

% ------------ MAGNET 1------------
[bMag1,bint,r,rint,stat] = regress(mag1Vel(mag1_saccademask), vars(mag1_saccademask,:));
mag1Amp = sqrt(bMag1(1)^2+bMag1(2)^2);
mag1Phase = mod((rad2deg(atan2(bMag1(2),bMag1(1))) - headPhase),360)-180;
r2mag1 = stat(1);

% ------------ MAGNET 2------------
[bMag2,bint,r,rint,stat] = regress(mag2Vel(mag2_saccademask), vars(mag2_saccademask,:));
mag2Amp = sqrt(bMag2(1)^2+bMag2(2)^2);
mag2Phase = mod((rad2deg(atan2(bMag2(2),bMag2(1))) - headPhase),360)-180;
r2mag2 = stat(1);

% ------------ VIDEO ------------
[bVid,bint,r,rint,stat] = regress(vidVel(vid_saccademask), vars(vid_saccademask,:));
vidAmp = sqrt(bVid(1)^2+bVid(2)^2);
vidPhase = rad2deg(atan2(bVid(2), bVid(1)));
r2vid = stat(1);

%% save scale factor
% Add term for 180 deg phase - negate?
if r2mag1>r2mag2
    scaleCh1 = vidAmp/mag1Amp * (2*(abs(mag1Phase)<90)-1); % Change sign if needed
    scaleCh2 = 0;
else
    scaleCh1 = 0;
    scaleCh2 = vidAmp/mag2Amp * (2*(abs(mag2Phase)<90)-1); % Change sign if needed
end
fprintf('scaleCh1 = %.2f, scaleCh2 = %.2f\n',scaleCh1, scaleCh2)
fprintf('r2   Ch1 = %.4f, r2   Ch2 = %.4f\n',r2mag1, r2mag2)
save(fullfile(cd, [filenameroot '.mat']),'scaleCh1', 'scaleCh2',...
    'vidAmp','mag1Amp','mag1Phase','mag2Amp','mag2Phase',...
    'r2mag1','r2mag2','r2vid','vidthresh','magthresh','freq');

%% Plot fits
axes(ha(1)); hold on; 
plot(tmag,vars*bMag1,'r-', 'LineWidth', 1);
text(1, 1.6, sprintf('Amp = %.3f\nr^2 = %.3f\nScale Factor = %.3f',mag1Amp, r2mag1, scaleCh1),'BackgroundColor','w')
yticklabels(yticks)

axes(ha(2)); hold on;
plot(tmag,vars*bMag2,'r-', 'LineWidth', 1);
text(1, 1.6, sprintf('Amp = %.3f\nr^2 = %.3f\nScale Factor = %.3f',mag2Amp, r2mag2, scaleCh2),'BackgroundColor','w')
yticklabels(yticks)

axes(ha(3)); hold on; 
plot(tmag, vars*bVid,'r-', 'LineWidth', 1);
text(1, 20, sprintf('Amp = %.3f\nr^2 = %.3f',vidAmp, r2vid),'BackgroundColor','w')
yticklabels(yticks)

% cosmetics
xlabel('s')
linkaxes(ha, 'x')
xticks(0:5:max(xticks))
xticklabels(0:5:max(xticks))
xlim([0, 40])
box off

% Save Figures
savefig('Calib_Desaccading_Summary.fig')
%print('Calib_Desaccading_Summary', '-dpdf')

end
