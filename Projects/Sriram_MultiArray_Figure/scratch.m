%{
Arifact @ ~3183.5Hz

%}

%% load
cd Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Granule_cell_recording\NR2_F_10_S1
load('testData.mat')


tv = amplifier_data(2,:);
samplerate = 30000;

%% BANDPASS FILTER
N = 3;
fc = [7 200];
[bb,aa] = butter(N, fc/samplerate, 'bandpass');
tv_filt = filtfilt(bb,aa,tv);


%% LOW PASS FILTER
N = 5;
fc = 1000;
[bb,aa] = butter(N, fc/samplerate, 'low');
tv_filt = filtfilt(bb,aa,tv);


%% plot Raw and CLEAN
%lims
lims = [180000 230000];

ha = tight_subplot(2,1,[.005 .005],[.005 .005],[.005 .005]);

axes(ha(1))
plot(tv)
xlim(lims)
vline(1:30000:length(tv),'-k')

axes(ha(2))
plot(tv_filt)
xlim(lims)
vline(1:30000:length(tv),'-k')

linkaxes(ha,'x');


%% Plot Frequency spectrum(s)
freqSpec(amplifier_data, samplerate)