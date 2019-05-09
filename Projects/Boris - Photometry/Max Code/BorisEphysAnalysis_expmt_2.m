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
params.whichSeg = 'M114_R1_S2';

% Filtered or Unfiltered
params.filter = 'Unfiltered';

% What direction? % TEMP. This is only needed for unique situations!!!
%params.direction = 'R';

switch params.whichSeg 
    
    case 'M114_R1_S1'
        params.mouse = 1;
        params.segment = [734 2014];
        params.segLen = 800;
    case 'M114_R1_S2'
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
    case 'M115_R1_S3' % 20d range (40 total)
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

params.direction = {'L', 'R'}; 
[segMat_405_Control, segMat_472_GCaMP, segMat_Diff] = segMatrix(params);

spikeAnalysis(segMat_405_Control, params)
spikeAnalysis(segMat_472_GCaMP, params)
spikeAnalysis(segMat_Diff, params)



%% direction seperation TEMP COMMENT THIS OUT UNLESS SPECIAL CASE
% if params.direction == 'R'
%     segMat_405_Control = segMat_405_Control(1:2:end, :);
%     segMat_472_GCaMP = segMat_472_GCaMP(1:2:end, :);
%     segMat_Diff = segMat_Diff(1:2:end, :);
% else 
%     segMat_405_Control = segMat_405_Control(2:2:end, :);
%     segMat_472_GCaMP = segMat_472_GCaMP(2:2:end, :);
%     segMat_Diff = segMat_Diff(2:2:end, :);
% end

%% plot the individual traces and their means
% subplotfigure = figure();
% 
% % 1) Mean of GCaMP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% meanGCaMP = subplot(3, 1, 1);
% plot(segMat_405_Control', 'color', lightGreen); hold on;
% plot(nanmean(segMat_405_Control), 'k', 'linewidth', 2)
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Mean - Control'])
% legend('Individual Trials', 'Mean')
% figureCosmetics(params)
% 
% % 2) Mean of Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MeanControl = subplot(3, 1, 2);
% plot(segMat_472_GCaMP','color', lightGreen); hold on;
% plot(nanmean(segMat_472_GCaMP), 'k', 'linewidth', 2)
% title('GCaMP')
% figureCosmetics(params)
% 
% % 3) Mean of Difference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% meanDifference = subplot(3, 1, 3);
% plot(segMat_Diff', 'color', lightGreen); hold on;
% plot(nanmean(segMat_Diff), 'k', 'linewidth', 2)
% title('Difference')
% figureCosmetics(params)
% 
% % save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Means'];
% orient(subplotfigure,'landscape')
% print([fileName], '-dpdf', '-bestfit')
% saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))

%% Plot various measures of variation in the data
% subplotfigure = figure();
% 
% % 1) Variance between each cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varFig = subplot(4, 1, 1);
% plot(nanvar(segMat_405_Control, 0, 1), 'b'); hold on
% plot(nanvar(segMat_472_GCaMP, 0, 1), 'color', lightGreen);
% plot(nanvar(segMat_Diff, 0, 1), 'k');
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Variance'])
% legend('Control', 'GCaMP', 'Difference')
% figureCosmetics(params)
% 
% % 2) CV at each timepoints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cvFig = subplot(4, 1, 2);
% plot(nanstd(segMat_405_Control, 1) ./ nanmean(segMat_405_Control, 1) * 100, 'b'); hold on
% plot(nanstd(segMat_472_GCaMP, 1) ./ nanmean(segMat_472_GCaMP, 1) * 100, 'color', lightGreen);
% %plot(nanstd(segMat_Diff, 1) ./ nanmean(segMat_Diff, 1) * 100, 'k');
% title('Coeficient of Variance')
% figureCosmetics(params)
% 
% % 3) SD at each time point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sdFig = subplot(4,1,3);
% plot(nanstd(segMat_405_Control, 1), 'b'); hold on
% plot(nanstd(segMat_472_GCaMP, 1), 'color', lightGreen);
% plot(nanstd(segMat_Diff, 1), 'k');
% title('Standard Deviation')
% figureCosmetics(params)
% 
% % 4) Mean at each timepoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% meanFig = subplot(4,1,4);
% plot(nanmean(segMat_405_Control, 1), 'b'); hold on
% plot(nanmean(segMat_472_GCaMP, 1), 'color', lightGreen);
% %plot(nanmean(segMat_Diff, 1), 'k');
% title('Mean')
% figureCosmetics(params)
% 
% % Save Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Measures of Variation'];
% orient(subplotfigure,'landscape')
% print([fileName], '-dpdf', '-bestfit')
% saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))

