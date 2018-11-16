function VOR_Summary_Sriram_DR1(params)

%% Prep
type = 1;% 1 == desaccaded, 2 == good cycles

load('t0_t30.mat')

%% Calculations

% Desaccaded
t0_eyeVelDes_Wmean = segObj(1).eyeVelDes * segObj(1).SacFrac + ...
    segObj(2).eyeVelDes * segObj(2).SacFrac + ...
    segObj(3).eyeVelDes * segObj(3).SacFrac;

t0_eyeVelDes_Wmean = t0_eyeVelDes_Wmean / sum([segObj(1).SacFrac, ...
    segObj(2).SacFrac, ...
    segObj(3).SacFrac]);

t30_eyeVelDes_Wmean = segObj(4).eyeVelDes * segObj(4).SacFrac + ...
    segObj(5).eyeVelDes * segObj(5).SacFrac + ...
    segObj(6).eyeVelDes * segObj(6).SacFrac;

t30_eyeVelDes_Wmean = t30_eyeVelDes_Wmean / sum([segObj(4).SacFrac, ...
    segObj(5).SacFrac, ...
    segObj(6).SacFrac]);

% Only Good Cycles
t0_eyeVelGood_Wmean = segObj(1).eyeVelGood * segObj(1).SacFrac + ...
    segObj(2).eyeVelGood * segObj(2).SacFrac + ...
    segObj(3).eyeVelGood * segObj(3).SacFrac;

t0_eyeVelGood_Wmean = t0_eyeVelGood_Wmean / sum([segObj(1).SacFrac, ...
    segObj(2).SacFrac, ...
    segObj(3).SacFrac]);

t30_eyeVelGood_Wmean = segObj(4).eyeVelGood * segObj(4).SacFrac + ...
    segObj(5).eyeVelGood * segObj(5).SacFrac + ...
    segObj(6).eyeVelGood * segObj(6).SacFrac;

t30_eyeVelGood_Wmean = t30_eyeVelGood_Wmean / sum([segObj(4).SacFrac, ...
    segObj(5).SacFrac, ...
    segObj(6).SacFrac]);

% Misc
freq = segObj(1).freq;
sampleRate = segObj(1).sampleRate;
ttCycle = segObj(1).ttCycle;

% Calc mean head velocity @ t0
qq = vec2mat([segObj(1:3).headVel], 1000);
headVelMean_t0 = mean(qq, 1);
% Calc mean head velocity @ t30
qq = vec2mat([segObj(4:6).headVel], 1000);
headVelMean_t30 = mean(qq,1);

% Calc mean drum velocity @ t0
qq = vec2mat([segObj(1:3).DrumVel], 1000);
drumVelMean_t0 = mean(qq, 1);
% Calc mean drum velocity @ 3t0
qq = vec2mat([segObj(4:6).DrumVel], 1000);
drumVelMean_t30 = mean(qq,1);

% calc mean idealEye movement @ t0
qq = vec2mat([segObj(1:6).idealEye], 1000);
idealEye_all = mean(qq,1);

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
%plot(ttCycle, idealEye_all, ':k')
ylim([-10, 10])
hline(0, 'k')
legend('t=0', 't-30')
%grid on
box off
xticklabels([])

%% Figure B, Fits

% Calc
if type == 1
    [~, eyevelH_rel_phase_t0, eyevelH_amp_t0, eyeHgain_t0] = VOR_SineFit_Single(freq, sampleRate, t0_eyeVelDes_Wmean, headVelMean_t0, drumVelMean_t0);
    [~, eyevelH_rel_phase_t30, eyevelH_amp_t30, eyeHgain_t30] = VOR_SineFit_Single(freq, sampleRate, t30_eyeVelDes_Wmean, headVelMean_t30, drumVelMean_t30);
    titlewords = 'Fits of Desaccaded';
else
    [~, eyevelH_rel_phase_t0, eyevelH_amp_t0, eyeHgain_t0] = VOR_SineFit_Single(freq, sampleRate, t0_eyeVelGood_Wmean, headVelMean_t0, drumVelMean_t0);
    [~, eyevelH_rel_phase_t30, eyevelH_amp_t30, eyeHgain_t30] = VOR_SineFit_Single(freq, sampleRate, t30_eyeVelGood_Wmean, headVelMean_t30, drumVelMean_t30);
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
%grid on
box off
xticklabels([])
yticklabels([])

