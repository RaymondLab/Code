function PLOT_AlignedTraces(app, vars)           
%% Prep
mag1_aligned = vars.mag1_aligned - mean(vars.mag1_aligned);
mag2_aligned = vars.mag2_aligned - mean(vars.mag2_aligned);
mag1_ScaledVel = vars.mag1_vel_aligned * vars.scaleCh1;
mag2_ScaledVel = vars.mag2_vel_aligned * vars.scaleCh2;
vidV_aligned = vars.vidV_aligned;
mag1_ScaledVel(~vars.keep) = nan;
mag2_ScaledVel(~vars.keep) = nan;
vidV_aligned(~vars.keep) = nan;

[~, mag1_v_mean] = VOR_breakTrace(1000, 1, mag1_ScaledVel);
[~, mag2_v_mean] = VOR_breakTrace(1000, 1, mag2_ScaledVel);
[~, vel_v_mean] = VOR_breakTrace(1000, 1, vidV_aligned);

%% Position
A = figure();
AlignedTraces = tight_subplot(2,1,[.01 .025],[.04 .025],[.03 .03]);

axes(AlignedTraces(1));
plot(vars.time_aligned, mag1_aligned, 'k'); hold on
plot(vars.time_aligned, mag2_aligned, 'b');
ylabel('Magnet Position')
yyaxis right
plot(vars.time_aligned, vars.vid_aligned, 'r')
ylabel('Video Position')
legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
xlim([0 vars.time_aligned(end)]);

%% Velocity 
axes(AlignedTraces(2));
plot(vars.time_aligned, mag1_ScaledVel, 'k'); hold on
plot(vars.time_aligned, mag2_ScaledVel, 'b');
plot(vars.time_aligned, vidV_aligned, 'r')
xlabel('Time (s)')
ylabel('Velocity (deg/s)')
ylim([-300 300])
xlim([0 vars.time_aligned(end)]);

% Save Figure
set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(A, fullfile(cd, 'MagnetVideoAlignment_segment.pdf'),'-dpdf');
savefig('MagnetVideoAlignment_segment.fig');
%% Velocity (Cycle)
B = figure();

tight_subplot(1,1,[.01 .025],[.04 .025],[.03 .03]);
plot(mag1_v_mean, 'k'); hold on
plot(mag2_v_mean, 'b');
plot(vel_v_mean, 'r');
legend('Magnet Channel 1', 'Magnet Channel 2', 'Video')
ylabel('Velocity (deg/s)');
xlabel('Time (ms)');

% Save Figure
set(B,'Units','Inches');
pos = get(B,'Position');
set(B,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(B, fullfile(cd, 'MagnetVideoAlignment_cycle.pdf'),'-dpdf');
savefig('MagnetVideoAlignment_cycle.fig');

