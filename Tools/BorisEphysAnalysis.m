%{
TODO
    - Vertical Lines to indicate cycle position
    - Get start and stop points for all segments
    - run each section 
NOTES
    segment 1: 763 - 4043, 40 range, 10/s --> 800
    segment 2: 5563 - 6282, 10 range, 5/s --> 400
    segment 3: 6363 - 7617, 10 range, 10/s --> 200
    segment 4: 8683 - 10284, 20 range, 10/s --> 400
    segment 5: 11403 - 13723, 20 range, 10/s --> 400
%} 


%% Build params
clear;clc;close all

% Choose Segment
params.whichSeg = '8';

% Filtered or Unfiltered
params.filter = 'Ffiltered';

switch params.whichSeg 
    
    % Mouse 1
    case '1'
        params.mouse = 2;
        params.segment = [763, 4043];
        params.segLen = 800;
        params.direction = {'L', 'R'};
    case '2'
        params.mouse = 2;
        params.segment = [5563, 6282];
        params.segLen = 400;
        params.direction = {'R', 'L'};
    case '3'
        params.mouse = 2;
        params.segment = [6363, 7617];
        params.segLen = 200;
        params.direction = {'R', 'L'};
    case '4'
        params.mouse = 2;
        params.segment = [8683, 10284];
        params.segLen = 400;
        params.direction = {'R', 'L'};
    case '5'
        params.mouse = 2;
        params.segment = [11403, 13723];
        params.segLen = 400;
        params.direction = {'R', 'L'};
        
    % Mouse 2
    case '6'
        params.mouse = 1;
        params.segment = [185, 2680];
        params.segLen = 800;
        params.direction = {'R', 'L'};
    case '7'
        params.mouse = 1;
        params.segment = [2466, 5865 ];
        params.segLen = 800;
        params.direction = {'R', 'L'};
    case '8'
        params.mouse = 1;
        params.segment = [6172, 7710];
        params.segLen = 800;
        params.direction = {'R', 'L'};
        
        
end


%% Gather matrix of relevent segments for each of the conditions

% Control
params.channel = 'Control';
segmentMatrixControl = segMatrix(params);
title_Control = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% GCaMP
params.channel = 'GCaMP';
segmentMatrixGCaMP = segMatrix(params);
title_GCaMP = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% Difference between the two channels
params.channel = 'Difference';
segmentMatrixDifference = segMatrix(params);
title_Difference = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);


%% plot the individual traces and their means
% 
% lightBlue = [82 201 247] ./ 255;
% 
% fig = figure();
% plot(segmentMatrix', 'color', lightBlue, 'lineWidth', .3)
% hold on 
% plot(nanmean(segmentMatrix',2), 'k', 'lineWidth', 2)
% 
% 
% % other cosmetics
% title(title3);
% vline(params.segLen / 4, 'r')
% vline(params.segLen / 4 * 3, 'r')
% b = ylim;
% text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
% text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
% text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
% text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])
% orient(fig,'landscape')
% 
% % save Figure
% print(fig, title3, '-dpdf', '-bestfit')
% saveas(fig, strcat(cd, '\', title3, '.fig'))
% 
% 
%% Plot various measures of variation in the data
lightBlue = [37 110 4] ./ 255;
subplotfigure = figure();

% 1) Variance between each cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varFig = subplot(4, 1, 1);
plot(nanvar(segmentMatrixControl, 0, 1), 'b'); hold on
plot(nanvar(segmentMatrixGCaMP, 0, 1), 'color', lightBlue);
plot(nanvar(segmentMatrixDifference, 0, 1), 'k');
title(['Segment-' params.whichSeg ' ' params.filter ': Variance'])
legend('Control', 'GCaMP', 'Difference')
figureCosmetics(params)

% 2) CV at each timepoints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cvFig = subplot(4, 1, 2);
plot(nanstd(segmentMatrixControl, 1) ./ nanmean(segmentMatrixControl, 1) * 100, 'b'); hold on
plot(nanstd(segmentMatrixGCaMP, 1) ./ nanmean(segmentMatrixGCaMP, 1) * 100, 'color', lightBlue);
%plot(nanstd(segmentMatrixDifference, 1) ./ nanmean(segmentMatrixDifference, 1) * 100, 'k');
title('Coeficient of Variance')
figureCosmetics(params)

% 3) SD at each time point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdFig = subplot(4,1,3);
plot(nanstd(segmentMatrixControl, 1), 'b'); hold on
plot(nanstd(segmentMatrixGCaMP, 1), 'color', lightBlue);
plot(nanstd(segmentMatrixDifference, 1), 'k');
title('Standard Deviation')
figureCosmetics(params)

