function  findmagscaleVel
% Updated 2/23/15 HP
% Simplest version of calibration: fit sine wave to VOR stimulus for both
% video and magnet channels, scale so the gains are the same.
close all;  clc
magthresh =5;
vidthresh = 100;

freq = 1;


% SET ANGLE HERE
theta = 39.8;


%% Load magnet
pathname = cd;
fList = dir;
% temp = arrayfun(@(x) ~isempty([strfind(x.name,'calib.smr')  strfind(x.name,'Calib.smr')]),fList);
temp = arrayfun(@(x) ~isempty(regexpi(x.name,'^.*calib.*\.smr$')  ),fList);
filenameroot = fList(temp).name;
filenameroot = filenameroot(1:end-4);
fullfilename = fullfile(pathname,[filenameroot  '.smr']);

if filenameroot(end)=='R' || ~isempty(strfind(filenameroot,'right')) %% Right eye
magnet = importSpike(fullfilename,[4 7 8 10]); %*** Right eye only
disp('reading right eye')
else
    magnet = importSpike(fullfilename,[4 5 6 10]);%** left eye
end
%% Load video
A=load(fullfile(pathname, 'videoresults.mat'));
results = A.results;


% % CAREFULY: SOME FILES IMG1 and 2 witched
% temp = results;
% results.pupil1 = temp.pupil2;
% results.pupil2 = temp.pupil1;
% results.cr1a = temp.cr2a;
% results.cr1b = temp.cr2b;
% results.cr2a = temp.cr1a;
% results.cr2b = temp.cr1b;

%% Med filt on everything
% n = 3;
% results.pupil1(:,1) = medfilt1(results.pupil1(:,1),n);
% results.cr1a(:,1) = medfilt1(results.cr1a(:,1),n);
% results.pupil2(:,1) = medfilt1(results.pupil2(:,1),n);
% results.cr2b(:,1) = medfilt1(results.cr2b(:,1),n);
% plotresults(results)

[vidH, vidV, ~] = calceyeangle(results, theta);

tvid = (results.time1+results.time2)/2;
tvid = tvid-tvid(1);
dt = mean(diff(tvid));
vidH_vel = diff(vidH)/dt;
[a,b] = fitsine(dt, vidH_vel(1:400), 1,1)
%%
% % Alternate method using just one camera
% % rP = calcEyeRadius(results,theta);
% rP = 50;
% posH1 = real(asind((results.pupil1(:,1) - results.cr1a(:,1))./rP)); % in degrees cam 1 estimate
% posH2 = real(asind((results.pupil2(:,1) - results.cr2b(:,1))./rP)); % in degrees cam 2 estimate
% 
% % Without using CRs at all
% posH1 = real(asind((results.pupil1(:,1) - nanmean(results.pupil1(:,1)))./rP)); % in degrees cam 1 estimate
% posH2 = real(asind((results.pupil2(:,1) -nanmean(results.pupil2(:,1)))./rP)); % in degrees cam 2 estimate
% posH1 = posH1-nanmean(posH1);
% posH2 = posH2-nanmean(posH2);
% vidH = nanmean([posH1, posH2],2)
% figure; plot(tvid, posH1,tvid,posH2)
% 
% std(posH1(tvid>54 & tvid<55))

% vidH_dat = dat(vidH,'vid',1,1/mean(diff(tvid)),tvid(1), tvid(end),'deg');
% vidH_dat.data = inpaint_nans(vidH_dat.data);
% vidH = datlowpass(vidH_dat,50);

%%
function vidAmp = vidTimeFcn(tvid,vidH,freq,tscale)
varsTemp = [sin(2*pi*freq*tvid(:)/tscale) cos(2*pi*freq*tvid(:)/tscale) ones(size(tvid(:)))];
yTemp = [0; diff(vidH)]/mean(diff(tvid));
mask = abs(yTemp)<100;
bVidTemp = regress(yTemp(mask), varsTemp(mask,:));
vidAmp = -sqrt(bVidTemp(1)^2+bVidTemp(2)^2);
end
%%
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
plot(tmag, mag1Velplot,'Color',[.5 .5 .5]); mag1Velplot(~mag1_saccademask) = NaN; 
plot(tmag, mag1Velplot,'r'); ylim([-5 5]); 

mag2Vel = [diff(mag2.data); 0]*samplerateM;
mag2_saccademask = ~isnan(desaccade(mag2Vel,samplerateM,magthresh,0));
mag2Velplot = smooth(mag2Vel,50); 
figure(h(2)); clf; title('Magnet 2 desaccading'); hold on; 
plot(tmag, mag2Velplot,'Color',[.5 .5 .5]);  mag2Velplot(~mag2_saccademask) = NaN;
plot(tmag, mag2Velplot,'r');  ylim([-5 5]); 


%% Desaccade video
vidH_upsample = interp1(tvid,vidH,tmag(:),'linear');

gapCumsum = cumsum(isnan(vidH_upsample));
gapDiff = [0; diff(isnan(vidH_upsample))];
gapIndex = cumsum(gapDiff).*cumsum(gapDiff>0);
maxGap = 250; % 250 ms
gapLength = diff([0; gapCumsum(gapDiff==-1)]);

% Fill in short NaNs
vidH_upsample = inpaint_nans(vidH_upsample);

% Keep the big NaNs NaN
for itemp = 1:length(gapLength)
    if gapLength(itemp) > maxGap
    vidH_upsample(gapIndex==itemp) = NaN;
    end
end



vidVel = [diff(vidH_upsample); 0]*samplerateM;
vid_saccademask = ~isnan(desaccade(vidVel,samplerateM,vidthresh,0)); 

tVidGood = tvid(~isnan(vidH));
vid_saccademask(tmag>tVidGood(end)) = 0;

vidVelplot = smooth(inpaint_nans(vidVel),50,'moving'); 

figure(h(3)); clf; title('Video desaccading'); hold on
plot(tmag, vidVelplot,'Color',.5*[1 1 1]);  vidVelplot(~vid_saccademask) = NaN;
plot(tmag, vidVelplot,'r');  ylim([-50 50]); 

%% Average position of each

meanMag1Pos = nanmean(mag1.data(vid_saccademask & mag1_saccademask));
meanMag2Pos = nanmean(mag2.data(vid_saccademask & mag2_saccademask));
meanVidPos = nanmean(vidH_upsample(vid_saccademask));



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
    'r2mag1','r2mag2','r2vid','vidthresh','magthresh','freq',...
    'meanMag1Pos','meanMag2Pos','meanVidPos');

%% Plot fits
xlims = [0 min(30,tmag(end))];
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