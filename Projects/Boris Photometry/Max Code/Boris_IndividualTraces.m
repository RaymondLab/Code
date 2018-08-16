%% plot the individual traces and their means

subplotfigure = figure();

%% 1) Mean of GCaMP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanGCaMP = subplot(3, 1, 1);
plot(segMat_405_Control', 'color', lightGreen); hold on;
plot(nanmean(segMat_405_Control), 'k', 'linewidth', 2)
title([direction ' Segment - ' num2str(struct(1).mouse) '_R' num2str(struct(1).recNum) '_S' num2str(struct(1).segNum) ' ' filter ': Mean - Control'])
legend('Individual Trials', 'Mean')
Boris_figureCosmetics

%% 2) Mean of Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MeanControl = subplot(3, 1, 2);
plot(segMat_472_GCaMP','color', lightGreen); hold on;
plot(nanmean(segMat_472_GCaMP), 'k', 'linewidth', 2)
title('GCaMP')
Boris_figureCosmetics

%% 3) Mean of Difference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanDifference = subplot(3, 1, 3);
plot(segMat_Diff', 'color', lightGreen); hold on;
plot(nanmean(segMat_Diff), 'k', 'linewidth', 2)
title('Difference')
Boris_figureCosmetics

%% save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [direction ' Segment - ' num2str(struct(1).mouse) '_R' num2str(struct(1).recNum) '_S' num2str(struct(1).segNum) ' ' filter ' Means'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))