function VOR_Summary_Sriram_OKR(params, post, pre, Etitle)

%% Prep
type = 1;% 1 == desaccaded, 2 == good cycles

load('t1_t15_t60.mat')
segObj = segObj([pre, post]);

%% Calculations

% Desaccaded - weight by NotSaccade %
tPre_eyeVelDes_Wmean = segObj(1).eyeVelDes * (1-segObj(1).SacFrac) + ...
                       segObj(2).eyeVelDes * (1-segObj(2).SacFrac) + ...
                       segObj(3).eyeVelDes * (1-segObj(3).SacFrac);

tPre_eyeVelDes_Wmean = tPre_eyeVelDes_Wmean / sum([(1-segObj(1).SacFrac), ...
                                                   (1-segObj(2).SacFrac), ...
                                                   (1-segObj(3).SacFrac)]);

tPost_eyeVelDes_Wmean = segObj(4).eyeVelDes * (1-segObj(4).SacFrac) + ...
                        segObj(5).eyeVelDes * (1-segObj(5).SacFrac) + ...
                        segObj(6).eyeVelDes * (1-segObj(6).SacFrac);

tPost_eyeVelDes_Wmean = tPost_eyeVelDes_Wmean / sum([(1-segObj(4).SacFrac), ...
                                                     (1-segObj(5).SacFrac), ...
                                                     (1-segObj(6).SacFrac)]);

% Only Good Cycles - weight by good cycle count
tPre_eyeVelGood_Wmean = segObj(1).eyeVelGood * segObj(1).goodCcount + ...
                        segObj(2).eyeVelGood * segObj(2).goodCcount + ...
                        segObj(3).eyeVelGood * segObj(3).goodCcount;

tPre_eyeVelGood_Wmean = tPre_eyeVelGood_Wmean / sum([segObj(1).goodCcount, ...
                                                     segObj(2).goodCcount, ...
                                                     segObj(3).goodCcount]);

tPost_eyeVelGood_Wmean = segObj(4).eyeVelGood * segObj(4).goodCcount + ...
                         segObj(5).eyeVelGood * segObj(5).goodCcount + ...
                         segObj(6).eyeVelGood * segObj(6).goodCcount;

tPost_eyeVelGood_Wmean = tPost_eyeVelGood_Wmean / sum([segObj(4).goodCcount, ...
                                                       segObj(5).goodCcount, ...
                                                       segObj(6).goodCcount]);

% Misc
freq = segObj(1).freq;
sampleRate = segObj(1).sampleRate;
ttCycle = segObj(1).ttCycle;

% Calc mean head velocity @ Pre
qq = vec2mat([segObj(1:3).headVel], 1000);
headVelMean_tPre = mean(qq, 1);
% Calc mean head velocity @ Post
qq = vec2mat([segObj(4:6).headVel], 1000);
headVelMean_tPost = mean(qq,1);

% Calc mean drum velocity @ Pre
qq = vec2mat([segObj(1:3).DrumVel], 1000);
drumVelMean_tPre = mean(qq, 1);
% Calc mean drum velocity @ Post
qq = vec2mat([segObj(4:6).DrumVel], 1000);
drumVelMean_tPost = mean(qq,1);

%% Figure A, Averages

% plot
qqq = figure('visible','off', 'PaperOrientation', 'landscape');
ha = tight_subplot(2,2,[.025 .025],[.025 .025],[.025 .025]);
axes(ha(1))
if type == 1
    plot(ttCycle, tPre_eyeVelDes_Wmean, 'b'); hold on
    plot(ttCycle, tPost_eyeVelDes_Wmean, 'r');
    title('Desaccaded')
else
    plot(ttCycle, tPre_eyeVelGood_Wmean, 'b'); hold on
    plot(ttCycle, tPost_eyeVelGood_Wmean, 'r')
    title('Only Good Cycles')
end

plot(ttCycle, drumVelMean_tPre, 'k')
plot(ttCycle, drumVelMean_tPost, 'k')
ylim([-50, 50])
hline(0, 'k')
legend('pre', 'post')
box off
xticklabels([])

%% Figure B, Fits

% Calc
if type == 1
    [~, eyevelH_rel_phase_tPre, eyevelH_amp_tPre, eyeHgain_tPre]    = VOR_SineFit_Single(freq, sampleRate, tPre_eyeVelDes_Wmean, headVelMean_tPre, drumVelMean_tPre);
    [~, eyevelH_rel_phase_tPost, eyevelH_amp_tPost, eyeHgain_tPost] = VOR_SineFit_Single(freq, sampleRate, tPost_eyeVelDes_Wmean, headVelMean_tPost, drumVelMean_tPost);
    titlewords = 'Fits of Desaccaded';
