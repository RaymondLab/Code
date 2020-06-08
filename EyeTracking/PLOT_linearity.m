function vars = PLOT_linearity(vars)
%% load data
loadAnalysisInfo_APP;

c = linspace(1,10,length(mag1.pos_data_aligned_scaledInVel));

%% Linearity Calculation

% Sac Start and End Times
sacEndPoints = diff(~mag1.saccades_all);
goodStarts = find(sacEndPoints == 1);
% goodStarts = goodStarts + 1;
goodStops = find(sacEndPoints == -1);

if goodStarts(1) > goodStops(1)
    goodStarts = [0; goodStarts];
elseif goodStarts(end) > goodStops(end)
    goodStops = [goodStops; length(~mag1.saccades_all)];
elseif isempty(goodStarts) && isempty(goodStops)
    disp('No saccades: Cannot calculate piecewise linearity')
    return
end

% Whole segments
mag1.pos_data_all = measureLinearity(mag1.pos_data_aligned_scaledInVel(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag1.vel_data_all = measureLinearity(mag1.vel_data_aligned_scaledInVel(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag2.pos_data_all = measureLinearity(mag2.pos_data_aligned_scaledInVel(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);
mag2.vel_data_all = measureLinearity(mag2.vel_data_aligned_scaledInVel(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all), ~mag1.saccades_all);

% non-saccades, split up into chunks
for i = 1:length(goodStarts)
    chunk = goodStarts(i):goodStops(i);
    mag1.pos_data_chunks(i) = measureLinearity(mag1.pos_data_aligned_scaledInVel(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag1.vel_data_chunks(i) = measureLinearity(mag1.vel_data_aligned_scaledInVel(chunk), vid.vel_data_upsampled_aligned(chunk));
    mag2.pos_data_chunks(i) = measureLinearity(mag2.pos_data_aligned_scaledInVel(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag2.vel_data_chunks(i) = measureLinearity(mag2.vel_data_aligned_scaledInVel(chunk), vid.vel_data_upsampled_aligned(chunk));
end

%% FIGURE A: r2 over values with various time shift amounts

% yVals = 1:length(mag1.pos_data_all.Rsq);
% yVals = yVals - 4000;
% 
% figure();
% plot(yVals, mag1.pos_linearity_r2, 'r'); hold on
% vline(mag1.pos_linearity_maxr2Loc, 'r')
% text(mag1.pos_linearity_maxr2Loc,max(ylim)*.9, ['MagChan1 Pos ', num2str(mag1.pos_linearity_maxr2Loc)], 'Color', 'r')
% 
% plot(yVals, mag1.vel_linearity_r2, 'k');
% vline(mag1.vel_linearity_maxr2Loc, '--k')
% text(mag1.vel_linearity_maxr2Loc,max(ylim)*.8, ['MagChan1 Vel ', num2str(mag1.vel_linearity_maxr2Loc)], 'Color', 'k')
% 
% plot(yVals, mag2.pos_linearity_r2, 'b');
% vline(mag2.pos_linearity_maxr2Loc, 'b')
% text(mag2.pos_linearity_maxr2Loc,max(ylim)*.7, ['MagChan2 Pos ', num2str(mag2.pos_linearity_maxr2Loc)], 'Color', 'b')
% 
% plot(yVals, mag2.vel_linearity_r2, 'c');
% vline(mag2.vel_linearity_maxr2Loc, '--c')
% text(mag2.vel_linearity_maxr2Loc,max(ylim)*.6, ['MagChan2 Vel ', num2str(mag2.vel_linearity_maxr2Loc)], 'Color', 'c')
% grid on
% 
% drawnow
% title('Linearity with Various Alignment Values, ALL DATA')
% ylabel('r^2 Values')
% xlabel('Alignment Amounts (ms)')
% 
% print(gcf, fullfile(cd, 'Linearity_allShifts.pdf'),'-dpdf');
% savefig('Linearity_allShifts.fig');

%% Figure B: Linearity of Best Alignmnet, ALL DATA

figure();
plotb = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 
allData = logical(ones(length(~mag1.saccades_all), 1));

axes(plotb(1)); hold on
Rsq = linearityScatterPlot(mag1.pos_data_aligned_scaledInVel, vid.pos_data_upsampled_aligned, allData, c);
title(['ALL DATA: r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Position')

axes(plotb(2));
Rsq = linearityScatterPlot(mag1.vel_data_aligned_scaledInVel, vid.vel_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Velocity')


axes(plotb(3));
Rsq = linearityScatterPlot(mag2.pos_data_aligned_scaledInVel, vid.pos_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')


axes(plotb(4));
Rsq = linearityScatterPlot(mag2.vel_data_aligned_scaledInVel, vid.vel_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')

print(gcf, fullfile(cd, 'Linearity_Best_AllData.pdf'),'-dpdf');
savefig('Linearity_Best_AllData.fig');

%% Figure C: Linearity of Best Alignmnet, DESACCADED

figure();
plotc = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 

axes(plotc(1)); hold on
scatter(vid.pos_data_upsampled_aligned(~mag1.saccades_all), mag1.pos_data_aligned_scaledInVel(~mag1.saccades_all), 4, c(~mag1.saccades_all), '.'); hold on
plot(mag1.pos_data_all.yfit, mag1.pos_data_all.range, 'k', 'lineWidth', 2);
colormap hsv;
title(['DESACCADED: r^2: ', num2str(mag1.pos_data_all.Rsq)])
ylabel('Mag Chan1 Position')

axes(plotc(2));
scatter(vid.vel_data_upsampled_aligned(~mag1.saccades_all), mag1.vel_data_aligned_scaledInVel(~mag1.saccades_all), 4, c(~mag1.saccades_all), '.'); hold on
plot(mag1.vel_data_all.yfit, mag1.vel_data_all.range, 'k', 'lineWidth', 2);
colormap hsv;
title(['r^2: ', num2str(mag1.vel_data_all.Rsq)])
ylabel('Mag Chan1 Velocity')

axes(plotc(3));
scatter(vid.pos_data_upsampled_aligned(~mag2.saccades_all), mag2.pos_data_aligned_scaledInVel(~mag2.saccades_all), 4, c(~mag1.saccades_all), '.'); hold on
plot(mag2.pos_data_all.yfit, mag2.pos_data_all.range, 'k', 'lineWidth', 2);
colormap hsv;
title(['r^2: ', num2str(mag2.pos_data_all.Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')

axes(plotc(4));
scatter(vid.vel_data_upsampled_aligned(~mag2.saccades_all), mag2.vel_data_aligned_scaledInVel(~mag2.saccades_all), 4, c(~mag1.saccades_all), '.'); hold on
plot(mag2.vel_data_all.yfit, mag2.vel_data_all.range, 'k', 'lineWidth', 2);
colormap hsv;
title(['r^2: ', num2str(mag2.vel_data_all.Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')


print(gcf, fullfile(cd, 'Linearity_Best_Desacced.pdf'),'-dpdf');
savefig('Linearity_Best_Desacced.fig');

%% Linearity PLots 2.0

% PLOT_linearityComparison(mag1.pos_data_all, mag1.pos_data_chunks, vid.pos_data_upsampled_aligned, mag1.pos_data_aligned_scaledInVel, ~mag1.saccades_all, c, goodStarts, goodStops)
% print(gcf, fullfile(cd, 'Linearity_mag1_pos.pdf'),'-dpdf');
% savefig('Linearity_mag1_pos.fig');

% PLOT_linearityComparison(mag1.vel_data_all, mag1.vel_data_chunks, vid.vel_data_upsampled_aligned, mag1.vel_data_aligned_scaledInVel, ~mag1.saccades_all, c, goodStarts, goodStops)
% print(gcf, fullfile(cd, 'Linearity_mag1_vel.pdf'),'-dpdf');
% savefig('Linearity_mag1_vel.fig');

% PLOT_linearityComparison(mag2.pos_data_all, mag2.pos_data_chunks, vid.pos_data_upsampled_aligned, mag2.pos_data_aligned_scaledInVel, ~mag1.saccades_all, c, goodStarts, goodStops)
% print(gcf, fullfile(cd, 'Linearity_mag2_pos.pdf'),'-dpdf');
% savefig('Linearity_mag2_pos.fig');

% PLOT_linearityComparison(mag2.vel_data_all, mag2.vel_data_chunks, vid.vel_data_upsampled_aligned, mag2.vel_data_aligned_scaledInVel, ~mag1.saccades_all, c, goodStarts, goodStops)
% print(gcf, fullfile(cd, 'Linearity_mag2_vel.pdf'),'-dpdf');
% savefig('Linearity_mag2_vel.fig');

%% Linearity Plots 3.0

% PLOT_linearityComparison2(mag1.pos_data_aligned_scaledInVel, vid.pos_data_upsampled_aligned, goodStarts, goodStops, ~mag1.saccades_all, mag1.pos_data_all, mag1.pos_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag1_pos.pdf'),'-dpdf');
% savefig('Linearity2_mag1_pos2.fig');
% 
% PLOT_linearityComparison2(mag1.vel_data_aligned_scaledInVel, vid.vel_data_upsampled_aligned, goodStarts, goodStops, ~mag1.saccades_all, mag1.vel_data_all, mag1.vel_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag1_vel.pdf'),'-dpdf');
% savefig('Linearity2_mag1_vel.fig');

% PLOT_linearityComparison2(mag2.pos_data_aligned_scaledInVel, vid.pos_data_upsampled_aligned, goodStarts, goodStops, ~mag1.saccades_all, mag2.pos_data_all, mag2.pos_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag2_pos.pdf'),'-dpdf');
% savefig('Linearity2_mag2_pos.fig');

% PLOT_linearityComparison2(mag2.vel_data_aligned_scaledInVel, vid.vel_data_upsampled_aligned, goodStarts, goodStops, ~mag1.saccades_all, mag2.vel_data_all, mag2.vel_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag2_vel.pdf'),'-dpdf');
% savefig('Linearity2_mag2_vel.fig');

%% Linearity Plots 4: Magnet 1

mag_aligned = mag1.pos_data_aligned_scaledInVel;
mag_aligned(vars.mag1.saccades_all) = nan;
vid_aligned = vid.pos_data_upsampled_aligned;
vid_aligned(vars.vid.saccades_all) = nan;


figure()

for i = 1:length(goodStarts)
    chunk = goodStarts(i):goodStops(i);
    
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - nanmean(magPoints);
    mag_aligned(chunk) = magPoints;
    
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - nanmean(vidChunk);
    vid_aligned(chunk) = vidChunk;
end

scatter(mag_aligned, vid_aligned, 50, c, '.'); hold on
ylimits = ylim;
xlimits = xlim;

for i = 1:length(goodStarts)
    chunk = goodStarts(i)+1:goodStops(i);
    
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - nanmean(magPoints);
    
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - nanmean(vidChunk);
    coefficients = polyfit(magPoints, vidChunk, 1);
    xFit = linspace(min(xlim), max(xlim), 1000);
    yFit = polyval(coefficients , xFit);
    plot(xFit, yFit, '-k', 'LineWidth', .1);
end

coefficients = polyfit(mag_aligned(~mag1.saccades_all), vid_aligned(~mag1.saccades_all), 1);
xFit = linspace(min(xlim), max(xlim), 1000);
yFit = polyval(coefficients , xFit);
plot(xFit, yFit, '-r', 'LineWidth', 3);
ylim(ylimits)
xlim(xlimits)
hline(0, ':r')
vline(0, ':r')    
    
print(gcf, fullfile(cd, 'Linearity_4_MagnetChan1.pdf'),'-dpdf');
savefig('Linearity_4_MagnetChan1.fig');

%% Linearity Plots 4: Magnet 2
    
mag_aligned = mag2.pos_data_aligned_scaledInVel;
mag_aligned(vars.mag1.saccades_all) = nan;
vid_aligned = vid.pos_data_upsampled_aligned;
vid_aligned(vars.vid.saccades_all) = nan;


figure()

for i = 1:length(goodStarts)
    chunk = goodStarts(i):goodStops(i);
    
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - nanmean(magPoints);
    mag_aligned(chunk) = magPoints;
    
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - nanmean(vidChunk);
    vid_aligned(chunk) = vidChunk;
end

scatter(mag_aligned, vid_aligned, 50, c, '.'); hold on
ylimits = ylim;
xlimits = xlim;

for i = 1:length(goodStarts)
    chunk = goodStarts(i)+1:goodStops(i);
    
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - nanmean(magPoints);
    
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - nanmean(vidChunk);
    coefficients = polyfit(magPoints, vidChunk, 1);
    xFit = linspace(min(xlim), max(xlim), 1000);
    yFit = polyval(coefficients , xFit);
    plot(xFit, yFit, '-k', 'LineWidth', .1);
end

coefficients = polyfit(mag_aligned(~mag1.saccades_all), vid_aligned(~mag1.saccades_all), 1);
xFit = linspace(min(xlim), max(xlim), 1000);
yFit = polyval(coefficients , xFit);
plot(xFit, yFit, '-r', 'LineWidth', 3);
ylim(ylimits)
xlim(xlimits)
hline(0, ':r')
vline(0, ':r')

print(gcf, fullfile(cd, 'Linearity_4_MagnetChan2.pdf'),'-dpdf');
savefig('Linearity_4_MagnetChan2.fig');

