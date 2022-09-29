function [trackParams, frameData] = eyeAnalysis_APP(app, trackParams)

%% Parameters & Prep
a = 0:.1:2*pi;
the = linspace(0,2*pi,100);
lastGoodFrame = 1;

%% Get Images
disp('Opening Images...')
tic
customEndFrame = 9000;
[ImageStack, n_images] = getImageStack(['img', num2str(trackParams.cam), '.tiff'], customEndFrame);
toc

%% Pre-process Images
disp('Preprocessing...')
tic
ImageStackPreProcessed = preprocessImages(ImageStack, trackParams.pos, trackParams.imAdjust);
toc

%% steup Figures
cla(app.UIAxes2_2);
cla(app.UIAxes3);
cla(app.UIAxes3_2);
cla(app.UIAxes3_3);

plottedImage = imagesc(app.UIAxes2_2, ImageStackPreProcessed(:,:,1));
hp = gobjects(6,1);

hold(app.UIAxes2_2, 'on');
colormap(app.UIAxes2_2, gray);

%% Load results time file & Preallocate frameData Object
load(fullfile(cd,'time.mat'));

n = length(results.time1);
frameData = struct('cr1_x', nan, 'cr1_y', nan, 'cr1_r', nan, ...
                   'cr2_x', nan, 'cr2_y', nan, 'cr2_r', nan, ...
                   'pupil_x', nan, 'pupil_y', nan, ...
                   'pupil_r1', nan, 'pupil_r2', nan, ...
                   'pupil_angle', nan, ...
                   'time1', num2cell(results.time1), ...
                   'time2', num2cell(results.time2), ...
                   'time3', num2cell(results.time3));
               
