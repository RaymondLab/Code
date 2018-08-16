% Plot various measures of variation in the data
subplotfigure = figure();

% 1) Variance between each cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varFig = subplot(4, 1, 1);
plot(nanvar(segMat_405_Control, 0, 1), 'b'); hold on
plot(nanvar(segMat_472_GCaMP, 0, 1), 'color', lightGreen);
plot(nanvar(segMat_Diff, 0, 1), 'k');
title([direction ' Segment - ' num2str(struct(1).mouse) '_R' num2str(struct(1).recNum) '_S' num2str(struct(1).segNum) ' ' filter ': Variance'])
legend('Control', 'GCaMP', 'Difference')
Boris_figureCosmetics

% 2) CV at each timepoints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cvFig = subplot(4, 1, 2);
plot(nanstd(segMat_405_Control, 1) ./ nanmean(segMat_405_Control, 1) * 100, 'b'); hold on
plot(nanstd(segMat_472_GCaMP, 1) ./ nanmean(segMat_472_GCaMP, 1) * 100, 'color', lightGreen);
%plot(nanstd(segMat_Diff, 1) ./ nanmean(segMat_Diff, 1) * 100, 'k');
title('Coeficient of Variance')
Boris_figureCosmetics

% 3) SD at each time point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdFig = subplot(4,1,3);
plot(nanstd(segMat_405_Control, 1), 'b'); hold on
plot(nanstd(segMat_472_GCaMP, 1), 'color', lightGreen);
plot(nanstd(segMat_Diff, 1), 'k');
title('Standard Deviation')
Boris_figureCosmetics

% 4) Mean at each timepoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanFig = subplot(4,1,4);
plot(nanmean(segMat_405_Control, 1), 'b'); hold on
plot(nanmean(segMat_472_GCaMP, 1), 'color', lightGreen);
%plot(nanmean(segMat_Diff, 1), 'k');
title('Mean')
Boris_figureCosmetics

% Save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [direction ' Segment - ' num2str(struct(1).mouse) '_R' num2str(struct(1).recNum) '_S' num2str(struct(1).segNum) ' ' filter ' Measures of Variation'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))