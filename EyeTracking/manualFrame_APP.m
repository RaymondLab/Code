function [vars, trackParams, frameData] = manualFrame_APP(app, vars, trackParams, frameData, frame)

%% Set up Figure
manFig = figure();
manualFrameFig = tight_subplot(2,1,[0 0],[.0 .02],[0 0]); 

subplot(2,2,3)
[previousImage] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame-1);
imagesc(previousImage); colormap(gray); axis image;box off; xticks([]); yticks([]);
title('PREVIOUS FRAME');

subplot(2,2,4)
[nextImage] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame+1);
imagesc(nextImage); colormap(gray); axis image;box off; xticks([]); yticks([]);
title('NEXT FRAME');

axes(manualFrameFig(1))
[imgLarge] = readImg_APP(trackParams.imAdjust, trackParams.cam, frame);
imagesc(imgLarge); colormap(gray); axis image;box off; xticks([]); yticks([]);

%% Do the Drawing
title('Draw an elipse on the borders of the Pupil.')
roiPupil = drawellipse('Color', 'r');

title('Draw an elipse on the borders of the LEFTMOST corneal reflection.')
roiCR1 = drawcircle('Color', 'b');

title('Draw an elipse on the borders of the RIGHTMOST corneal reflection.')
roiCR2 = drawcircle('Color', 'c');

title('Edit your selections. When satisfied, press ''esc''')

pause

%% Confirm with user
answer = questdlg('Keep These Results?', ...
	'Manual Pupil/CR Identificaion', ...
	'Yes','No','Remove Entire Frame','No');
% Handle response
switch answer
    case 'Yes'
        frameData(frame).cr1_x = roiCR1.Center(1);
        frameData(frame).cr1_y = roiCR1.Center(2);
        frameData(frame).cr1_r = roiCR1.Radius;

        frameData(frame).cr2_x = roiCR2.Center(1);
        frameData(frame).cr2_y = roiCR2.Center(2);
        frameData(frame).cr2_r = roiCR2.Radius;

        frameData(frame).pupil_x = roiPupil.Center(1);
        frameData(frame).pupil_y = roiPupil.Center(2);
        frameData(frame).pupil_r1 = roiPupil.SemiAxes(2);
        frameData(frame).pupil_r2 = roiPupil.SemiAxes(1);
        frameData(frame).pupil_angle = roiPupil.RotationAngle;
        app.ManualFrameReDosPanel.Children(end).Items(contains(app.ManualFrameReDosPanel.Children(end).Items, {num2str(frame)})) = [];
    case 'No'
    case 'Remove Entire Frame'
        frameData(frame).cr1_x = nan;
        frameData(frame).cr1_y = nan;
        frameData(frame).cr1_r = nan;

        frameData(frame).cr2_x = nan;
        frameData(frame).cr2_y = nan;
        frameData(frame).cr2_r = nan;

        frameData(frame).pupil_x = nan;
        frameData(frame).pupil_y = nan;
        frameData(frame).pupil_r1 = nan;
        frameData(frame).pupil_r2 = nan;
        frameData(frame).pupil_angle = nan;
        app.ManualFrameReDosPanel.Children(end).Items(contains(app.ManualFrameReDosPanel.Children(end).Items, {num2str(frame)})) = [];
end
close(manFig)

%% Update figure
app.UIAxes3.Children(end).YData = [frameData.pupil_x];

app.UIAxes3_2.Children(end).YData = [frameData.cr1_x] - frameData(1).cr1_x;
app.UIAxes3_2.Children(end-1).YData = [frameData.cr2_x] - frameData(1).cr2_x;

app.UIAxes3_3.Children(end).YData = [frameData.cr1_r];
app.UIAxes3_3.Children(end-1).YData = [frameData.cr2_r];


