%  results = eyeAnalysis
% Run this to eye track on saved image files
% Adds to a results structure that already has time info
% to do - have ROI picked automatically based on pupil radius size, and
% move with pupil
% https://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
function [trackParams, frameData] = eyeAnalysis_APP(app, trackParams, frameData)

%% Parameters & Prep
load settings

% for plotting
a = 0:.1:2*pi;
the=linspace(0,2*pi,100);

%% Get Images
disp('Opening Images...')
tic
[ImageStack, n_images] = getImageStack(['img', num2str(trackParams.cam), '.tiff']);
toc

%% Pre-process Images
disp('Preprocessing...')
tic
ImageStackB = preprocessImages(ImageStack, pos, trackParams.imAdjust);
toc

%% steup Figures
cla(app.UIAxes2_2);
cla(app.UIAxes3);
cla(app.UIAxes3_2);

plottedImage = imagesc(app.UIAxes2_2, ImageStackB(:,:,1));

hold(app.UIAxes2_2, 'on');
colormap(app.UIAxes2_2, gray);

%% Load results time file

load(fullfile(cd,'time.mat'));

n = length(results.time1);

warning on
if n ~= n_images
    warning('time stamps dont match number of images, trying to fix')
    warning(['There are only ' num2str(min([n, n_images])), ' available frames'])
    
    if n < n_images
        n_images = n;
        ImageStackB(:,:,n:end) = [];
    else
        n = n_images;
        results.time1(n:end) = [];
        results.time2(n:end) = [];
        results.time3(n:end) = [];
    end
end
warning off

frameData(n).crx = [nan; nan];
frameData(n).cry = [nan; nan];
frameData(n).cr1 = [nan, nan, nan];
frameData(n).cr2 = [nan, nan, nan];
frameData(n).pupil = [nan, nan, nan, nan, nan]; 

for i = 1:n
    frameData(i).crx = [nan; nan];
    frameData(i).cry = [nan; nan];
    frameData(i).cr1 = [nan, nan, nan];
    frameData(i).cr2 = [nan, nan, nan];
    frameData(i).pupil = [nan, nan, nan, nan, nan]; 
end
pupil = NaN(n,5);
CRa = NaN(n,3);
CRb = NaN(n,3);
crx = [];
cry = [];
hp = gobjects(6,1);

warning off

disp('Running Analysis...')
tic

