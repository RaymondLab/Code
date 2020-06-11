function vars = PLOT_DesaccadedTraces(vars)

%% load data
loadAnalysisInfo_APP;

%% Setup
A = figure('units','normalized','outerposition',[0 0 1 1]);
desacPLot = tight_subplot(3,1,[.025 .025],[.025 .025],[.015 .01]);

%% Magnet Channel 1 
axes(desacPLot(1));
title('Magnet Channel-1, Unscaled'); hold on;
plot(mag1.time, mag1.vel_data,'k'); 
mag1VelPlot_desac = mag1.vel_data;
mag1VelPlot_desac(mag1.saccades) = NaN;
plot(mag1.time, mag1VelPlot_desac,'b', 'LineWidth', 1); 
plot(mag1.time,mag1.vel_fit,'r', 'LineWidth', 2);
ylim([-mag1.vel_amp*9, mag1.vel_amp*9])
text(1, max(ylim)*.9, sprintf('fit amp = %.3f V\nfit r^2 = %.3f\nScale Factor = %.3f deg/V',mag1.vel_amp, mag1.vel_fitr2, mag1.vel_scale),'BackgroundColor','w')
yticklabels(yticks)

%% Magnet Channel 2
axes(desacPLot(2));
title('Magnet Channel-2, Unscaled'); hold on;
plot(mag2.time, mag2.vel_data,'k'); 
mag2VelPlot_desac = mag2.vel_data;
mag2VelPlot_desac(mag2.saccades) = NaN;
plot(mag2.time, mag2VelPlot_desac,'b', 'LineWidth', 1); 
plot(mag2.time,mag2.vel_fit,'r', 'LineWidth', 2);
ylim([-mag2.vel_amp*9, mag2.vel_amp*9])
text(1, max(ylim)*.9, sprintf('fit amp = %.3f V\nfit r^2 = %.3f\nScale Factor = %.3f deg/V',mag2.vel_amp, mag2.vel_fitr2, mag2.vel_scale),'BackgroundColor','w')
yticklabels(yticks)

%% Video Channel
axes(desacPLot(3));
title('Video'); hold on;
plot(vid.time_upsampled, vid.vel_data_upsampled,'k');  
vidVelplot_desac = vid.vel_data_upsampled;
vidVelplot_desac(vid.saccades_upsampled) = NaN;
plot(vid.time_upsampled, vidVelplot_desac,'b', 'LineWidth', 1);  
plot(vid.time_upsampled, vid.vel_fit, 'r', 'LineWidth', 2);
ylim([-vid.vel_amp*9, vid.vel_amp*9])
text(1, max(ylim)*.9, sprintf('fit amp = %.3f deg/s\nfit r^2 = %.3f',vid.vel_amp, vid.vel_fitr2),'BackgroundColor','w')
yticklabels(yticks)

%% Cosmetics
xlabel('s')
linkaxes(desacPLot, 'x')
xticks(0:5:max(xticks))
xticklabels(0:5:max(xticks))
xlim([0, max(mag1.time)]) % NEW METHOD
%xlim([0, max([mag1.time(end), vid.time_upsampled(end)])]) NEW METHOD
box off

%% Save Figures
set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(A, fullfile(cd, 'Summary_Desaccading.pdf'),'-dpdf');
savefig('Summary_Desaccading.fig')