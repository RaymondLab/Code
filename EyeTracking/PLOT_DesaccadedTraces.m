function vars = PLOT_DesaccadedTraces(vars)

%% Setup
A = figure('units','normalized','outerposition',[0 0 1 1]);
desacPLot = tight_subplot(3,1,[.025 .025],[.025 .025],[.015 .01]);

%% Magnet Channel 1 
axes(desacPLot(1));
title('Magnet Channel-1, Unscaled'); hold on;
plot(vars.tmag, vars.mag1Vel,'k'); 
mag1VelPlot_desac = vars.mag1Vel;
mag1VelPlot_desac(vars.sacLoc_mag1) = NaN;
plot(vars.tmag, mag1VelPlot_desac,'b', 'LineWidth', 1); 
plot(vars.tmag,vars.vars*vars.bMag1,'r', 'LineWidth', 2);
ylim([-vars.mag1Amp*9, vars.mag1Amp*9])
text(1, median(vars.mag1Vel)*300, sprintf('Amp = %.3f deg\nr^2 = %.3f\nScale Factor = %.3f deg/V',vars.mag1Amp, vars.r2mag1, vars.scaleCh1),'BackgroundColor','w')
yticklabels(yticks)


%% Magnet Channel 2
axes(desacPLot(2));
title('Magnet  Channel-2, Unscaled'); hold on;
plot(vars.tmag, vars.mag2Vel,'k');  
mag2VelPlot_desac = vars.mag2Vel;
mag2VelPlot_desac(vars.sacLoc_mag2) = NaN;
plot(vars.tmag, mag2VelPlot_desac,'b', 'LineWidth', 1);  
plot(vars.tmag,vars.vars*vars.bMag2,'r', 'LineWidth', 2);
ylim([-vars.mag2Amp*9, vars.mag2Amp*9])
text(1, median(vars.mag2Vel)*300, sprintf('Amp = %.3f deg\nr^2 = %.3f\nScale Factor = %.3f deg/V',vars.mag2Amp, vars.r2mag2, vars.scaleCh2),'BackgroundColor','w')
yticklabels(yticks)


%% Video Channel
axes(desacPLot(3));
title('Video'); hold on;
plot(vars.tmag, vars.vidVel,'k');  
vidVelplot_desac = vars.vidVel;
vidVelplot_desac(vars.sacLoc_vid) = NaN;
plot(vars.tmag, vidVelplot_desac,'b', 'LineWidth', 1);  
plot(vars.tmag, vars.vars*vars.bVid,'r', 'LineWidth', 2);
ylim([-vars.vidAmp*9, vars.vidAmp*9])
text(1, median(vars.vidVel)*300, sprintf('Amp = %.3f V\nr^2 = %.3f',vars.vidAmp, vars.r2vid),'BackgroundColor','w')
yticklabels(yticks)


%% Cosmetics
xlabel('s')
linkaxes(desacPLot, 'x')
xticks(0:5:max(xticks))
xticklabels(0:5:max(xticks))
xlim([0, max(vars.tmag)])
box off

%% Save Figures
set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(A, fullfile(cd, 'Summary_Desaccading.pdf'),'-dpdf');
savefig('Summary_Desaccading.fig')