%% Start looping
tic
for i = 1:n-1
    if mod(i,15) ==0
        
        % Store results
        results.pupil = pupil;
        results.cra = CRa;
        results.crb = CRb;
        hp = plotresults_APP(app, results, frameData, hp, i);
    end
    
    % Load images
    img = ImageStackB(:,:,i);
    
    % Use previous frame's pupil as a starting point & radii estimate
    if i~=1
        pupilStart = pupil(i-1,:);
        
        maxRadii = max([pupil(i-1,3:4)]);
        radiiPupil(2) = round(maxRadii*1.25);
        crx = frameData(i-1).crx;
        cry = frameData(i-1).cry;
        if isnan(maxRadii)
            maxRadii = app.RadiusPupilEditField_2.Value;
            radiiPupil(2) = maxRadii;
        end
    end
    
    try
        % Detect Pupil
        [trackParams, frameData(i), plotData] = detectPupilCR_APP(app, 1, img, crx, cry, trackParams);        
    catch msgid
        fprintf('Error in cam 1 img %i\n',i)
        msgid.message
        trackParams.edgeThresh = 35;
        %crx = frameData(find(sum(isnan([frameData.crx]),1), 1)-1).crx;
        %cry = frameData(find(sum(isnan([frameData.cry]),1), 1)-1).cry;
    end
    
    %% Plotting
    set(plottedImage,'CData',img);
    
    if ~exist('plot1', 'var')
        
        % Corneal Reflection 1
        plot1 = line(app.UIAxes2_2, CRa(i,3).*cos(a) + CRa(i,1), CRa(i,3).*sin(a) + CRa(i,2),'Color', 'b');
        plot3 = plot(app.UIAxes2_2, frameData(i).crx(1), frameData(i).cry(1),'+b', 'LineWidth',2, 'MarkerSize',10);
        
        % Corneal Reflection 2
        plot2 = line(app.UIAxes2_2, CRb(i,3).*cos(a) + CRb(i,1), CRb(i,3).*sin(a) + CRb(i,2),'Color', 'c');
        plotra = plot(app.UIAxes2_2, frameData(i).crx(2), frameData(i).cry(2),'+c', 'LineWidth',2, 'MarkerSize',10);
        
        % Pupil 
        plot5 = line(app.UIAxes2_2, ...
            frameData(i).pupil(i,3)*cos(the)*cos(frameData(i).pupil(i,5)) - sin(frameData(i).pupil(i,5))*frameData(i).pupil(i,4)*sin(the) + frameData(i).pupil(i,1), ...
            frameData(i).pupil(i,3)*cos(the)*sin(frameData(i).pupil(i,5)) + cos(frameData(i).pupil(i,5))*frameData(i).pupil(i,4)*sin(the) + frameData(i).pupil(i,2),...
            'Color','r');
        plot4 = plot(app.UIAxes2_2, frameData(i).pupil(i,1), frameData(i).pupil(i,2),'+r','LineWidth',2, 'MarkerSize',10);
        
        plot6 = plot(app.UIAxes2_2, plotData.epx, plotData.epy,'.c');
        plot7 = plot(app.UIAxes2_2, plotData.epx2, plotData.epy2,'.y');
    else
        
        %% Right Plot
        try
        set(plot1, 'XData', CRa(i,3).*cos(a) + CRa(i,1))
        set(plot1, 'YData', CRa(i,3).*sin(a) + CRa(i,2))
        set(plot2, 'XData', CRb(i,3).*cos(a) + CRb(i,1))
        set(plot2, 'YData', CRb(i,3).*sin(a) + CRb(i,2))
        set(plot3, 'XData', frameData(i).crx(1))
        set(plot3, 'YData', frameData(i).cry(1))
        set(plotra, 'XData', frameData(i).crx(2))
        set(plotra, 'YData', frameData(i).cry(2))
        set(plot4, 'XData', frameData(i).pupil(1))
        set(plot4, 'YData', frameData(i).pupil(2))
        set(plot5, 'XData', frameData(i).pupil(3)*cos(the)*cos(frameData(i).pupil(5)) - sin(frameData(i).pupil(5))*frameData(i).pupil(4)*sin(the) + frameData(i).pupil(1))
        set(plot5, 'YData', frameData(i).pupil(3)*cos(the)*sin(frameData(i).pupil(5)) + cos(frameData(i).pupil(5))*frameData(i).pupil(4)*sin(the) + frameData(i).pupil(2))
        set(plot6, 'XData', plotData.epx)
        set(plot6, 'YData', plotData.epy)
        set(plot7, 'XData', plotData.epx2)
        set(plot7, 'YData', plotData.epy2)
        catch
            disp('apple')
        end
        
    end
    
    pause(0.001) % needed for things actually plot.
   
end

toc

%% Store results
pupil = [frameData.pupil];
cr1 = [frameData.cr1];
cr2 = [frameData.cr2];

results.pupil(:,1) = pupil(1:5:end);
results.pupil(:,2) = pupil(2:5:end);
results.pupil(:,3) = pupil(3:5:end);
results.pupil(:,4) = pupil(4:5:end);
results.pupil(:,5) = pupil(5:5:end);

results.cra(:,1) = cr1(1:3:end);
results.cra(:,2) = cr1(2:3:end);
results.cra(:,3) = cr1(3:3:end);

results.crb(:,1) = cr2(1:3:end);
results.crb(:,2) = cr2(2:3:end);
results.crb(:,3) = cr2(3:3:end);

%% Save Data
save(['videoresults_cam', trackParams.cam, '.mat'],'results')
fprintf('\nResults saved\n')
warning on

%% Plot Summary
A = figure('units','normalized','outerposition',[0 0 1 1]); clf

TrackSumFig = tight_subplot(2,1,[.01 .025],[.025 .025],[.03 .01]);
axes(TrackSumFig(1));

plot( results.time1(1:end), pupil(1:5:end),'r-');hold on
plot( results.time1(1:end), cr1(1:3:end),'b-');
plot( results.time2(1:end), cr2(1:3:end),'c-');
xticks([])
box off
xlim( [results.time1(1+1) results.time1(end-1)]);

ylabel( 'Horiz Pos (pix)')

axes(TrackSumFig(2));
plot( results.time1(1:end),max(pupil(:,3:4),[],2),'r-'); hold on
plot( results.time1(1:end),cr1(3:3:end),'b-');
plot( results.time2(1:end),cr2(3:3:end),'c-');  
box off
legend({'Cam1 - Pupil' 'Cam2 - Pupil', 'Cam1 - Left CR', 'Cam2 - Right CR'})
xlim( [results.time1(1) results.time1(end)]);
ylabel( 'radii (pix)' )
xlabel( 'Time (s)')

set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(A, fullfile(cd, ['Summary_EyeTracking_Cam' num2str(trackParams.cam), '.pdf']),'-dpdf');
savefig(['Summary_EyeTracking_Cam' num2str(trackParams.cam), '.fig'])




