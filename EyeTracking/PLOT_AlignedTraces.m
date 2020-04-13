function vars = PLOT_AlignedTraces(vars)  

%% Align channels
vars = alignChans_APP(vars, vars.chosenShiftVal);

%% load data
loadAnalysisInfo_APP;

%% Prep
% mag1_aligned = mag1.pos_data_aligned - mean(mag1.pos_data_aligned);
% mag2_aligned = mag2.pos_data_aligned - mean(mag2.pos_data_aligned);
mag1_ScaledVel = mag1.vel_data_aligned * mag1.vel_scale;
mag2_ScaledVel = mag2.vel_data_aligned * mag2.vel_scale;
vidV_aligned = vid.vel_data_upsampled_aligned;

mag1posplot = cumtrapz(mag1_ScaledVel);
mag1posplot = mag1posplot - mean(mag1posplot);
mag2posplot = cumtrapz(mag2_ScaledVel);
mag2posplot = mag2posplot - mean(mag2posplot);
vidposplot = cumtrapz(vid.vel_data_upsampled_aligned);
vidposplot = vidposplot - mean(vidposplot);


% mag1posplot(mag1.saccades_all) = nan;
% mag2posplot(mag2.saccades_all) = nan;
% vidposplot(vid.saccades_all) = nan;

mag1_ScaledVel(mag1.saccades_all) = nan;
mag2_ScaledVel(mag2.saccades_all) = nan;
vidV_aligned(vid.saccades_all) = nan;

[~, mag1_v_mean] = VOR_breakTrace(1000, 1, mag1_ScaledVel);
[~, mag2_v_mean] = VOR_breakTrace(1000, 1, mag2_ScaledVel);
[~, vel_v_mean] = VOR_breakTrace(1000, 1, vidV_aligned);

%% Figure 1: whole segment for position and velocity
% Position
A = figure();
AlignedTraces = tight_subplot(2,1,[.01 .025],[.04 .025],[.03 .03]);

axes(AlignedTraces(1));
plot(mag1.time_aligned, mag1posplot, 'k'); hold on
plot(mag2.time_aligned, mag2posplot, 'b');
ylabel('Magnet Position')
plot(vid.time_upsampled_aligned, vidposplot, 'r')
ylabel('Video Position')
legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
xlim([0 vid.time_upsampled_aligned(end)]);
grid on
title('Scaled in Velocity Space')

% Velocity 
axes(AlignedTraces(2));
plot(mag1.time_aligned, mag1_ScaledVel, 'k'); hold on
plot(mag2.time_aligned, mag2_ScaledVel, 'b');
plot(vid.time_upsampled_aligned, vidV_aligned, 'r')
xlabel('Time (s)')
ylabel('Velocity (deg/s)')
ylim([-300 300])
xlim([0 vid.time_upsampled_aligned(end)]);
grid on
linkaxes(AlignedTraces, 'x')
% Save Figure
set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(A, fullfile(cd, 'MagnetVideoAlignment_segment.pdf'),'-dpdf');
savefig('MagnetVideoAlignment_segment.fig');

%% Figure 2: Velocity cycle
% B = figure();
% 
% tight_subplot(1,1,[.01 .025],[.04 .025],[.03 .03]);
% plot(mag1_v_mean, 'k'); hold on
% plot(mag2_v_mean, 'b');
% plot(vel_v_mean, 'r');
% legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
% ylabel('Velocity (deg/s)');
% xlabel('Time (ms)');
% grid on
% % Save Figure
% set(B,'Units','Inches');
% pos = get(B,'Position');
% set(B,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
% print(B, fullfile(cd, 'MagnetVideoAlignment_cycle.pdf'),'-dpdf');
% savefig('MagnetVideoAlignment_cycle.fig');


%% Figure 3: where to apply scaling?
% Position
A = figure();
AlignedTraces = tight_subplot(2,1,[.01 .025],[.04 .025],[.03 .03]);

axes(AlignedTraces(1));
pos1Plot = (mag1.pos_data_aligned * mag1.vel_scale) - mean(mag1.pos_data_aligned * mag1.vel_scale);
pos2Plot = (mag2.pos_data_aligned * mag2.vel_scale) - mean(mag2.pos_data_aligned * mag2.vel_scale);

plot(mag1.time_aligned, pos1Plot, 'k'); hold on
plot(mag2.time_aligned, pos2Plot, 'b');
ylabel('Magnet Position')
plot(vid.time_upsampled_aligned, vidposplot, 'r')
ylabel('Video Position')
legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
xlim([0 vid.time_upsampled_aligned(end)]);
grid on
title('Scaled in Position Space')

% Velocity 
axes(AlignedTraces(2));
plot(mag1.time_aligned, movingslopeCausal(mag1.pos_data_aligned * mag1.vel_scale), 'k'); hold on
plot(mag2.time_aligned, movingslopeCausal(mag2.pos_data_aligned * mag2.vel_scale), 'b');
plot(vid.time_upsampled_aligned, vidV_aligned, 'r')
xlabel('Time (s)')
ylabel('Velocity (deg/s)')
ylim([-300 300])
xlim([0 vid.time_upsampled_aligned(end)]);
grid on
linkaxes(AlignedTraces, 'x')
% Save Figure
set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(A, fullfile(cd, 'MagnetVideoAlignment_segment.pdf'),'-dpdf');
savefig('MagnetVideoAlignment_segment.fig');
    
%% save data
saveAnalysisInfo_APP;