%% Windowed Measures
% % windowed SD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% windowLen = 100;
% windowedSDFig = figure();
% 
% for i = 1:size(segMat_405_Control, 1)
%     moveSTDsegMat_405_Control(i,:) = movstd(segMat_405_Control(i,:), windowLen);
%     moveSTDsegMat_472_GCaMP(i,:) = movstd(segMat_472_GCaMP(i,:), windowLen);
%     moveSTDsegMat_Diff(i,:) = movstd(segMat_Diff(i,:), windowLen);
% end
% 
% % Control
% subplot(3,1,1)
% plot(moveSTDsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveSTDsegMat_405_Control, 1), 'k', 'lineWidth', 2)
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Standard Deviation (' num2str(windowLen) ' samples) - Control'])
% legend('Individual Trials', 'Mean')
% figureCosmetics(params)
% 
% % GCaMP
% subplot(3,1,2)
% plot(moveSTDsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveSTDsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
% title('GCamp')
% figureCosmetics(params)
% 
% % Difference
% subplot(3,1,3)
% plot(moveSTDsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveSTDsegMat_Diff, 1), 'k', 'lineWidth', 2)
% title('Difference')
% figureCosmetics(params)
% 
% % Save Figure
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Standard Deviation (' num2str(windowLen) ' samples)'];
% orient(windowedSDFig,'landscape')
% print(fileName, '-dpdf', '-bestfit')
% saveas(windowedSDFig, strcat(cd, '\', fileName, '.fig'))
% 
% 
% 
% % windowed Mean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% windowedMeanFig = figure();
% 
% for i = 1:size(segMat_405_Control, 1)
%     moveMEANsegMat_405_Control(i,:) = movmean(segMat_405_Control(i,:), windowLen);
%     moveMEANsegMat_472_GCaMP(i,:) = movmean(segMat_472_GCaMP(i,:), windowLen);
%     moveMEANsegMat_Diff(i,:) = movmean(segMat_Diff(i,:), windowLen);
% end
% 
% % Control
% subplot(3,1,1)
% plot(moveMEANsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveMEANsegMat_405_Control, 1), 'k', 'lineWidth', 2)
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Mean (' num2str(windowLen) ' samples) - Control'])
% legend('Individual Trials', 'Mean')
% figureCosmetics(params)
% 
% % GCaMP
% subplot(3,1,2)
% plot(moveMEANsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveMEANsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
% title('GCamp')
% figureCosmetics(params)
% 
% % Difference
% subplot(3,1,3)
% plot(moveMEANsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveMEANsegMat_Diff, 1), 'k', 'lineWidth', 2)
% title('Difference')
% figureCosmetics(params)
% 
% % Save Figure
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Mean (' num2str(windowLen) ' samples)'];
% orient(windowedMeanFig,'landscape')
% print(fileName, '-dpdf', '-bestfit')
% saveas(windowedMeanFig, strcat(cd, '\', fileName, '.fig'))
% 
% 
% % windowed Var %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% windowedVARFig = figure();
% 
% for i = 1:size(segMat_405_Control, 1)
%     moveVARsegMat_405_Control(i,:) = movvar(segMat_405_Control(i,:), windowLen);
%     moveVARsegMat_472_GCaMP(i,:) = movvar(segMat_472_GCaMP(i,:), windowLen);
%     moveVARsegMat_Diff(i,:) = movvar(segMat_Diff(i,:), windowLen);
% end
% 
% % Control
% subplot(3,1,1)
% plot(moveVARsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveVARsegMat_405_Control, 1), 'k', 'lineWidth', 2)
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed Variance (' num2str(windowLen) ' samples) - Control'])
% legend('Individual Trials', 'Mean')
% figureCosmetics(params)
% 
% % GCaMP
% subplot(3,1,2)
% plot(moveVARsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveVARsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
% title('GCamp')
% figureCosmetics(params)
% 
% % Difference
% subplot(3,1,3)
% plot(moveVARsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveVARsegMat_Diff, 1), 'k', 'lineWidth', 2)
% title('Difference')
% figureCosmetics(params)
% 
% % Save Figure
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed Variance (' num2str(windowLen) ' samples)'];
% orient(windowedVARFig,'landscape')
% print(fileName, '-dpdf', '-bestfit')
% saveas(windowedVARFig, strcat(cd, '\', fileName, '.fig'))
% 
% 
% % windowed CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% windowedCVFig = figure();
% 
% for i = 1:size(segMat_405_Control, 1)
%     moveCVsegMat_405_Control(i,:) = movstd(segMat_405_Control(i,:), windowLen) ./ movmean(segMat_405_Control(i,:), windowLen);
%     moveCVsegMat_472_GCaMP(i,:) = movstd(segMat_472_GCaMP(i,:), windowLen) ./ movmean(segMat_472_GCaMP(i,:), windowLen);
%     moveCVsegMat_Diff(i,:) = movstd(segMat_Diff(i,:), windowLen) ./ movmean(segMat_Diff(i,:), windowLen);
% end
% 
% % Control
% subplot(3,1,1)
% plot(moveCVsegMat_405_Control', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveCVsegMat_405_Control, 1), 'k', 'lineWidth', 2)
% title([params.direction ' Segment - ' params.whichSeg ' ' params.filter ': Windowed CV (' num2str(windowLen) ' samples) - Control'])
% legend('Individual Trials', 'Mean')
% figureCosmetics(params)
% 
% % GCaMP
% subplot(3,1,2)
% plot(moveCVsegMat_472_GCaMP', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveCVsegMat_472_GCaMP, 1), 'k', 'lineWidth', 2)
% title('GCamp')
% figureCosmetics(params)
% 
% % Difference
% subplot(3,1,3)
% plot(moveCVsegMat_Diff', 'color', lightGreen, 'lineWidth', .3); hold on
% plot(nanmean(moveCVsegMat_Diff, 1), 'k', 'lineWidth', 2)
% title('Difference')
% figureCosmetics(params)
% 
% % Save Figure
% fileName = [params.direction ' Segment - ' params.whichSeg ' ' params.filter ' Windowed CV (' num2str(windowLen) ' samples)'];
% orient(windowedCVFig,'landscape')
% print(fileName, '-dpdf', '-bestfit')
% saveas(windowedCVFig, strcat(cd, '\', fileName, '.fig'))

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

