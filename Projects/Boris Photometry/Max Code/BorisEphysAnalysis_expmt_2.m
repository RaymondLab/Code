%{
TODO
    - Go back and look for wierdness
        - light on off
        - movement artifacts
        - investigate HUGE transients
NOTES
    - All ephys data is DEBLEACHED
    Mouse 1
        Recording 1
            2 Segments (1,2)
        Recording 2
            3 Segments (3,4,5)
    Mouse 2
        Recording 1
            8 Segments (6,7,8,9,10,12,13)        
%} 


%% Build params
clear;clc;close all
lightGreen = [117 187 49] ./ 255;

% Choose Segment
params.whichSeg = 'M115_R1_S2';

% Filtered or Unfiltered
params.filter = 'Unfiltered';

% What direction? % TEMP. This is only needed for unique situations!!!
params.direction = 'R';

switch params.whichSeg 
    
    case 'M114_R1_S1'
        params.mouse = 1;
        params.segment = [734 2014];
        params.segLen = 800;
    case 'M114_R1_S2' % done
        params.mouse = 1;
        params.segment = [2414 3459];
        params.segLen = 1600;

    case 'M114_R2_S1'
        params.mouse = 2;
        params.segment = [5040 7285];
        params.segLen = 1600;
    case 'M114_R2_S2'
        params.mouse = 2;
        params.segment = [7689 8650];
        params.segLen = 1600;
    case 'M114_R2_S3' % RR_LL_ each sub-trial is 4 seconds. 40d range. 80d total.
        params.mouse = 2;
        params.segment = [9770 11370];
        params.segLen = 2400;
        
    case 'M115_R1_S1' % SPECIAL!!!!!
        params.mouse = 3;
        params.segment = [308 3753];
        params.segLen = [];
    case 'M115_R1_S2' % SPECIAL!!!!!
        params.mouse = 3;
        params.segment = [5509 14425];
        params.segLen = [];
    case 'M115_R1_S3' % 20d range (40 total
        params.mouse = 3;
        params.segment = [14869 14989];
        params.segLen = 200;
    case 'M115_R1_S4' % 10d range (20 total)
        params.mouse = 3;
        params.segment = [15269 15589];
        params.segLen = 200;
    case 'M115_R1_S5' % 10d range (20 total)
        params.mouse = 3;
        params.segment = [15949 17432];
        params.segLen = 400; 
    case 'M115_R1_S6' % 20d range (40 total)
        params.mouse = 3;
        params.segment = [17934 19949];
        params.segLen = 800; 
    case 'M115_R1_S7' % 20d range (40 total)
        params.mouse = 3;
        params.segment = [21829 23682];
        params.segLen = 800;        
    case 'M115_R1_S8' %  R_L_ each segment is 4 seconds. 16 second total. 20 degree range (40 total).
        params.mouse = 3;
        params.segment = [25029 27909];
        params.segLen = 1600; 
               
end
%params.direction = {'L', 'R'}; 

%% Gather matrix of relevent segments for each of the conditions

% Control
params.channel = 'Control';
segmentMatrixControl = segMatrix(params);
%title_Control = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% GCaMP
params.channel = 'GCaMP';
segmentMatrixGCaMP = segMatrix(params);
%title_GCaMP = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% Difference between the two channels
params.channel = 'Difference';
segmentMatrixDifference = segMatrix(params);
%title_Difference = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

%% direction seperation TEMP COMMENT THIS OUT UNLESS SPECIAL CASE
if params.direction == 'R'
    segmentMatrixControl = segmentMatrixControl(1:2:end, :);
    segmentMatrixGCaMP = segmentMatrixGCaMP(1:2:end, :);
    segmentMatrixDifference = segmentMatrixDifference(1:2:end, :);
else 
    segmentMatrixControl = segmentMatrixControl(2:2:end, :);
    segmentMatrixGCaMP = segmentMatrixGCaMP(2:2:end, :);
    segmentMatrixDifference = segmentMatrixDifference(2:2:end, :);
end

%% plot the individual traces and their means
subplotfigure = figure();

% 1) Mean of GCaMP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanGCaMP = subplot(3, 1, 1);
plot(segmentMatrixControl', 'color', lightGreen); hold on;
plot(nanmean(segmentMatrixControl), 'k', 'linewidth', 2)
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Mean - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% 2) Mean of Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MeanControl = subplot(3, 1, 2);
plot(segmentMatrixGCaMP','color', lightGreen); hold on;
plot(nanmean(segmentMatrixGCaMP), 'k', 'linewidth', 2)
title('GCaMP')
figureCosmetics(params)

% 3) Mean of Difference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanDifference = subplot(3, 1, 3);
plot(segmentMatrixDifference', 'color', lightGreen); hold on;
plot(nanmean(segmentMatrixDifference), 'k', 'linewidth', 2)
title('Difference')
figureCosmetics(params)

% save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Means'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))

%% Plot various measures of variation in the data
subplotfigure = figure();

% 1) Variance between each cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varFig = subplot(4, 1, 1);
plot(nanvar(segmentMatrixControl, 0, 1), 'b'); hold on
plot(nanvar(segmentMatrixGCaMP, 0, 1), 'color', lightGreen);
plot(nanvar(segmentMatrixDifference, 0, 1), 'k');
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Variance'])
legend('Control', 'GCaMP', 'Difference')
figureCosmetics(params)

% 2) CV at each timepoints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cvFig = subplot(4, 1, 2);
plot(nanstd(segmentMatrixControl, 1) ./ nanmean(segmentMatrixControl, 1) * 100, 'b'); hold on
plot(nanstd(segmentMatrixGCaMP, 1) ./ nanmean(segmentMatrixGCaMP, 1) * 100, 'color', lightGreen);
%plot(nanstd(segmentMatrixDifference, 1) ./ nanmean(segmentMatrixDifference, 1) * 100, 'k');
title('Coeficient of Variance')
figureCosmetics(params)

