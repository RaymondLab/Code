%% windowed SD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowLen = 100;
windowedSDFig = figure();

for k = 1:size(segMat_405_Control, 1)
    moveSTDsegMat_405_Control(k,:) = movstd(segMat_405_Control(k,:), windowLen);
    moveSTDsegMat_472_GCaMP(k,:) = movstd(segMat_472_GCaMP(k,:), windowLen);
    moveSTDsegMat_Diff(k,:) = movstd(segMat_Diff(k,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveSTDsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegMat_405_Control, 1), 'k', 'lineWidth', 2)
title([direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ': Windowed Standard Deviation (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
Boris_figureCosmetics

% GCaMP
subplot(3,1,2)
plot(moveSTDsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
Boris_figureCosmetics

% Difference
subplot(3,1,3)
plot(moveSTDsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegMat_Diff, 1), 'k', 'lineWidth', 2)
title('Difference')
Boris_figureCosmetics

% Save Figure
fileName = [direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ' Windowed Standard Deviation (' num2str(windowLen) ' samples)'];
orient(windowedSDFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedSDFig, strcat(cd, '\', fileName, '.fig'))

%% windowed Mean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedMeanFig = figure();

for k = 1:size(segMat_405_Control, 1)
    moveMEANsegMat_405_Control(k,:) = movmean(segMat_405_Control(k,:), windowLen);
    moveMEANsegMat_472_GCaMP(k,:) = movmean(segMat_472_GCaMP(k,:), windowLen);
    moveMEANsegMat_Diff(k,:) = movmean(segMat_Diff(k,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveMEANsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegMat_405_Control, 1), 'k', 'lineWidth', 2)
title([direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ': Windowed Mean (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
Boris_figureCosmetics

% GCaMP
subplot(3,1,2)
plot(moveMEANsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
Boris_figureCosmetics

% Difference
subplot(3,1,3)
plot(moveMEANsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegMat_Diff, 1), 'k', 'lineWidth', 2)
title('Difference')
Boris_figureCosmetics

% Save Figure
fileName = [direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ' Windowed Mean (' num2str(windowLen) ' samples)'];
orient(windowedMeanFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedMeanFig, strcat(cd, '\', fileName, '.fig'))

%% windowed Var %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedVARFig = figure();

for k = 1:size(segMat_405_Control, 1)
    moveVARsegMat_405_Control(k,:) = movvar(segMat_405_Control(k,:), windowLen);
    moveVARsegMat_472_GCaMP(k,:) = movvar(segMat_472_GCaMP(k,:), windowLen);
    moveVARsegMat_Diff(k,:) = movvar(segMat_Diff(k,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveVARsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegMat_405_Control, 1), 'k', 'lineWidth', 2)
title([direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ': Windowed Variance (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
Boris_figureCosmetics

% GCaMP
subplot(3,1,2)
plot(moveVARsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
Boris_figureCosmetics

% Difference
subplot(3,1,3)
plot(moveVARsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegMat_Diff, 1), 'k', 'lineWidth', 2)
title('Difference')
Boris_figureCosmetics

% Save Figure
fileName = [direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ' Windowed Variance (' num2str(windowLen) ' samples)'];
orient(windowedVARFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedVARFig, strcat(cd, '\', fileName, '.fig'))

%% windowed CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedCVFig = figure();

for k = 1:size(segMat_405_Control, 1)
    moveCVsegMat_405_Control(k,:) = movstd(segMat_405_Control(k,:), windowLen) ./ movmean(segMat_405_Control(k,:), windowLen);
    moveCVsegMat_472_GCaMP(k,:) = movstd(segMat_472_GCaMP(k,:), windowLen) ./ movmean(segMat_472_GCaMP(k,:), windowLen);
    moveCVsegMat_Diff(k,:) = movstd(segMat_Diff(k,:), windowLen) ./ movmean(segMat_Diff(k,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveCVsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegMat_405_Control, 1), 'k', 'lineWidth', 2)
title([direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ': Windowed CV (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
Boris_figureCosmetics

% GCaMP
subplot(3,1,2)
plot(moveCVsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
Boris_figureCosmetics

% Difference
subplot(3,1,3)
plot(moveCVsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegMat_Diff, 1), 'k', 'lineWidth', 2)
title('Difference')
Boris_figureCosmetics

% Save Figure
fileName = [direction ' Segment - ' num2str(struct(i).mouse) '_R' num2str(struct(i).recNum) '_S' num2str(struct(i).segNum) ' ' filter ' Windowed CV (' num2str(windowLen) ' samples)'];
orient(windowedCVFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedCVFig, strcat(cd, '\', fileName, '.fig'))