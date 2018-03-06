function  findmagscaleVel
% Updated 2/23/15 HP
% Simplest version of calibration: fit sine wave to VOR stimulus for both
% video and magnet channels, scale so the gains are the same.
close all; 
magthresh = 5; % 15
vidthresh = 100; % 100


freq = 1;

%% Load magnet
pathname = cd;
[~, filenameroot]= fileparts(pathname);
fullfilename = fullfile(pathname,[filenameroot '.smr']);
magnet = importSpike(fullfilename,[4 5 6 10]);%** left eye
% magnet = importSpike(fullfile(pathname,[filenameroot '.smr']),[4 7 8 10]); %*** Right eye only

%% Load video
A=load(fullfile(pathname, 'videoresults.mat'));
results = A.results;
[vidH, vidV, ~] = calceyeangle(results);
% tvid = (results.time1+results.time2)/2;
% tvid = results.time1;
tvid = results.time2;

% tvid = results.time3;
tvid = tvid-tvid(1);
% 
function vidAmp = vidTimeFcn(tvid,vidH,freq,tscale)
varsTemp = [sin(2*pi*freq*tvid(:)/tscale) cos(2*pi*freq*tvid(:)/tscale) ones(size(tvid(:)))];
yTemp = [0; diff(vidH)]/mean(diff(tvid));
mask = abs(yTemp)<100;
bVidTemp = regress(yTemp(mask), varsTemp(mask,:));
vidAmp = -sqrt(bVidTemp(1)^2+bVidTemp(2)^2);
end

[tscale, temp] = fminsearchbnd(@(x)vidTimeFcn(tvid,vidH,freq,x),1,.7, 1.4)
temp
tvid = tvid/tscale;%.995;

samplerateV = 1/mean(diff(tvid))

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

% filter with 100 Hz low pass filter
mag1 = datlowpass(magnetSeg(2),100); 
mag2 = datlowpass(magnetSeg(3),100);
tmag = dattime(mag1);

mag1Vel = [diff(mag1.data); 0]*samplerateM;
mag1_saccademask = ~isnan(desaccade(mag1Vel,samplerateM,magthresh,0)); 
mag1Velplot = smooth(mag1Vel,50);  
h = 1:3;
figure(h(1)); clf; title('Magnet 1 desaccading'); hold on;  
plot(tmag, mag1Velplot,'k'); mag1Velplot(~mag1_saccademask) = NaN; 
plot(tmag, mag1Velplot,'r'); ylim([-5 5]); 

mag2Vel = [diff(mag2.data); 0]*samplerateM;
mag2_saccademask = ~isnan(desaccade(mag2Vel,samplerateM,magthresh,0));
mag2Velplot = smooth(mag2Vel,50); 
figure(h(2)); clf; title('Magnet 2 desaccading'); hold on; 
plot(tmag, mag2Velplot,'k');  mag2Velplot(~mag2_saccademask) = NaN;
plot(tmag, mag2Velplot,'r');  ylim([-5 5]); 


%% Desaccade video
vidH_upsample = interp1(tvid,vidH,tmag(:),'linear');
vidH_upsample = inpaint_nans(vidH_upsample);
vidVel = [diff(vidH_upsample); 0]*samplerateM;
vid_saccademask = ~isnan(desaccade(vidVel,samplerateM,vidthresh,0)); 

vidVelplot = smooth(inpaint_nans(vidVel),50,'moving'); 

figure(h(3)); clf; title('Video desaccading'); hold on
plot(tmag, vidVelplot,'k');  vidVelplot(~vid_saccademask) = NaN;
plot(tmag, vidVelplot,'r');  ylim([-50 50]); 


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
mag1Amp = sqrt(bMag1(1)^2+bMag1(2)^2)
mag1Phase = mod((rad2deg(atan2(bMag1(2),bMag1(1))) - headPhase),360)-180;
r2mag1 = stat(1);

% ------------ MAGNET 2------------
[bMag2,bint,r,rint,stat] = regress(mag2Vel(mag2_saccademask), vars(mag2_saccademask,:));
mag2Amp = sqrt(bMag2(1)^2+bMag2(2)^2)
mag2Phase = mod((rad2deg(atan2(bMag2(2),bMag2(1))) - headPhase),360)-180;
r2mag2 = stat(1);

% ------------ VIDEO ------------
[bVid,bint,r,rint,stat] = regress(vidVel(vid_saccademask), vars(vid_saccademask,:));
vidAmp = sqrt(bVid(1)^2+bVid(2)^2)
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
xlims = [0 min(40,tmag(end))];
figure(h(1)); hold on; plot(tmag,vars*bMag1,'k-'); box off;xlim(xlims)
text(1, 4, sprintf('amp = %.3f, r2 = %.3f',mag1Amp, r2mag1),'BackgroundColor','w')
saveas(gcf, 'fitMagnet1.jpg');

figure(h(2)); hold on; plot(tmag,vars*bMag2,'k-'); box off;xlim(xlims)
text(1, 4, sprintf('amp = %.3f, r2 = %.3f',mag2Amp, r2mag2),'BackgroundColor','w')
saveas(gcf, 'fitMagnet2.jpg');

figure(h(3)); hold on; plot(tmag, vars*bVid,'k-'); box off;xlim(xlims)
text(1, 40, sprintf('amp = %.3f, r2 = %.3f',vidAmp, r2vid),'BackgroundColor','w')
saveas(gcf, 'fitVideo.jpg');


end