% 3) SD at each time point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdFig = subplot(4,1,3);
plot(nanstd(segmentMatrixControl, 1), 'b'); hold on
plot(nanstd(segmentMatrixGCaMP, 1), 'color', lightGreen);
plot(nanstd(segmentMatrixDifference, 1), 'k');
title('Standard Deviation')
figureCosmetics(params)

% 4) Mean at each timepoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanFig = subplot(4,1,4);
plot(nanmean(segmentMatrixControl, 1), 'b'); hold on
plot(nanmean(segmentMatrixGCaMP, 1), 'color', lightGreen);
%plot(nanmean(segmentMatrixDifference, 1), 'k');
title('Mean')
figureCosmetics(params)

% Save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Measures of Variation'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))

%% Windowed Measures
% windowed SD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

windowLen = 100;
windowedSDFig = figure();

for i = 1:size(segmentMatrixControl, 1)
    moveSTDsegmentMatrixControl(i,:) = movstd(segmentMatrixControl(i,:), windowLen);
    moveSTDsegmentMatrixGCaMP(i,:) = movstd(segmentMatrixGCaMP(i,:), windowLen);
    moveSTDsegmentMatrixDifference(i,:) = movstd(segmentMatrixDifference(i,:), windowLen);
end

% Control
subplot(3,1,1)
plot(moveSTDsegmentMatrixControl', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Standard Deviation (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveSTDsegmentMatrixGCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveSTDsegmentMatrixDifference', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveSTDsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Standard Deviation (' num2str(windowLen) ' samples)'];
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
plot(moveMEANsegmentMatrixControl', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Mean (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveMEANsegmentMatrixGCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveMEANsegmentMatrixDifference', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveMEANsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Mean (' num2str(windowLen) ' samples)'];
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
plot(moveVARsegmentMatrixControl', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Variance (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveVARsegmentMatrixGCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveVARsegmentMatrixDifference', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveVARsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Variance (' num2str(windowLen) ' samples)'];
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
plot(moveCVsegmentMatrixControl', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixControl, 1), 'k', 'lineWidth', 2)
title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed CV (' num2str(windowLen) ' samples) - Control'])
legend('Individual Trials', 'Mean')
figureCosmetics(params)

% GCaMP
subplot(3,1,2)
plot(moveCVsegmentMatrixGCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixGCaMP, 1), 'k', 'lineWidth', 2)
title('GCamp')
figureCosmetics(params)

% Difference
subplot(3,1,3)
plot(moveCVsegmentMatrixDifference', 'color', lightGreen, 'lineWidth', .3); hold on
plot(nanmean(moveCVsegmentMatrixDifference, 1), 'k', 'lineWidth', 2)
title('Difference')
figureCosmetics(params)

% Save Figure
fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed CV (' num2str(windowLen) ' samples)'];
orient(windowedCVFig,'landscape')
print(fileName, '-dpdf', '-bestfit')
saveas(windowedCVFig, strcat(cd, '\', fileName, '.fig'))


%% Let user know it's done
disp('DONE! :) ')

%% tools
function figureCosmetics(params)

    % default Cosmetics 
    vline(params.segLen / 4, 'r')
    vline(params.segLen / 4 * 3, 'r')
    b = ylim;
    text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
    text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
    text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])
    
%     % Temp for 'M114_R2_S3'
%     b = ylim;
%     text(0, ((b(2)-b(1)) * .05) + b(1), '* R Motion')
%     vline(params.segLen / 6, 'r')
%     text(params.segLen / 6, ((b(2)-b(1)) * .05) + b(1), '* Center')
%     vline(params.segLen / 6 * 2, 'r')
%     text(params.segLen / 6 * 2, ((b(2)-b(1)) * .05) + b(1), '* Stop')
%     vline(params.segLen / 6 * 3, 'r')
%     text(params.segLen / 6 * 3, ((b(2)-b(1)) * .05) + b(1), '* L Motion')
%     vline(params.segLen / 6 * 4, 'r')
%     text(params.segLen / 6 * 4, ((b(2)-b(1)) * .05) + b(1), '* Center')
%     vline(params.segLen / 6 * 5, 'r')
%     text(params.segLen / 6 * 5, ((b(2)-b(1)) * .05) + b(1), '* Stop')

%     % Temp for 'M115_R1_S8'
%     b = ylim;
%     text(0, ((b(2)-b(1)) * .05) + b(1), '* R Motion')    
%     vline(params.segLen / 4, 'r')
%     text(params.segLen / 4, ((b(2)-b(1)) * .05) + b(1), '* Stop')
%     vline(params.segLen / 8, 'r')
%     text(params.segLen / 8, ((b(2)-b(1)) * .05) + b(1), '* Center')
%     vline(params.segLen / 4 * 2, 'r')
%     text(params.segLen / 4 * 2, ((b(2)-b(1)) * .05) + b(1), '* L Motion')
%     vline(params.segLen / 8 * 5, 'r')
%     text(params.segLen / 8 * 5, ((b(2)-b(1)) * .05) + b(1), '* Center')
%     vline(params.segLen / 4 * 3, 'r')
%     text(params.segLen / 4 * 3, ((b(2)-b(1)) * .05) + b(1), '* Stop')


%     % Temp for unique
%     b = ylim;
%     text(0, ((b(2)-b(1)) * .05) + b(1), ['* ' params.direction ' Motion'])    
%     vline(800, 'r')
%     text(800, ((b(2)-b(1)) * .05) + b(1), '* Stop')


end