%% Start looping
disp('Running Analysis...')
tic
for i = 1:n-1
    
    %% every 15 frames, update position and radii figures
    if mod(i,15) ==0
        hp = plotresults_APP(app, frameData, hp, i);
    end
    
    % Stop if we exceed the number frames in the tiff stack
    if i > n_images
        break
    end

    %% Load image
    img = ImageStackPreProcessed(:,:,i);
    
    %% Use most recent good frame as a starting point
    if i~=1
        lastGoodFrame = i;
        
        while (any( structfun(@isnan, frameData(lastGoodFrame)) ) || any( structfun(@isempty, frameData(lastGoodFrame)) )) && lastGoodFrame > 0
            lastGoodFrame = lastGoodFrame - 1;
        end

        maxRadii = nanmax(frameData(lastGoodFrame).pupil_r1,frameData(lastGoodFrame).pupil_r2);
        trackParams.radiiPupil(2) = round(maxRadii*1.15);
    end
    
    %% Detect Pupil  
    try
        [trackParams, frameData(i), plotData] = detectPupilCR_APP(app, img, frameData(lastGoodFrame), frameData(i), trackParams);
    catch msgid
        fprintf('Error in img %i:\n',i)
        disp(msgid.message)
        trackParams.edgeThresh = 35;
    end
    
    %% Plotting
    set(plottedImage,'CData',img);
    
    if ~exist('plot1', 'var')
        
        % Corneal Reflection 1
        plot1 = line(app.UIAxes2_2, ...
            frameData(i).cr1_r.*cos(a) + frameData(i).cr1_x, frameData(i).cr1_r.*sin(a) + frameData(i).cr1_y,'Color', 'b');
        plot3 = plot(app.UIAxes2_2, frameData(i).cr1_x, frameData(i).cr1_y,'+b', 'LineWidth',2, 'MarkerSize',10);
        
        % Corneal Reflection 2
        plot2 = line(app.UIAxes2_2, ...
            frameData(i).cr2_r.*cos(a) + frameData(i).cr2_x, frameData(i).cr2_r.*sin(a) + frameData(i).cr2_y,'Color', 'c');
        plot8 = plot(app.UIAxes2_2, frameData(i).cr2_x, frameData(i).cr2_y,'+c', 'LineWidth',2, 'MarkerSize',10);
        
        % Pupil 
        plot5 = line(app.UIAxes2_2, ...
            frameData(i).pupil_r1*cos(the)*cos(frameData(i).pupil_angle) - sin(frameData(i).pupil_angle)*frameData(i).pupil_r2*sin(the) + frameData(i).pupil_x, ...
            frameData(i).pupil_r1*cos(the)*sin(frameData(i).pupil_angle) + cos(frameData(i).pupil_angle)*frameData(i).pupil_r2*sin(the) + frameData(i).pupil_y, ...
            'Color','r');
        plot4 = plot(app.UIAxes2_2, frameData(i).pupil_x, frameData(i).pupil_y,'+r','LineWidth',2, 'MarkerSize',10);
        
        % Scatters
        plot6 = plot(app.UIAxes2_2, plotData.epx, plotData.epy,'.c');
        plot7 = plot(app.UIAxes2_2, plotData.epx2, plotData.epy2,'.y');
    else
        % Fastest way to update plot for frames after the first frame
        set(plot1, 'XData', frameData(i).cr1_r.*cos(a) + frameData(i).cr1_x)
        set(plot1, 'YData', frameData(i).cr1_r.*sin(a) + frameData(i).cr1_y)
        set(plot2, 'XData', frameData(i).cr2_r.*cos(a) + frameData(i).cr2_x)
        set(plot2, 'YData', frameData(i).cr2_r.*sin(a) + frameData(i).cr2_y)
        set(plot3, 'XData', frameData(i).cr1_x)
        set(plot3, 'YData', frameData(i).cr1_y)
        set(plot8, 'XData', frameData(i).cr2_x)
        set(plot8, 'YData', frameData(i).cr2_y)
        set(plot4, 'XData', frameData(i).pupil_x)
        set(plot4, 'YData', frameData(i).pupil_y)
        set(plot5, 'XData', frameData(i).pupil_r1*cos(the)*cos(frameData(i).pupil_angle) - sin(frameData(i).pupil_angle)*frameData(i).pupil_r2*sin(the) + frameData(i).pupil_x)
        set(plot5, 'YData', frameData(i).pupil_r1*cos(the)*sin(frameData(i).pupil_angle) + cos(frameData(i).pupil_angle)*frameData(i).pupil_r2*sin(the) + frameData(i).pupil_y)
        set(plot6, 'XData', plotData.epx)
        set(plot6, 'YData', plotData.epy)
        set(plot7, 'XData', plotData.epx2)
        set(plot7, 'YData', plotData.epy2)
        
    end
    pause(0.001) % needed for things to actually plot.
end
toc

%% Save Data
save(['videoresults_cam', num2str(trackParams.cam), '.mat'],'frameData')
fprintf('\nResults saved\n')
warning on

%% Plot Summary
A = figure('units','normalized','outerposition',[0 0 1 1]); clf

TrackSumFig = tight_subplot(2,1,[.01 .025],[.025 .025],[.03 .01]);
axes(TrackSumFig(1));

plot( [frameData.time1], [frameData.pupil_x],'r-');hold on
plot( [frameData.time1], [frameData.cr1_x],'b-');
plot( [frameData.time2], [frameData.cr2_x],'c-');
xticks([])
box off
xlim( [frameData(1).time1 frameData(end).time1]);

ylabel( 'Horiz Pos (pix)')

axes(TrackSumFig(2));
plot( [frameData.time1], nanmax([frameData.pupil_r1; frameData.pupil_r2],[],1),'r-'); hold on
plot( [frameData.time1],[frameData.cr1_r],'b-');
plot( [frameData.time2],[frameData.cr2_r],'c-');  
box off
legend({'Pupil', 'cr1', 'cr2'})
xlim( [frameData(1).time1 frameData(end).time1]);
ylabel( 'radii (pix)' )
xlabel( 'Time (s)')

set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(A, fullfile(cd, ['Summary_EyeTracking_Cam' num2str(trackParams.cam), '.pdf']),'-dpdf');
savefig(['Summary_EyeTracking_Cam' num2str(trackParams.cam), '.fig'])




