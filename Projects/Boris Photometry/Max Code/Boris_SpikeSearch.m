savename = 'd\d_100Hz';
savename=strcat(savename,'.mat');
load(savename)

% Mouse Specific
start = camtime([14869; 15269; 15949; 17934; 21829; 25029]) * 100;
stop = camtime([14989; 15589; 17432; 19949; 23682; 27909]) * 100;
len = [200; 200; 400; 800; 800; 1600];

samplerate = 101.7253; % mouse 115, recording 1 (only recording) 

% plot raw
figure()
plot(sig_405_RS, 'k'); hold on
plot(sig_472_RS, 'b')
legend('Control', 'GCaMP')

%% Filter Design
N = 3;
fc = [.3 10];
[bb,aa] = butter(N, fc/samplerate, 'bandpass');
sig_405_RS_Filt = filter(bb, aa, (sig_405_RS));
sig_472_RS_Filt = filter(bb, aa, (sig_472_RS));

%% Plot filtered versions
seg = 5;
thresh = 1.5;

figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(sig_405_RS(start(seg):stop(seg)), 'b'); hold on
plot(sig_472_RS(start(seg):stop(seg)), 'b'); hold on
vline([0:len(seg):length(sig_405_RS_Filt(start(seg):stop(seg)))])

subplot(3,1,2)
plot(sig_472_RS_Filt(start(seg):stop(seg)), 'b'); hold on
plot(sig_405_RS_Filt(start(seg):stop(seg)),'k'); hold on

% cosmetics
ylim([-4 4])
title(seg)
hline(thresh)
hline(-1*thresh)
vline([0:len(seg):length(sig_405_RS_Filt(start(seg):stop(seg)))])


% difference
subplot(3,1,3)
plot(sig_472_RS_Filt(start(seg):stop(seg)) - sig_405_RS_Filt(start(seg):stop(seg)))

% cosmetics
ylim([-4 4])
hline(thresh)
hline(-1*thresh)
vline([0:len(seg):length(sig_405_RS_Filt(start(seg):stop(seg)))])


% bar
temp.segLen = len(seg);
temp.special = 0;
Boris_spikeAnalysis(sig_472_RS_Filt(start(seg):stop(seg)) - sig_405_RS_Filt(start(seg):stop(seg)), temp, thresh)