% 4) Mean at each timepoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanFig = subplot(4,1,4);
plot(nanmean(segmentMatrixControl, 1), 'b'); hold on
plot(nanmean(segmentMatrixGCaMP, 1), 'color', lightBlue);
%plot(nanmean(segmentMatrixDifference, 1), 'k');
title('Mean')
figureCosmetics(params)

% Save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Measures of Variation'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))


%% Windowed Measures
% windowed SD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lightBlue = [82 201 247] ./ 255;
windowLen = 100;
windowedSDFig = figure();

for i = 1:size(segmentMatrixControl, 1)
    moveSTDsegmentMatrixControl(i,:) = movstd(segmentMatrixControl(i,:), windowLen);
    moveSTDsegmentMatrixGCaMP(i,:) = movstd(segmentMatrixGCaMP(i,:), windowLen);
    moveSTDsegmentMatrixDifference(i,:) = movstd(segmentMatrixDifference(i,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveSTDsegmentMatrixControl', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title(['Segment-' params.whichSeg ' ' params.filter ': Windowed Standard Deviation (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveSTDsegmentMatrixGCaMP', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveSTDsegmentMatrixDifference', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Windowed Standard Deviation (' num2str(windowLen) ' samples)'];
orient(windowedSDFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedSDFig, strcat(cd, '\', fileName, '.fig'))



% windowed Mean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedMeanFig = figure();

for i = 1:size(segmentMatrixControl, 1)
    moveMEANsegmentMatrixControl(i,:) = movmean(segmentMatrixControl(i,:), windowLen);
    moveMEANsegmentMatrixGCaMP(i,:) = movmean(segmentMatrixGCaMP(i,:), windowLen);
    moveMEANsegmentMatrixDifference(i,:) = movmean(segmentMatrixDifference(i,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveMEANsegmentMatrixControl', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title(['Segment-' params.whichSeg ' ' params.filter ': Windowed Mean (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveMEANsegmentMatrixGCaMP', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveMEANsegmentMatrixDifference', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Windowed Mean (' num2str(windowLen) ' samples)'];
orient(windowedMeanFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedMeanFig, strcat(cd, '\', fileName, '.fig'))


% windowed Var %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedVARFig = figure();

for i = 1:size(segmentMatrixControl, 1)
    moveVARsegmentMatrixControl(i,:) = movvar(segmentMatrixControl(i,:), windowLen);
    moveVARsegmentMatrixGCaMP(i,:) = movvar(segmentMatrixGCaMP(i,:), windowLen);
    moveVARsegmentMatrixDifference(i,:) = movvar(segmentMatrixDifference(i,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveVARsegmentMatrixControl', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title(['Segment-' params.whichSeg ' ' params.filter ': Windowed Variance (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveVARsegmentMatrixGCaMP', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveVARsegmentMatrixDifference', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Windowed Variance (' num2str(windowLen) ' samples)'];
orient(windowedVARFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedVARFig, strcat(cd, '\', fileName, '.fig'))


% windowed CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowedCVFig = figure();

for i = 1:size(segmentMatrixControl, 1)
    moveCVsegmentMatrixControl(i,:) = movstd(segmentMatrixControl(i,:), windowLen) ./ movmean(segmentMatrixControl(i,:), windowLen);
    moveCVsegmentMatrixGCaMP(i,:) = movstd(segmentMatrixGCaMP(i,:), windowLen) ./ movmean(segmentMatrixGCaMP(i,:), windowLen);
    moveCVsegmentMatrixDifference(i,:) = movstd(segmentMatrixDifference(i,:), windowLen) ./ movmean(segmentMatrixDifference(i,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveCVsegmentMatrixControl', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title(['Segment-' params.whichSeg ' ' params.filter ': Windowed CV (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveCVsegmentMatrixGCaMP', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveCVsegmentMatrixDifference', 'color', lightBlue, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Windowed CV (' num2str(windowLen) ' samples)'];
orient(windowedCVFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedCVFig, strcat(cd, '\', fileName, '.fig'))


function figureCosmetics(params)
    % Universal Cosmetics 
    vline(params.segLen / 4, 'r')
    vline(params.segLen / 4 * 3, 'r')
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
    text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])
end
