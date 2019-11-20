function VOR_Summary_Sriram_CycleDiff(params, post, pre, Etitle, stim)

%% Prep
type = 1;% 1 == desaccaded, 2 == good cycles SRIRAM
load('result.mat')

%% Calculations

% extract dessaccaded mean traces
eyeVel_des_cycleMean_pre = cell2mat([result.eyeVel_des_cycleMean(pre)]');
eyeVel_des_cycleMean_post = cell2mat([result.eyeVel_des_cycleMean(post)]');

% extract !saccade fraction
eyeVel_des_cycleMean_pre_sacFrac = 1-result.data(pre,strcmp(result.header, 'saccadeFrac'));
eyeVel_des_cycleMean_post_sacFrac = 1-result.data(post,strcmp(result.header, 'saccadeFrac'));

% calculate weighted mean for pre & post measures 
eyeVel_des_preWeightedMean = sum(eyeVel_des_cycleMean_pre .* eyeVel_des_cycleMean_pre_sacFrac, 1) ...
                             / sum(eyeVel_des_cycleMean_pre_sacFrac);
eyeVel_des_postWeightedMean = sum(eyeVel_des_cycleMean_post .* eyeVel_des_cycleMean_post_sacFrac, 1) ...
                             / sum(eyeVel_des_cycleMean_post_sacFrac);
                                                 
% extract goodCycle mean traces
eyeVel_good_cycleMean_pre = cell2mat([result.eyeVel_good_cycleMean(pre)]');
eyeVel_good_cycleMean_post = cell2mat([result.eyeVel_good_cycleMean(post)]');

% extract good cycle count
eyeVel_good_cycleMean_pre_nGoodCycles = result.data(pre,strcmp(result.header, 'nGoodCycles'));
eyeVel_good_cycleMean_post_nGoodCycles = result.data(post,strcmp(result.header, 'nGoodCycles'));

% calculate weighted mean for pre & post measures 
eyeVel_good_preWeightedMean = sum(eyeVel_good_cycleMean_pre .* eyeVel_good_cycleMean_pre_nGoodCycles, 1) ...
                             / sum(eyeVel_good_cycleMean_pre_nGoodCycles);
eyeVel_good_postWeightedMean = sum(eyeVel_good_cycleMean_post .* eyeVel_good_cycleMean_post_nGoodCycles, 1) ...
                             / sum(eyeVel_good_cycleMean_post_nGoodCycles);


% Misc
freq = result.freq{1};
samplerate = result.samplerate{1};
ttCycle = result.cycleTime{1};

% Calc mean head velocity @ Pre
headVel_pre = cell2mat([result.headVel_cycleMean(pre)]');
headVel_preMean = mean(headVel_pre, 1);

% Calc mean head velocity @ Post
headVel_post = cell2mat([result.headVel_cycleMean(post)]');
headVel_postMean = mean(headVel_post, 1);

% Calc mean drum velocity @ Pre
drumVel_pre = cell2mat([result.drumVel_cycleMean(pre)]');
drumVel_preMean = mean(drumVel_pre, 1);

% Calc mean drum velocity @ Post
drumVel_post = cell2mat([result.drumVel_cycleMean(post)]');
drumVel_postMean = mean(drumVel_post, 1);

%% Figure A, Averages

% plot
qqq = figure('visible','off', 'PaperOrientation', 'landscape');
ha = tight_subplot(2,2,[.025 .025],[.025 .025],[.025 .025]);
axes(ha(1))
if type == 1
    plot(ttCycle, eyeVel_des_preWeightedMean, 'b'); hold on
    plot(ttCycle, eyeVel_des_postWeightedMean, 'r');
    title('Desaccaded')
else
    plot(ttCycle, eyeVel_good_preWeightedMean, 'b'); hold on
    plot(ttCycle, eyeVel_good_postWeightedMean, 'r')
    title('Only Good Cycles')
end

if contains(stim, 'drum')
    plot(ttCycle, drumVel_preMean, 'k')
    plot(ttCycle, drumVel_postMean, 'k')
else
    plot(ttCycle, headVel_preMean, 'k')
    plot(ttCycle, headVel_postMean, 'k')
end

ylim([-50, 50])
hline(0, 'k')
legend('pre', 'post')
box off
xticklabels([])

%% Figure B, Fits

% Calc
if type == 1
    [~, eyevelH_rel_phase_tPre, eyevelH_amp_tPre, eyeHgain_tPre]    = VOR_SineFit_Single(freq, samplerate, eyeVel_des_preWeightedMean, headVel_preMean, drumVel_preMean);
    [~, eyevelH_rel_phase_tPost, eyevelH_amp_tPost, eyeHgain_tPost] = VOR_SineFit_Single(freq, samplerate, eyeVel_des_postWeightedMean, headVel_postMean, drumVel_postMean);
    titlewords = 'Fits of Desaccaded';
else
    [~, eyevelH_rel_phase_tPre, eyevelH_amp_tPre, eyeHgain_tPre]    = VOR_SineFit_Single(freq, samplerate, eyeVel_good_preWeightedMean, headVel_preMean, drumVel_preMean);
    [~, eyevelH_rel_phase_tPost, eyevelH_amp_tPost, eyeHgain_tPost] = VOR_SineFit_Single(freq, samplerate, eyeVel_good_postWeightedMean, headVel_postMean, drumVel_postMean);
    titlewords = 'Fits of Only Good Cycles';
end

% Plot
axes(ha(2))
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_tPre+180))*eyevelH_amp_tPre, 'b'); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_tPost+180))*eyevelH_amp_tPost, 'r');

if contains(stim, 'drum')
    plot(ttCycle, drumVel_preMean, 'k')
    plot(ttCycle, drumVel_postMean, 'k')
else
    plot(ttCycle, headVel_preMean, 'k')
    plot(ttCycle, headVel_postMean, 'k')
end

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
    DiffOfMeans = eyeVel_des_postWeightedMean - eyeVel_des_preWeightedMean;
else
    DiffOfMeans = eyeVel_good_postWeightedMean - eyeVel_good_preWeightedMean;
end
[~, eyevelH_rel_phase_diff, eyevelH_amp_diff, eyeHgain_diff]    = VOR_SineFit_Single(freq, samplerate, DiffOfMeans, headVel_preMean, drumVel_preMean);

Pree = table( eyeVel_des_preWeightedMean);
posst= table( eyeVel_des_postWeightedMean);

writetable(Pree, [params.file, ' ', Etitle, 'mousePRE', '.xlsx']);
writetable(posst, [params.file, ' ', Etitle, 'mousePOST', '.xlsx']);



% Plot
axes(ha(3))
plot(ttCycle, DiffOfMeans, 'Color', [0 .5 0]); hold on
plot(ttCycle, sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase_diff+180))*eyevelH_amp_diff, 'c');

if contains(stim, 'drum')
    plot(ttCycle, drumVel_preMean, 'k')
    plot(ttCycle, drumVel_postMean, 'k')
else
    plot(ttCycle, headVel_preMean, 'k')
    plot(ttCycle, headVel_postMean, 'k')
end

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
diffData(end).stim = drumVel_preMean;

% load information into excel file
mouse = {diffData.mouse}';
condition = {diffData.condition}';
use = [diffData.keep]';
color = [diffData.color]';

T = table(mouse, condition, use, color);
writetable(T, 'diffData.xlsx');


save('diffData.mat', 'diffData');
cd(params.folder);
