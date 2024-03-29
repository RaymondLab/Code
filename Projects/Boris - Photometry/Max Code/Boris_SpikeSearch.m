savename = 'd\d_100Hz';
savename=strcat(savename,'.mat');
load(savename)
seg = 1;

temp.special = 1;
samplerate = 101.7253; % mouse 115, recording 1 (only recording) 
thresh = 1.3;

%% Mouse Specific

% FRAME NUMBER (~ 10 frames / s)
start_camFrame = [308; 5509; 14869; 15269; 15949; 17934; 21829; 25029];
stop_camFrame = [3753; 14425; 14989; 15589; 17432; 19949; 23682; 27909];

% ABSOLUTE TIME (s)
start_abs = camtime(start_camFrame);
stop_abs = camtime(stop_camFrame);
cycleLen_abs = [0; 0; 2; 2; 4; 8; 8; 16];
temp.segLen = cycleLen_abs(seg);

% FP SAMPLE  (~ 100 samples / s)
start_FPsample = NaN(1, length(start_camFrame));
stop_FPsample = NaN(1, length(start_camFrame));

for q = 1:length(start_camFrame)
    [~, start_FPsample(q)] = min(abs(timeFP_RS - start_abs(q)));
    [~, stop_FPsample(q)]  = min(abs(timeFP_RS - stop_abs(q)));
end

% CYCLE START AND STOP TIMES IN ABS AND FP SAMPLES
if cycleLen_abs(seg) > 1
    abs_cycle_starts = start_abs(seg):cycleLen_abs(seg):stop_abs(seg);
    abs_cycle_stops = abs_cycle_starts + cycleLen_abs(seg);    
else
    
    if seg == 1
        segLenSpecial = [2 2 2 6 3 3 3 3 3 3 3 3 6 4 4 4 4 4 4 4 4 4 4 4] * 4;
    elseif seg == 2
        segLenSpecial = [5 7 7 7 8 7 6 6 5 6 5 5 6 17 9 11 8 8 9 14 12 16 9 11 19] * 4;
    end

    for q = 1:length(segLenSpecial)
        abs_cycle_stops(q) = start_abs(seg) + sum(segLenSpecial(1:q));
    end
    
    abs_cycle_starts = [start_abs(seg) abs_cycle_stops(1:end-1)];
end

for q = 1:length(abs_cycle_starts)
    [~, FP_cycle_starts(q)] = min(abs(timeFP_RS - abs_cycle_starts(q)));
    [~, FP_cycle_stops(q)] = min(abs(timeFP_RS - abs_cycle_stops(q)));
end


%% plot Entire raw trace
figure()
plot(sig_405_RS, 'k'); hold on
plot(sig_472_RS, 'b')
vline(start_FPsample, 'k')
vline(stop_FPsample, ':k')
legend('Control', 'GCaMP')
title('Mouse 115: Complete Unfiltered Unbleached Recording')
vline(FP_cycle_starts)

%% Filter Design    
N = 2;
fc = [.3 7];
[bb,aa] = butter(N, fc/samplerate, 'bandpass');
sig_405_RS_Filt = filter(bb, aa, (sig_405_RS));
sig_472_RS_Filt = filter(bb, aa, (sig_472_RS));
startT = [];

%% Plot filtered versions
% xaxis seconds scale
xaxis = linspace(0,stop_FPsample(seg) - start_FPsample(seg), length(start_FPsample(seg):stop_FPsample(seg))) / 100;


figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1)
%plot(xaxis, sig_405_RS(start_FPsample(seg):stop_FPsample(seg)), 'b'); hold on
plot(xaxis, sig_472_RS(start_FPsample(seg):stop_FPsample(seg)), 'b'); hold on
vline([FP_cycle_starts - FP_cycle_starts(1)] / 100)
title(['Mouse 115: Segment ' num2str(seg) ' GCaMP'])
xlim([0 60])
vline(1:400)
ylim([min(ylim),min(ylim)+10])

%figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,2)
plot(xaxis, sig_472_RS_Filt(start_FPsample(seg):stop_FPsample(seg)), 'b'); hold on
%plot(xaxis, sig_405_RS(start_FPsample(seg):stop_FPsample(seg)), 'b'); hold on
%plot(xaxis, sig_405_RS_Filt(start_FPsample(seg):stop_FPsample(seg)),'k'); hold on
title(['Mouse 115: Segment ' num2str(seg) ' Filter'])
xlim([0 60])
ylim([min(ylim),min(ylim)+9])


% cosmetics
ylim([-5 5])
hline(thresh)
hline(-1*thresh)
vline(1:400)
vline([FP_cycle_starts - FP_cycle_starts(1)] / 100)

axH = findall(gcf,'type','axes');
%set(axH,'xlim',[600 675])
if temp.special
    cycleVec = nan(length(FP_cycle_starts), max(segLenSpecial) * 100);
    for i = 1:length(segLenSpecial)
        cycleVec(i,1:segLenSpecial(i)*100) = sig_472_RS(FP_cycle_starts(i):FP_cycle_stops(i)-1);
    end  
else
% bar
Boris_spikeAnalysis(sig_472_RS_Filt, temp, thresh)
end

