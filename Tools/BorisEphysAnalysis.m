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
clear;clc

% Choose Segment
params.whichSeg = '1';

% Filtered or Unfiltered
params.filter = 'Unfiltered';

switch params.whichSeg 
    case '1'
        params.segment = [763, 4043];
        params.segLen = 800;
        params.direction = {'L', 'R'};
    case '2'
        params.segment = [5563, 6282];
        params.segLen = 400;
        params.direction = {'R', 'L'};
    case '3'
        params.segment = [6363, 7617];
        params.segLen = 200;
        params.direction = {'R', 'L'};
    case '4'
        params.segment = [8683, 10284];
        params.segLen = 400;
        params.direction = {'R', 'L'};
    case '5'
        params.segment = [11403, 13723];
        params.segLen = 400;
        params.direction = {'R', 'L'};
end


%% Gather matrix of relevent segments for each of the conditions

% Control
params.channel = 'Control';
segmentMatrixControl = segMatrix(params);
title_Control = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% GCaMP
params.channel = 'GCaMP';
segmentMatrixCGaMP = segMatrix(params);
title_GCaMP = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);

% Difference between the two channels
params.channel = 'Difference';
segmentMatrixDifference = segMatrix(params);
title_Difference = strcat('Segment_', params.whichSeg, '_', params.filter, '_', params.channel);


%% plot the individual traces and their means

darkGreen = [82 201 247] ./ 255;

fig = figure();
plot(segmentMatrix', 'color', darkGreen, 'lineWidth', .3)
hold on 
plot(nanmean(segmentMatrix',2), 'k', 'lineWidth', 2)


% other cosmetics
title(title3);
vline(params.segLen / 4, 'r')
vline(params.segLen / 4 * 3, 'r')
b = ylim;
text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])
orient(fig,'landscape')

% save Figure
print(fig, title3, '-dpdf', '-bestfit')
saveas(fig, strcat(cd, '\', title3, '.fig'))


%% Plot various measures of variation in the data
% 1) Variance between each cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
darkGreen = [37 110 4] ./ 255;


subplotfigure = figure();
varFig = subplot(4, 1, 1);
plot(nanvar(segmentMatrixControl, 0, 1), 'b');
hold on
plot(nanvar(segmentMatrixCGaMP, 0, 1), 'color', darkGreen);
plot(nanvar(segmentMatrixDifference, 0, 1), 'k');
title(['Segment-' params.whichSeg ' ' params.filter ': Variance'])

% Cosmetics
legend('Control', 'GCaMP', 'Difference')
vline(params.segLen / 4, 'r')
vline(params.segLen / 4 * 3, 'r')
b = ylim;
text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])

% 2) CV at each timepoints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cvFig = subplot(4, 1, 2);
plot(nanstd(segmentMatrixControl, 1) ./ nanmean(segmentMatrixControl, 1) * 100, 'b');
hold on
plot(nanstd(segmentMatrixCGaMP, 1) ./ nanmean(segmentMatrixCGaMP, 1) * 100, 'color', darkGreen);
%plot(nanstd(segmentMatrixDifference, 1) ./ nanmean(segmentMatrixDifference, 1) * 100, 'k');
title('Coeficient of Variance')

% Cosmetics
vline(params.segLen / 4, 'r')
vline(params.segLen / 4 * 3, 'r')
b = ylim;
text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])

% 3) SD at each time point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdFig = subplot(4,1,3);
plot(nanstd(segmentMatrixControl, 1), 'b');
hold on
plot(nanstd(segmentMatrixCGaMP, 1), 'color', darkGreen);
plot(nanstd(segmentMatrixDifference, 1), 'k');
title('Standard Deviation')

% Cosmetics
vline(params.segLen / 4, 'r')
vline(params.segLen / 4 * 3, 'r')
b = ylim;
text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])

% 4) Mean at each timepoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanFig = subplot(4,1,4);
plot(nanmean(segmentMatrixControl, 1), 'b');
hold on
plot(nanmean(segmentMatrixCGaMP, 1), 'color', darkGreen);
%plot(nanmean(segmentMatrixDifference, 1), 'k');
title('Mean')

% Cosmetics
vline(params.segLen / 4, 'r')
vline(params.segLen / 4 * 3, 'r')
b = ylim;
text(0, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .25, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{1} ])
text(params.segLen * .50, ((b(2)-b(1)) * .05) + b(1), '* Center')
text(params.segLen * .75, ((b(2)-b(1)) * .05) + b(1), ['* '  params.direction{2} ])


% save figures
fileName = ['Segment-' params.whichSeg ' ' params.filter ' Measures of Variation'];
orient(subplotfigure,'landscape')
print([fileName], '-dpdf', '-bestfit')
saveas(subplotfigure, strcat(cd, '\', fileName, '.fig'))

