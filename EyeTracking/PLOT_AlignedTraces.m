function vars = PLOT_AlignedTraces(app, vars)  

%% Align channels
vars = alignChans_APP(vars, vars.chosenShiftVal);
veltau = .01;

%% load data
loadAnalysisInfo_APP;

%% Prep Video 
vid.pos_data_upsampled_aligned = cumtrapz(vid.vel_data_upsampled_aligned)./mag1.samplerate;
vid.pos_data_upsampled_aligned = vid.pos_data_upsampled_aligned - mean(vid.pos_data_upsampled_aligned);

%% Get pos and vel for when scaling in VELOCITY space
mag1.vel_data_aligned_scaledInVel = mag1.vel_data_aligned * mag1.vel_scale;
mag2.vel_data_aligned_scaledInVel = mag2.vel_data_aligned * mag2.vel_scale;

mag1.pos_data_aligned_scaledInVel = cumtrapz(mag1.vel_data_aligned_scaledInVel)./mag1.samplerate;
mag2.pos_data_aligned_scaledInVel = cumtrapz(mag2.vel_data_aligned_scaledInVel)./mag2.samplerate;

% Center position at 2
mag1.pos_data_aligned_scaledInVel = mag1.pos_data_aligned_scaledInVel - mean(mag1.pos_data_aligned_scaledInVel);
mag2.pos_data_aligned_scaledInVel = mag2.pos_data_aligned_scaledInVel - mean(mag2.pos_data_aligned_scaledInVel);

%% Get pos and vel for when scaling in POSITION space
N = 4;
fc = 15;
[bb,aa] = butter(N, fc/mag1.samplerate, 'low');
mag1.pos_data_aligned_scaledInPos = filtfilt(bb,aa,mag1.pos_data_aligned) * mag1.vel_scale;
mag2.pos_data_aligned_scaledInPos = filtfilt(bb,aa,mag2.pos_data_aligned) * mag2.vel_scale;

mag1.vel_data_aligned_scaledInPos = movingslopeCausal(mag1.pos_data_aligned_scaledInPos, round(mag1.samplerate*veltau))*mag1.samplerate;
mag2.vel_data_aligned_scaledInPos = movingslopeCausal(mag2.pos_data_aligned_scaledInPos, round(mag2.samplerate*veltau))*mag2.samplerate;;

% Center position at 0
mag1.pos_data_aligned_scaledInPos = mag1.pos_data_aligned_scaledInPos - mean(mag1.pos_data_aligned_scaledInPos);
mag2.pos_data_aligned_scaledInPos = mag2.pos_data_aligned_scaledInPos - mean(mag2.pos_data_aligned_scaledInPos);

%% Remove saccades
% Position
% mag1posplot(mag1.saccades_all) = nan;
% mag2.pos_data_aligned_scaledinVel (mag2.saccades_all) = nan;
% vid.pos_data_upsampled_aligned(vid.saccades_all) = nan;

% Velocity
% mag1.vel_data_aligned_scaledInVel(mag1.saccades_all) = nan;
% mag2.vel_data_aligned_scaledInVel(mag2.saccades_all) = nan;
% vidV_aligned(vid.saccades_all) = nan;

%% Get cycle averages
[~, mag1_vinv_mean] = VOR_breakTrace(1000, 1, mag1.vel_data_aligned_scaledInVel);
[~, mag2_vinv_mean] = VOR_breakTrace(1000, 1, mag2.vel_data_aligned_scaledInVel);
[~, mag1_vinp_mean] = VOR_breakTrace(1000, 1, mag1.vel_data_aligned_scaledInPos);
[~, mag2_vinp_mean] = VOR_breakTrace(1000, 1, mag2.vel_data_aligned_scaledInPos);
[~, vel_v_mean] = VOR_breakTrace(1000, 1, vid.vel_data_upsampled_aligned);

%% PLOT Position and Velocity
% Position
% A = figure();
% AlignedTraces = tight_subplot(2,1,[.01 .025],[.04 .025],[.03 .03]);0
% axes(AlignedTraces(1));

% Position
plot(app.UIAxes4_3, mag1.time_aligned, mag1.pos_data_aligned_scaledInVel, 'k'); 
hold(app.UIAxes4_3, 'on')
plot(app.UIAxes4_3, mag2.time_aligned, mag2.pos_data_aligned_scaledInVel , 'b');
plot(app.UIAxes4_3, vid.time_upsampled_aligned, vid.pos_data_upsampled_aligned, 'r')
ylabel(app.UIAxes4_3, 'Position (deg)')
legend(app.UIAxes4_3, 'Magnet Channel 1', 'Magnet Channel 2', 'Video')
xlim(app.UIAxes4_3, [0 vid.time_upsampled_aligned(end)]);
hold(app.UIAxes4_3, 'off')
   

% Velocity 
plot(app.UIAxes4_5, mag1.time_aligned, mag1.vel_data_aligned_scaledInVel, 'k');
hold(app.UIAxes4_5, 'on')
plot(app.UIAxes4_5, mag2.time_aligned, mag2.vel_data_aligned_scaledInVel, 'b');
plot(app.UIAxes4_5, vid.time_upsampled_aligned, vid.vel_data_upsampled_aligned, 'r')
xlabel(app.UIAxes4_5, 'Time (s)')
ylabel(app.UIAxes4_5, 'Velocity (deg/s)')
ylim(app.UIAxes4_5, [-300 300])
xlim(app.UIAxes4_5, [0 vid.time_upsampled_aligned(end)]);
hold(app.UIAxes4_5, 'off')

% % Save Figure
% set(A,'Units','Inches');
% pos = get(A,'Position');
% set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
% print(A, fullfile(cd, 'MagnetVideoAlignment_segment_scaledInVel.pdf'),'-dpdf');
% savefig('MagnetVideoAlignment_segment_scaledInVel.fig');

%% FIGURE 2: Velocity cycle
B = figure();
plot(mag1_vinv_mean, 'k'); hold on
plot(mag2_vinv_mean, 'b');
plot(vel_v_mean, 'r');
legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
ylabel('Velocity (deg/s)');
xlabel('Time (ms)');
grid on
ylim([-100 100]);
title('Alignment of Cycle Averages, scaled in Vel space');
% Save Figure
set(B,'Units','Inches');
pos = get(B,'Position');
set(B,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(B, fullfile(cd, 'MagnetVideoAlignment_cycle_inV.pdf'),'-dpdf');
savefig('MagnetVideoAlignment_cycle_inV.fig');

%% save data
saveAnalysisInfo_APP;