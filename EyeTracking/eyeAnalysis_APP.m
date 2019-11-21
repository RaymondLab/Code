%  results = eyeAnalysis
% Run this to eye track on saved image files
% Adds to a results structure that already has time info
% to do - have ROI picked automatically based on pupil radius size, and
% move with pupil
% https://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
function eyeAnalysis_APP(app)

%% Parameters & Prep
load settings
prevsettings = 1;

% Shouldn't need to change unless setup changes drastically
edgeThresh = app.edgeThreshCam1EditField.Value;
plotall = app.PlotAnalysisCheckBox.Value;
debugOn = app.debugCheckBox.Value;
enchanceContrast = app.ImproveImageContrastCheckBox.Value;

% for plotting
a = 0:.1:2*pi;
the=linspace(0,2*pi,100);

%% Get Images
disp('Opening Images...')
tic
[ImageStack, n_images] = getImageStack('img1.tiff');
toc

%% Pre-process Images
disp('Preprocessing...')
tic
ImageStackB = preprocessImages(ImageStack, pos, enchanceContrast);
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

if n ~= n_images
    error('time stamps dont match number of images')
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
for i = 1:n
    if mod(i,120) ==0
        
        % Store results
        results.pupil = pupil;
        results.cra = CRa;
        results.crb = CRb;
        hp = plotresults_APP(app, results, hp, i);
    end
    
    % Load images
    img = ImageStackB(:,:,i);
    
    % Use previous frame's pupil as a starting point & radii estimate
    if i~=1
        pupilStart = pupil(i-1,:);
        
        maxRadii = max([pupil(i-1,3:4)]);
        radiiPupil(2) = round(maxRadii*1.25);
        %radiiPupil = [round(maxRadii*.8) round(maxRadii*1.2)];
    end
    
    try
        % CAMERA 1
        [pupil(i,:), CRa(i,:),CRb(i,:), ~, edgeThresh, crx, cry, epx_1, epy_1, epx2_1, epy2_1] = detectPupilCR_APP(...
            app, 1, img, 0, crx, cry,...
            'radiiPupil',radiiPupil,'radiiCR',radiiCR,...
            'EdgeThresh',edgeThresh+3,'pupilStart',pupilStart,...
            'CRthresh',CRthresh,'CRfilter',CRfilter,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        
    catch msgid
        fprintf('Error in cam 1 img %i\n',i)
        msgid.message
        edgeThresh = 35;
    end
    
    %% Plotting
    set(plottedImage,'CData',img);
    
    if ~exist('plot1', 'var')
        
        % Corneal Reflection 1
        plot1 = line(app.UIAxes2_2, CRa(i,3).*cos(a) + CRa(i,1), CRa(i,3).*sin(a) + CRa(i,2),'Color', 'b');
        plot3 = plot(app.UIAxes2_2, crx(1), cry(1),'+b', 'LineWidth',2, 'MarkerSize',10);
        
        % Corneal Reflection 2
        plot2 = line(app.UIAxes2_2, CRb(i,3).*cos(a) + CRb(i,1), CRb(i,3).*sin(a) + CRb(i,2),'Color', 'c');
        plotra = plot(app.UIAxes2_2, crx(2), cry(2),'+c', 'LineWidth',2, 'MarkerSize',10);
        
        % Pupil 
        plot5 = line(app.UIAxes2_2, ...
            pupil(i,3)*cos(the)*cos(pupil(i,5)) - sin(pupil(i,5))*pupil(i,4)*sin(the) + pupil(i,1), ...
            pupil(i,3)*cos(the)*sin(pupil(i,5)) + cos(pupil(i,5))*pupil(i,4)*sin(the) + pupil(i,2),...
            'Color','m');
        plot4 = plot(app.UIAxes2_2, pupil(i,1), pupil(i,2),'+m','LineWidth',2, 'MarkerSize',10);
        
        plot6 = plot(app.UIAxes2_2, epx_1, epy_1,'.c');
        plot7 = plot(app.UIAxes2_2, epx2_1, epy2_1,'.y');
    else
        
        %% Right Plot
        set(plot1, 'XData', CRa(i,3).*cos(a) + CRa(i,1))
        set(plot1, 'YData', CRa(i,3).*sin(a) + CRa(i,2))
        set(plot2, 'XData', CRb(i,3).*cos(a) + CRb(i,1))
        set(plot2, 'YData', CRb(i,3).*sin(a) + CRb(i,2))
        set(plot3, 'XData', crx(1))
        set(plot3, 'YData', cry(1))
        set(plotra, 'XData', crx(2))
        set(plotra, 'YData', cry(2))
        set(plot4, 'XData', pupil(i,1))
        set(plot4, 'YData', pupil(i,2))
        set(plot5, 'XData', pupil(i,3)*cos(the)*cos(pupil(i,5)) - sin(pupil(i,5))*pupil(i,4)*sin(the) + pupil(i,1))
        set(plot5, 'YData', pupil(i,3)*cos(the)*sin(pupil(i,5)) + cos(pupil(i,5))*pupil(i,4)*sin(the) + pupil(i,2))
        set(plot6, 'XData', epx_1)
        set(plot6, 'YData', epy_1)
        set(plot7, 'XData', epx2_1)
        set(plot7, 'YData', epy2_1)
    end
    
    drawnow
    pause(0.001) % needed for things actually plot.
end

toc
%% Store results
results.pupil1 = pupil;
results.pupil2 = pupil2;
results.cr1a = CRa;
results.cr2a = CR2a;
results.cr1b = CRb;
results.cr2b = CR2b;

%% Plot Summary
A = figure('units','normalized','outerposition',[0 0 1 1]); clf

TrackSumFig = tight_subplot(2,1,[.01 .025],[.025 .025],[.03 .01]);
axes(TrackSumFig(1));

plot( results.time1, results.pupil1(:,1),'r-');hold on
plot( results.time2, results.pupil2(:,1),'m-');
plot( results.time1, results.cr1a(:,1),'b-');
plot( results.time2, results.cr2b(:,1),'c-');
xticks([])
box off
xlim( [results.time2(1+1) results.time2(end-1)]);

ylabel( 'Horiz Pos (pix)')

axes(TrackSumFig(2));
plot( results.time1,max(results.pupil1(:,3:4),[],2),'r-'); hold on
plot( results.time2,max(results.pupil2(:,3:4),[],2),'m-');  
plot( results.time1,results.cr1a(:,3),'b-');
plot( results.time2,results.cr2b(:,3),'c-');  
box off
legend({'Cam1 - Pupil' 'Cam2 - Pupil', 'Cam1 - Left CR', 'Cam2 - Right CR'})
xlim( [results.time2(1) results.time2(end)]);
ylabel( 'radii (pix)' )
xlabel( 'Time (s)')

set(A,'Units','Inches');
pos = get(A,'Position');
set(A,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(A, fullfile(cd, 'Summary_EyeTracking.pdf'),'-dpdf');
savefig('Summary_EyeTracking.fig')


%% Save Data
save('videoresults.mat','results')
fprintf('\nResults saved\n')
warning on