else
    [~, eyevelH_rel_phase_tPre, eyevelH_amp_tPre, eyeHgain_tPre]    = VOR_SineFit_Single(freq, sampleRate, tPre_eyeVelGood_Wmean, headVelMean_tPre, drumVelMean_tPre);
    [~, eyevelH_rel_phase_tPost, eyevelH_amp_tPost, eyeHgain_tPost] = VOR_SineFit_Single(freq, sampleRate, tPost_eyeVelGood_Wmean, headVelMean_tPost, drumVelMean_tPost);
    titlewords = 'Fits of Only Good Cycles';
end

% Plot
axes(ha(2))
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_tPre+180))*eyevelH_amp_tPre, 'b'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_tPost+180))*eyevelH_amp_tPost, 'r');
plot(ttCycle, drumVelMean_tPre, 'k')
plot(ttCycle, drumVelMean_tPost, 'k')

% Cosmetics
legend('pre', 'post')
title(titlewords)
ylim([-50, 50])
hline(0, 'k');
box off
xticklabels([])
yticklabels([])

%% Figure C, Difference of traces + fit

% Calc
if type == 1
    DiffOfMeans = tPost_eyeVelDes_Wmean - tPre_eyeVelDes_Wmean;
else
    DiffOfMeans = tPost_eyeVelGood_Wmean - tPre_eyeVelGood_Wmean;
end
[~, eyevelH_rel_phase_diff, eyevelH_amp_diff, eyeHgain_diff]    = VOR_SineFit_Single(freq, sampleRate, DiffOfMeans, headVelMean_tPre, drumVelMean_tPre);

% Plot
axes(ha(3))
plot(ttCycle, DiffOfMeans, 'g'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_diff+180))*eyevelH_amp_diff, 'c');
plot(ttCycle, drumVelMean_tPre, 'k')
plot(ttCycle, drumVelMean_tPost, 'k')

% cosmetics
title(['Diff of Means: ', Etitle])
ylim([-50, 50])
hline(0, 'k')
legend('Diff', 'Diff''s Fit')
xlabel('Seconds')
box off

%% Figure D, Polar Plots

% radians conversion
phasetPreRad = deg2rad(eyevelH_rel_phase_tPre);
phasetPostRad = deg2rad(eyevelH_rel_phase_tPost);
phaseDiffRad = deg2rad(eyevelH_rel_phase_diff);

% text summaries
message_tPre30 = sprintf([Etitle, '\nGain: ' num2str(eyeHgain_tPre), '  &  ', num2str(eyeHgain_tPost), ...
                                  '\nPhase: ' num2str(eyevelH_rel_phase_tPre), '  &  ', num2str(eyevelH_rel_phase_tPost), ...
                                  '\nAmp: ', num2str(eyevelH_amp_tPre),'  &  ', num2str(eyevelH_amp_tPost)]);
message_diff = sprintf(['Diff \nGain: ' num2str(eyeHgain_diff), ...
                             '\nPhase: ' num2str(eyevelH_rel_phase_diff), ...
                             '\nAmp: ', num2str(eyevelH_amp_diff)]);

% Plot pre and post Polar
ha;
subplot(2,4,7)
polarplot([0 phasetPreRad], [0 eyeHgain_tPre], 'color', 'b', 'lineWidth', 2); hold on
polarplot([0 phasetPostRad], [0 eyeHgain_tPost], 'color', 'r', 'lineWidth', 2);

% Cosmetics
title(message_tPre30, 'FontSize', 8)
rlim([0 2.5])

% Plot Diff Polar
subplot(2,4,8)
polarplot([0 phaseDiffRad], [0 eyeHgain_diff], 'color', 'c', 'lineWidth', 2);

% Cosmetics
title(message_diff, 'FontSize', 8)
rlim([0 2.5])

%% Save as pdf and fig
[~, b] = fileparts(params.folder);
print(qqq,fullfile(params.folder, [b, Etitle, '_Summary']),'-fillpage', '-dpdf', '-r300');
% Save as .fig
savefig(qqq,fullfile(params.folder, [b, Etitle, '_Summary.fig']));

%% Save information for Between-Animal Comparison
 
% Check if file exists
cd(params.TopFolder)

if exist('diffData.mat', 'file')
    load('diffData.mat');
else
    diffData = [];
end

% Load information into .mat
diffData(end+1).mouse = params.file;
diffData(end).condition = Etitle;
diffData(end).keep = 1; 
diffData(end).color = 1;
diffData(end).diffRaw = DiffOfMeans;
diffData(end).diffFit = sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_diff+180))*eyevelH_amp_diff;
diffData(end).ttCycle = ttCycle;
diffData(end).stim = drumVelMean_tPre;

% load information into excel file
mouse = {diffData.mouse}';
condition = {diffData.condition}';
use = [diffData.keep]';
color = [diffData.color]';

T = table(mouse, condition, use, color);
writetable(T, 'diffData.xlsx');


save('diffData.mat', 'diffData');
cd(params.folder);
