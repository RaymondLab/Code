function vars = PLOT_linearity(vars)
%% load data
loadAnalysisInfo_APP;

c = linspace(1,10,length(mag1.pos_data_aligned));

%% FIGURE A: r2 over values with various time shift amounts

yVals = 1:length(mag1.pos_linearity_r2);
yVals = yVals - 4000;

figure();
plot(yVals, mag1.pos_linearity_r2, 'r'); hold on
vline(mag1.pos_linearity_maxr2Loc, 'r')
text(mag1.pos_linearity_maxr2Loc,max(ylim)*.9, ['MagChan1 Pos ', num2str(mag1.pos_linearity_maxr2Loc)], 'Color', 'r')

plot(yVals, mag1.vel_linearity_r2, 'k');
vline(mag1.vel_linearity_maxr2Loc, '--k')
text(mag1.vel_linearity_maxr2Loc,max(ylim)*.8, ['MagChan1 Vel ', num2str(mag1.vel_linearity_maxr2Loc)], 'Color', 'k')

plot(yVals, mag2.pos_linearity_r2, 'b');
vline(mag2.pos_linearity_maxr2Loc, 'b')
text(mag2.pos_linearity_maxr2Loc,max(ylim)*.7, ['MagChan2 Pos ', num2str(mag2.pos_linearity_maxr2Loc)], 'Color', 'b')

plot(yVals, mag2.vel_linearity_r2, 'c');
vline(mag2.vel_linearity_maxr2Loc, '--c')
text(mag2.vel_linearity_maxr2Loc,max(ylim)*.6, ['MagChan2 Vel ', num2str(mag2.vel_linearity_maxr2Loc)], 'Color', 'c')
grid on

drawnow
title('Linearity with Various Alignment Values, ALL DATA')
ylabel('r^2 Values')
xlabel('Alignment Amounts (ms)')

print(gcf, fullfile(cd, 'Linearity_allShifts.pdf'),'-dpdf');
savefig('Linearity_allShifts.fig');

%% Figure B: Linearity of Best Alignmnet, ALL DATA
figure();
plotb = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 
allData = logical(ones(length(~mag1.saccades_all), 1));