% temp
%axes(ha(1))
%hold on
%plot(ttCycle, sin(2*pi*freq*ttCycle - deg2rad(eyevelH_rel_phase_t0+180))*eyevelH_amp_t0, ':b');
%plot(ttCycle, sin(2*pi*freq*ttCycle - deg2rad(eyevelH_rel_phase_t30+180))*eyevelH_amp_t30, ':r');

%% Figure C, Difference of traces + fit

% Calc
if type == 1
    DiffOfMeans = t30_eyeVelDes_Wmean - t0_eyeVelDes_Wmean;
else
    DiffOfMeans = t30_eyeVelGood_Wmean - t0_eyeVelGood_Wmean;
end
[~, eyevelH_rel_phase_diff, eyevelH_amp_diff, eyeHgain_diff] = VOR_SineFit_Single(freq, sampleRate, DiffOfMeans, headVelMean_t0, drumVelMean_t0);
[~, eyevelH_rel_phase_ideal, eyevelH_amp_ideal, eyeHgain_ideal] = VOR_SineFit_Single(freq, sampleRate, idealEye_all, headVelMean_t0, drumVelMean_t0);

% Plot
axes(ha(3))
plot(ttCycle, DiffOfMeans, 'g'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_diff+180))*eyevelH_amp_diff, 'c');
plot(ttCycle, headVelMean_t0, 'k')
plot(ttCycle, headVelMean_t30, 'k')
%plot(ttCycle, idealEye_all, ':k')

% cosmetics
title('Diff of Means: t_3_0 - t_0')
ylim([-10, 10])
hline(0, 'k')
legend('Diff', 'Diff''s Fit')
xlabel('Seconds')
%grid on
box off

%% Figure D, Polar Plots

% radians conversion
phaseT0Rad = deg2rad(eyevelH_rel_phase_t0);
phaseT30Rad = deg2rad(eyevelH_rel_phase_t30);
phaseDiffRad = deg2rad(eyevelH_rel_phase_diff);
phaseIdealRad = deg2rad(eyevelH_rel_phase_ideal);

% text summaries
message_t030 = sprintf(['t_0 & t_3_0\nGain: ' num2str(eyeHgain_t0), '  &  ', num2str(eyeHgain_t30), ...
                                '\nPhase: ' num2str(eyevelH_rel_phase_t0), '  &  ', num2str(eyevelH_rel_phase_t30), ...
                                '\nAmp: ', num2str(eyevelH_amp_t0),'  &  ', num2str(eyevelH_amp_t30)]);
message_diff = sprintf(['Diff\nGain: ' num2str(eyeHgain_diff), '\nPhase: ' num2str(eyevelH_rel_phase_diff), '\nAmp: ', num2str(eyevelH_amp_diff)]);


ha
subplot(2,4,7)
T0 = polarplot([0 phaseT0Rad], [0 eyeHgain_t0], 'color', 'b', 'lineWidth', 2); hold on
T30 = polarplot([0 phaseT30Rad], [0 eyeHgain_t30], 'color', 'r', 'lineWidth', 2);
%ideal = polarplot([0 phaseIdealRad], [0 eyeHgain_ideal], 'color', 'k', 'lineWidth', 1);

% cosmetics
title(message_t030, 'FontSize', 8)
rlim([0 .6])
subplot(2,4,8)
Tdiff = polarplot([0 phaseDiffRad], [0 eyeHgain_diff], 'color', 'c', 'lineWidth', 2);
rlim([0 .6])
title(message_diff, 'FontSize', 8)
print('done')

%% Save as pdf and fig
[~, b] = fileparts(params.folder);
print(qqq,fullfile(params.folder, [b, '_t30-t0_Summary']),'-fillpage', '-dpdf', '-r300');
% Save as .fig
savefig(qqq,fullfile(params.folder, [b, '_t30-t0_Summary.fig']));
