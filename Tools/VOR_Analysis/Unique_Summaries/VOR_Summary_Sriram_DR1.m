function VOR_Summary_Sriram_DR1(params)

%% Prep
type = 1;% 1 == desaccaded, 2 == good cycles

load('t0_t30.mat')

%% Calculations

% Desaccaded
t0_eyeVelDes_Wmean = segObj(1).eyeVelDes * (1-segObj(1).SacFrac) + ...
                     segObj(2).eyeVelDes * (1-segObj(2).SacFrac) + ...
                     segObj(3).eyeVelDes * (1-segObj(3).SacFrac);

t0_eyeVelDes_Wmean = t0_eyeVelDes_Wmean / sum([(1-segObj(1).SacFrac), ...
                                               (1-segObj(2).SacFrac), ...
                                               (1-segObj(3).SacFrac)]);

t30_eyeVelDes_Wmean = segObj(4).eyeVelDes * (1-segObj(4).SacFrac) + ...
                      segObj(5).eyeVelDes * (1-segObj(5).SacFrac) + ...
                      segObj(6).eyeVelDes * (1-segObj(6).SacFrac);        

t30_eyeVelDes_Wmean = t30_eyeVelDes_Wmean / sum([(1-segObj(4).SacFrac), ...
                                                 (1-segObj(5).SacFrac), ...
                                                 (1-segObj(6).SacFrac)]);

% Only Good Cycles
t0_eyeVelGood_Wmean = segObj(1).eyeVelGood * segObj(1).goodCcount + ...
                      segObj(2).eyeVelGood * segObj(2).goodCcount + ...
                      segObj(3).eyeVelGood * segObj(3).goodCcount;

t0_eyeVelGood_Wmean = t0_eyeVelGood_Wmean / sum([segObj(1).goodCcount, ...
                                                 segObj(2).goodCcount, ...
                                                 segObj(3).goodCcount]);

t30_eyeVelGood_Wmean = segObj(4).eyeVelGood * segObj(4).goodCcount + ...
                       segObj(5).eyeVelGood * segObj(5).goodCcount + ...
                       segObj(6).eyeVelGood * segObj(6).goodCcount;

t30_eyeVelGood_Wmean = t30_eyeVelGood_Wmean / sum([segObj(4).goodCcount, ...
                                                   segObj(5).goodCcount, ...
                                                   segObj(6).goodCcount]);

% Misc
freq = segObj(1).freq;
samplerate = segObj(1).samplerate;
ttCycle = segObj(1).ttCycle;

% Calc mean head velocity @ t0
qq = vec2mat([segObj(1:3).headVel], length(ttCycle));
headVelMean_t0 = mean(qq, 1);
% Calc mean head velocity @ t30
qq = vec2mat([segObj(4:6).headVel], length(ttCycle));
headVelMean_t30 = mean(qq,1);

% Calc mean drum velocity @ t0
qq = vec2mat([segObj(1:3).DrumVel], length(ttCycle));
drumVelMean_t0 = mean(qq, 1);
% Calc mean drum velocity @ 3t0
qq = vec2mat([segObj(4:6).DrumVel], length(ttCycle));
drumVelMean_t30 = mean(qq,1);

%% Figure A, Averages

% plot
qqq = figure('visible','off', 'PaperOrientation', 'landscape');
ha = tight_subplot(2,2,[.025 .025],[.025 .025],[.025 .025]);
axes(ha(1))
if type == 1
    plot(ttCycle, t0_eyeVelDes_Wmean, 'b'); hold on
    plot(ttCycle, t30_eyeVelDes_Wmean, 'r');
    title('Desaccaded')
else
    plot(ttCycle, t0_eyeVelGood_Wmean, 'b'); hold on
    plot(ttCycle, t30_eyeVelGood_Wmean, 'r')
    title('Only Good Cycles')
end

plot(ttCycle, headVelMean_t0, 'k')
plot(ttCycle, headVelMean_t30, 'k')
ylim([-10, 10])
hline(0, 'k')
legend('t=0', 't-30')
box off
xticklabels([])

%% Figure B, Fits

