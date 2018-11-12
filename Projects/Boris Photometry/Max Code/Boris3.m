clear;clc;%close all
dbstop if error
% Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Experiment 2\drive-download-20180713T210854Z-001\Raymond_071318_LFP_M2\Recording_1
savename = 'd\d_100Hz';
savename=strcat(savename,'.mat');
load(savename)
samplerate = 101.7253; % mouse 115, recording 1 (only recording) 

%% What signal to use? 
%sig = sig_472_RS;
sig = sig_405_RS;
min_height = 200;

% remove initial artifact?
sig = sig(200:end);
% hack to make math easier?
sig = sig(1:end-80);

%% Figure A: Plot signal over time
figure(); subplot(2,1,1); plot(sig);
%ylim([150 170])
xlim([0 25000])

N = 2;
fc = .3;
[bb,aa] = butter(N, fc/samplerate, 'high');
sig_filt = filter(bb,aa,sig);

subplot(2,1,2); plot(sig_filt);
ylim([-5 5])
xlim([0 25000])


figure()
L = length(sig_filt);
f = samplerate*(0:(L/2))/L;
Y = fft(sig);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

plot(f,P1) 
title('Single-Sided Amplitude Spectrum of S(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Analysis 1: Peak 'height' v Max slope during rise-to-height
[Pos_Peaks, Pos_locs] = findpeaks(sig);
peaks_p = [Pos_locs, Pos_Peaks];
[Neg_Peaks, Neg_locs] = findpeaks(sig * -1);
peaks_n = [Neg_locs, Neg_Peaks*-1];

% add t=1 to neg peaks, t=end to pos peaks
peaks_n = [1, sig(1); peaks_n];
peaks_p = [peaks_p; length(sig), sig(end)];

% deltaTo_ of peaks [locs, peakVal, deltaTo_]
deltaTo_p = peaks_p(:,2) - peaks_n(:,2);
peaks_p = [peaks_p deltaTo_p];
deltaTo_n = peaks_p(1:end-1,2) - peaks_n(2:end,2);
peaks_n = [peaks_n [NaN; deltaTo_n]];

% if sig == sig_472_RS
%     % add t=1 to neg peaks, t=end to pos peaks
%     peaks_n = [1, sig(1); peaks_n];
%     peaks_p = [peaks_p; length(sig), sig(end)];
% 
%     % deltaTo_ of peaks [locs, peakVal, deltaTo_]
%     deltaTo_p = peaks_p(:,2) - peaks_n(:,2);
%     peaks_p = [peaks_p deltaTo_p];
%     deltaTo_n = peaks_p(1:end-1,2) - peaks_n(2:end,2);
%     peaks_n = [peaks_n [NaN; deltaTo_n]];
%     
% elseif sig == sig_405_RS
%     % add t=1 to p peaks, t=end to n peaks
%     peaks_p = [1, sig(1); peaks_p];
%     peaks_n = [peaks_n; length(sig), sig(end)];
% 
%     % Height of peaks [locs, peakVal, height]
%     deltaTo_n = peaks_p(:,2) - peaks_n(:,2);
%     peaks_n = [peaks_n deltaTo_n];
%     deltaTo_p = peaks_p(2:end,2) - peaks_n(1:end-1,2);
%     peaks_p = [peaks_p [NaN; deltaTo_p]];
% end


% remove outliers 
%height_p(height_p < min_height) = [];
%height_n(height_n < min_height) = [];

% plot histgrams of heights
figure()
subplot(2,1,1)
hist(deltaTo_p, 500)
title('Histgram of Positive Raw Peak Rise from Previous Neg Peak ')
%ylim([0, 150])
%xlim([200 320])


subplot(2,1,2)
hist(deltaTo_n, 500)
title('Histgram of Negative Raw Peak Fall from Previous Pos Peak')
%ylim([0, 150])
%xlim([200 320])

%% plot peak height v max vel during rise-to-peak
peak_cuttoff = .5;
sig_deriv = diff(sig);
sig_deriv = [sig_deriv; NaN];

for i = 1:length(peaks_p)
    max_slope_p(i) = max(sig_deriv(peaks_n(i,1):peaks_p(i,1)));
%     figure(44)
%     subplot(1,2,1)
%     plot(sig_deriv(peaks_n(i,1):peaks_p(i,1)))
%     subplot(1,2,2)
%     plot(sig(peaks_n(i,1):peaks_p(i,1)))

end

% first neg peak is sample1 == no slope
for i = 2:length(peaks_p)
    min_slope_n(i) = min(sig_deriv(peaks_p(i-1,1):peaks_n(i,1)));
%     figure(45)
%     subplot(1,2,1)
%     plot(sig_deriv(peaks_p(i-1,1):peaks_n(i,1)))
%     subplot(1,2,2)
%     plot(sig(peaks_p(i-1,1):peaks_n(i,1)))
%     print('a')
end
min_slope_n(1) = NaN;

figure()
subplot(2,1,1)
%max_slope_p(max_slope_p > peak_cuttoff) = [];
hist(max_slope_p, 250);

subplot(2,1,2)
min_slope_n = min_slope_n*-1;
%min_slope_n(min_slope_n > peak_cuttoff) = [];
hist(min_slope_n,250);

figure()
% [locs, peakVal, height, maxSlopetopnt]
peaks_p = [peaks_p max_slope_p'];
peaks_n = [peaks_n min_slope_n'];
A = scatter(peaks_p(:,3), peaks_p(:,4), 'filled');
set(A,'SizeData',4)
hold on
%B = scatter(peaks_n(:,3), peaks_n(:,4), 'filled');
%set(B,'SizeData',4)
xlabel('Delta from Previous Peak')
ylabel('Peak Vel During Change')
%ylim([0,.5])

%% Plot dF/F
%df_f = calc_dF_F(sig(150:end));