axes(plotb(1)); hold on
Rsq = linearityScatterPlot(mag1.pos_data_aligned, vid.pos_data_upsampled_aligned, allData, c);
title(['ALL DATA: r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Position')

axes(plotb(2));
Rsq = linearityScatterPlot(mag1.vel_data_aligned, vid.vel_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Velocity')


axes(plotb(3));
Rsq = linearityScatterPlot(mag2.pos_data_aligned, vid.pos_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')


axes(plotb(4));
Rsq = linearityScatterPlot(mag2.vel_data_aligned, vid.vel_data_upsampled_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')

print(gcf, fullfile(cd, 'Linearity_Best_AllData.pdf'),'-dpdf');
savefig('Linearity_Best_AllData.fig');

%% Figure C: Linearity of Best Alignmnet, DESACCADED
figure();
plotc = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 

axes(plotc(1)); hold on
Rsq = linearityScatterPlot(mag1.pos_data_aligned, vid.pos_data_upsampled_aligned, ~mag1.saccades_all, c);
title(['DESACCADED: r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Position')


axes(plotc(2));
Rsq = linearityScatterPlot(mag1.vel_data_aligned, vid.vel_data_upsampled_aligned, ~mag1.saccades_all, c);
title(['r^2: ', num2str(Rsq)])
ylabel('Mag Chan1 Velocity')

axes(plotc(3));
Rsq = linearityScatterPlot(mag2.pos_data_aligned, vid.pos_data_upsampled_aligned, ~mag1.saccades_all, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')

axes(plotc(4));
Rsq = linearityScatterPlot(mag2.vel_data_aligned, vid.vel_data_upsampled_aligned, ~mag1.saccades_all, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')


print(gcf, fullfile(cd, 'Linearity_Best_Desacced.pdf'),'-dpdf');
savefig('Linearity_Best_Desacced.fig');

%% Linearity Calculation

% Sac Start and End Times
sacEndPoints = diff(~mag1.saccades_all);
sacStarts = find(sacEndPoints == 1);
sacStops = find(sacEndPoints == -1);

if sacStarts(1) > sacStops(1)
    sacStarts = [0; sacStarts];
elseif sacStarts(end) > sacStops(end)
    sacStops = [sacStops; length(~mag1.saccades_all)];
elseif isempty(sacStarts) && isempty(sacStops)
    disp('No saccades: Cannot calculate piecewise linearity')
    return
end

%Whole segments
mag1.pos_data_all = measureLinearity(mag1.pos_data_aligned(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all));
mag1.vel_data_all = measureLinearity(mag1.vel_data_aligned(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all));
mag2.pos_data_all = measureLinearity(mag2.pos_data_aligned(~mag1.saccades_all), vid.pos_data_upsampled_aligned(~mag1.saccades_all));
mag2.vel_data_all = measureLinearity(mag2.vel_data_aligned(~mag1.saccades_all), vid.vel_data_upsampled_aligned(~mag1.saccades_all));

% non-saccades, split up into chunks
for i = 1:length(sacStarts)
    chunk = sacStarts(i):sacStops(i);
    mag1.pos_data_chunks(i) = measureLinearity(mag1.pos_data_aligned(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag1.vel_data_chunks(i) = measureLinearity(mag1.vel_data_aligned(chunk), vid.vel_data_upsampled_aligned(chunk));
    mag2.pos_data_chunks(i) = measureLinearity(mag2.pos_data_aligned(chunk), vid.pos_data_upsampled_aligned(chunk));
    mag2.vel_data_chunks(i) = measureLinearity(mag2.vel_data_aligned(chunk), vid.vel_data_upsampled_aligned(chunk));
end
disp('apple')

%% Linearity PLots 2.0
PLOT_linearityComparison(mag1.pos_data_all, mag1.pos_data_chunks, vid.pos_data_upsampled_aligned, mag1.pos_data_aligned, ~mag1.saccades_all, c, sacStarts, sacStops)
print(gcf, fullfile(cd, 'Linearity_mag1_pos.pdf'),'-dpdf');
savefig('Linearity_mag1_pos.fig');

% PLOT_linearityComparison(mag1.vel_data_all, mag1.vel_data_chunks, vid.vel_data_upsampled_aligned, mag1.vel_data_aligned, ~mag1.saccades_all, c, sacStarts, sacStops)
% print(gcf, fullfile(cd, 'Linearity_mag1_vel.pdf'),'-dpdf');
% savefig('Linearity_mag1_vel.fig');

PLOT_linearityComparison(mag2.pos_data_all, mag2.pos_data_chunks, vid.pos_data_upsampled_aligned, mag2.pos_data_aligned, ~mag1.saccades_all, c, sacStarts, sacStops)
print(gcf, fullfile(cd, 'Linearity_mag2_pos.pdf'),'-dpdf');
savefig('Linearity_mag2_pos.fig');

% PLOT_linearityComparison(mag2.vel_data_all, mag2.vel_data_chunks, vid.vel_data_upsampled_aligned, mag2.vel_data_aligned, ~mag1.saccades_all, c, sacStarts, sacStops)
% print(gcf, fullfile(cd, 'Linearity_mag2_vel.pdf'),'-dpdf');
% savefig('Linearity_mag2_vel.fig');

%% Linearity Plots 3.0
PLOT_linearityComparison2(mag1.pos_data_aligned, vid.pos_data_upsampled_aligned, sacStarts, sacStops, ~mag1.saccades_all, mag1.pos_data_all, mag1.pos_data_chunks);
print(gcf, fullfile(cd, 'Linearity2_mag1_pos.pdf'),'-dpdf');
savefig('Linearity2_mag1_pos2.fig');

% PLOT_linearityComparison2(mag1.vel_data_aligned, vid.vel_data_upsampled_aligned, sacStarts, sacStops, ~mag1.saccades_all, mag1.vel_data_all, mag1.vel_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag1_vel.pdf'),'-dpdf');
% savefig('Linearity2_mag1_vel.fig');

PLOT_linearityComparison2(mag2.pos_data_aligned, vid.pos_data_upsampled_aligned, sacStarts, sacStops, ~mag1.saccades_all, mag2.pos_data_all, mag2.pos_data_chunks);
print(gcf, fullfile(cd, 'Linearity2_mag2_pos.pdf'),'-dpdf');
savefig('Linearity2_mag2_pos.fig');

% PLOT_linearityComparison2(mag2.vel_data_aligned, vid.vel_data_upsampled_aligned, sacStarts, sacStops, ~mag1.saccades_all, mag2.vel_data_all, mag2.vel_data_chunks);
% print(gcf, fullfile(cd, 'Linearity2_mag2_vel.pdf'),'-dpdf');
% savefig('Linearity2_mag2_vel.fig');

%% Linearity Plots 4.0

mag_aligned = mag1.pos_data_aligned;
vid_aligned = vid.pos_data_upsampled_aligned;

figure()
for i = 1:length(sacStarts)
    chunk = sacStarts(i):sacStops(i);
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - mean(magPoints);
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - mean(vidChunk);
    scatter(magPoints, vidChunk, '.b'); hold on
end

for i = 1:length(sacStarts)
    chunk = sacStarts(i):sacStops(i);
    magPoints = mag_aligned(chunk);
    magPoints = magPoints - mean(magPoints);
    vidChunk = vid_aligned(chunk);
    vidChunk = vidChunk - mean(vidChunk);    
    
    coefficients = polyfit(magPoints, vidChunk, 1);
    xFit = linspace(min(xlim), max(xlim), 1000);
    yFit = polyval(coefficients , xFit);
    plot(xFit, yFit, 'Color', [.5 .5 .5], 'LineWidth', .5);
end

ylim([-10 10])
xlim([-10 10])