% Calc
if type == 1
    [~, eyevelH_rel_phase_t0, eyevelH_amp_t0, eyeHgain_t0] = VOR_SineFit_Single(freq, samplerate, t0_eyeVelDes_Wmean, headVelMean_t0, drumVelMean_t0);
    [~, eyevelH_rel_phase_t30, eyevelH_amp_t30, eyeHgain_t30] = VOR_SineFit_Single(freq, samplerate, t30_eyeVelDes_Wmean, headVelMean_t30, drumVelMean_t30);
    titlewords = 'Fits of Desaccaded';
else
    [~, eyevelH_rel_phase_t0, eyevelH_amp_t0, eyeHgain_t0] = VOR_SineFit_Single(freq, samplerate, t0_eyeVelGood_Wmean, headVelMean_t0, drumVelMean_t0);
    [~, eyevelH_rel_phase_t30, eyevelH_amp_t30, eyeHgain_t30] = VOR_SineFit_Single(freq, samplerate, t30_eyeVelGood_Wmean, headVelMean_t30, drumVelMean_t30);
    titlewords = 'Fits of Only Good Cycles';
end

% Plot
axes(ha(2))
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_t0+180))*eyevelH_amp_t0, 'b'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_t30+180))*eyevelH_amp_t30, 'r');
plot(ttCycle, headVelMean_t0, 'k')
plot(ttCycle, headVelMean_t30, 'k')

% Cosmetics
legend('t=0', 't-30')
title(titlewords)
ylim([-10, 10])
hline(0, 'k');
box off
xticklabels([])
yticklabels([])

%% Figure C, Difference of traces + fit

% Calc
if type == 1
    DiffOfMeans = t30_eyeVelDes_Wmean - t0_eyeVelDes_Wmean;
else
    DiffOfMeans = t30_eyeVelGood_Wmean - t0_eyeVelGood_Wmean;
end
[~, eyevelH_rel_phase_diff, eyevelH_amp_diff, eyeHgain_diff] = VOR_SineFit_Single(freq, samplerate, DiffOfMeans, headVelMean_t0, drumVelMean_t0);

% Plot
axes(ha(3))
plot(ttCycle, DiffOfMeans, 'g'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_diff+180))*eyevelH_amp_diff, 'c');
plot(ttCycle, headVelMean_t0, 'k')
plot(ttCycle, headVelMean_t30, 'k')

% cosmetics
title('Diff of Means: t_3_0 - t_0')
ylim([-10, 10])
hline(0, 'k')
legend('Diff', 'Diff''s Fit')
xlabel('Seconds')
box off

%% Figure D, Polar Plots

% radians conversion
phaseT0Rad = deg2rad(eyevelH_rel_phase_t0);
phaseT30Rad = deg2rad(eyevelH_rel_phase_t30);
phaseDiffRad = deg2rad(eyevelH_rel_phase_diff);

% text summaries
message_t030 = sprintf(['t_0 & t_3_0 \nGain: ' num2str(eyeHgain_t0), '  &  ', num2str(eyeHgain_t30), ...
                                   '\nPhase: ' num2str(eyevelH_rel_phase_t0), '  &  ', num2str(eyevelH_rel_phase_t30), ...
                                   '\nAmp: ', num2str(eyevelH_amp_t0),'  &  ', num2str(eyevelH_amp_t30)]);
message_diff = sprintf(['Diff \nGain: ' num2str(eyeHgain_diff), ...
                             '\nPhase: ' num2str(eyevelH_rel_phase_diff), ...
                             '\nAmp: ', num2str(eyevelH_amp_diff)]);


% Plot pre and post Polar
ha;
subplot(2,4,7)
T0 = polarplot([0 phaseT0Rad], [0 eyeHgain_t0], 'color', 'b', 'lineWidth', 2); hold on
T30 = polarplot([0 phaseT30Rad], [0 eyeHgain_t30], 'color', 'r', 'lineWidth', 2);

% Cosmetics
title(message_t030, 'FontSize', 8)
rlim([0 .6])

% Plot Diff Polar
subplot(2,4,8)
Tdiff = polarplot([0 phaseDiffRad], [0 eyeHgain_diff], 'color', 'c', 'lineWidth', 2);

% Cosmetics
title(message_diff, 'FontSize', 8)
rlim([0 .6])

%% Save as pdf and fig
[~, b] = fileparts(params.folder);
print(qqq,fullfile(params.folder, [b, '_t30-t0_Summary']),'-fillpage', '-dpdf', '-r300');
% Save as .fig
savefig(qqq,fullfile(params.folder, [b, '_t30-t0_Summary.fig']));
