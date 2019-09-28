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
edgeThresh1 = app.edgeThreshCam1EditField.Value;
edgeThresh2 = app.edgeThreshCam2EditField.Value;
plotall = app.PlotAnalysisCheckBox.Value;
debugOn = app.debugCheckBox.Value;
enchanceContrast = app.ImproveImageContrastCheckBox.Value;

% for plotting
a = 0:.1:2*pi;
the=linspace(0,2*pi,100);

%% Get Images
disp('Opening Images...')
% tiff1
tic
FileTif1 = 'img1.tiff';
info1 = imfinfo(FileTif1);

nImage = info1(1).Height;
mImage = info1(1).Width;
n_images = length(info1);
ImageStack1 = zeros(nImage,mImage,n_images,'uint8');
TifLink1 = Tiff(FileTif1, 'r');

for i=1:n_images
    TifLink1.setDirectory(i);
    ImageStack1(:,:,i)=TifLink1.read();
end
TifLink1.close();

% tiff2
FileTif_2 = 'img2.tiff';
info2 = imfinfo(FileTif_2);

ImageStack2 = zeros(nImage,mImage,n_images,'uint8');

TifLink_2 = Tiff(FileTif_2, 'r');
for i = 1:n_images
    TifLink_2.setDirectory(i);
    ImageStack2(:,:,i) = TifLink_2.read();
end
TifLink_2.close();
toc

%% Pre-process Images
disp('Preprocessing...')
tic
ImageStack1B = preprocessImages(ImageStack1, n_images, pos1, enchanceContrast);
ImageStack2B = preprocessImages(ImageStack2, n_images, pos2, enchanceContrast);
toc

%% steup Figures
cla(app.UIAxes2);
cla(app.UIAxes2_2);
cla(app.UIAxes3);
cla(app.UIAxes3_2);

plottedImage1 = imagesc(app.UIAxes2, ImageStack1B(:,:,1));
plottedImage2 = imagesc(app.UIAxes2_2, ImageStack2B(:,:,1));

hold(app.UIAxes2, 'on');
colormap(app.UIAxes2, gray);

hold(app.UIAxes2_2, 'on');
colormap(app.UIAxes2_2, gray);

%% Load results time file

load(fullfile(cd,'time.mat'));

n = length(results.time1);

if n ~= n_images
    error('time stamps dont match number of images')
end

pupil1 = NaN(n,5);
pupil2 = NaN(n,5);
CR1a = NaN(n,3);
CR2a = NaN(n,3);
CR1b = NaN(n,3);
CR2b = NaN(n,3);
crx1 = [];
cry1 = [];
crx2 = [];
cry2 = [];

warning off
tic

%% Start looping
for i = 1:n
    if mod(i,120) ==0
        
        % Store results
        results.pupil1 = pupil1;
        results.pupil2 = pupil2;
        results.cr1a = CR1a;
        results.cr2a = CR2a;
        results.cr1b = CR1b;
        results.cr2b = CR2b;
        plotresults_APP(app, results)
    end
    
    % Load images
    img1 = ImageStack1B(:,:,i);
    img2 = ImageStack2B(:,:,i);
    
    try
        
        % Use the previous pupil location as a starting point
        if i~=1
            pupilStart1 = pupil1(i-1,:);
            pupilStart2 = pupil2(i-1,:);
        end
        %% CAMERA 1
%         [CR_Centers1, CR_radii1, ~] = imfindcircles(img1, [6 12], 'Sensitivity', .9, 'Method', 'TwoStage');
%         
%         % Only take first two circles
%         CR_Centers1 = CR_Centers1(1:2, 1:2);
%         crx1 = CR_Centers1(:,1);
%         cry1 = CR_Centers1(:,2);
%         
%         % Make sure order is correct
%         [crx1, I] = sort(crx1);
%         cry1 = cry1(I);
%         CR_radii1 = CR_radii1(I);
%         
%         % Put left CR first
%         CR1a(i,:) = [crx1(1) cry1(1) CR_radii1(1)];
%         CR1b(i,:) = [crx1(2) cry1(2) CR_radii1(2)];
%         
%         [pupil1(i,:), edgeThresh1, epx_1, epy_1, epx2_1, epy2_1] = detectPupilQuick(...
%             img1, CR_Centers1(1:2, 1:2), crx1, cry1, CR_radii1, ...
%             'pupilStart',pupilStart1, 'radiiPupil',radiiPupil, ...
%             'EdgeThresh',edgeThresh1+3, 'MinFeatures',minfeatures);
%         
        [pupil1(i,:), CR1a(i,:),CR1b(i,:), ~, edgeThresh1, crx1, cry1, epx_1, epy_1, epx2_1, epy2_1] = detectPupilCR_APP(...
            app, 1, img1, 0, crx1, cry1,...
            'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        
    catch msgid
        fprintf('Error in cam 1 img %i\n',i)
        msgid.message
        edgeThresh1 = 35;
    end
    
    
    try
        %% CAMERA 2
        [pupil2(i,:), CR2a(i,:),CR2b(i,:), ~, edgeThresh2, crx2, cry2, epx_2, epy_2, epx2_2, epy2_2] = detectPupilCR_APP(...
            app, 0, img2, 0, crx2, cry2,...
            'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        
        
    catch msgid
        fprintf('Error in cam 2 img %i\n',i)
        msgid.message
        edgeThresh2 = 35;
    end
    
    %% Plotting
    set(plottedImage1,'CData',img1);
    set(plottedImage2,'CData',img2);
    
    if ~exist('plotl1', 'var')
        
        %% Left Plot
        % Corneal Reflection 1
        plotl1 = plot(app.UIAxes2, CR1a(i,3).*cos(a) + CR1a(i,1), CR1a(i,3).*sin(a) + CR1a(i,2),'b');
        plotl3 = plot(app.UIAxes2, crx1(1), cry1(1),'+b', 'LineWidth', 2, 'MarkerSize',10);
        
        % Corneal Reflection 2
        plotl2 = plot(app.UIAxes2, CR1b(i,3).*cos(a) + CR1b(i,1), CR1b(i,3).*sin(a) + CR1b(i,2),'c');
        plotl3a = plot(app.UIAxes2, crx1(2), cry1(2),'+c', 'LineWidth', 2, 'MarkerSize',10);
        
        % Pupil 
        plotl5 = line(app.UIAxes2, ...
            pupil1(i,3)*cos(the)*cos(pupil1(i,5)) - sin(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,1), ...
            pupil1(i,3)*cos(the)*sin(pupil1(i,5)) + cos(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,2),...
            'Color','m');
        plotl4 = plot(app.UIAxes2, pupil1(i,1), pupil1(i,2),'+m','LineWidth', 2, 'MarkerSize',10);
        
        plotl6 = plot(app.UIAxes2, epx_1, epy_1,'.c');
        plotl7 = plot(app.UIAxes2, epx2_1, epy2_1,'.y');
        
        %% Right Plot
        % Corneal Reflection 1
        plotr1 = plot(app.UIAxes2_2, CR2a(i,3).*cos(a) + CR2a(i,1), CR2a(i,3).*sin(a) + CR2a(i,2),'b');
        plotr3 = plot(app.UIAxes2_2, crx2(1), cry2(1),'+b', 'LineWidth',2, 'MarkerSize',10);
        
        % Corneal Reflection 2
        plotr2 = plot(app.UIAxes2_2, CR2b(i,3).*cos(a) + CR2b(i,1), CR2b(i,3).*sin(a) + CR2b(i,2),'c');
        plotr3a = plot(app.UIAxes2_2, crx2(2), cry2(2),'+c', 'LineWidth',2, 'MarkerSize',10);
        
        % Pupil 
        plotr5 = line(app.UIAxes2_2, ...
            pupil2(i,3)*cos(the)*cos(pupil2(i,5)) - sin(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,1), ...
            pupil2(i,3)*cos(the)*sin(pupil2(i,5)) + cos(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,2),...
            'Color','m');
        plotr4 = plot(app.UIAxes2_2, pupil2(i,1), pupil2(i,2),'+m','LineWidth',2, 'MarkerSize',10);
        
        plotr6 = plot(app.UIAxes2_2, epx_2, epy_2,'.c');
        plotr7 = plot(app.UIAxes2_2, epx2_2, epy2_2,'.y');
    else
        %% Left Plot
        set(plotl1, 'XData', CR1a(i,3).*cos(a) + CR1a(i,1))
        set(plotl1, 'YData', CR1a(i,3).*sin(a) + CR1a(i,2))
        set(plotl2, 'XData', CR1b(i,3).*cos(a) + CR1b(i,1))
        set(plotl2, 'YData', CR1b(i,3).*sin(a) + CR1b(i,2))
        set(plotl3, 'XData', crx1(1))
        set(plotl3, 'YData', cry1(1))
        set(plotl3a, 'XData', crx1(2))
        set(plotl3a, 'YData', cry1(2))
        set(plotl4, 'XData', pupil1(i,1))
        set(plotl4, 'YData', pupil1(i,2))
        set(plotl5, 'XData', pupil1(i,3)*cos(the)*cos(pupil1(i,5)) - sin(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,1))
        set(plotl5, 'YData', pupil1(i,3)*cos(the)*sin(pupil1(i,5)) + cos(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,2))
        set(plotl6, 'XData', epx_1)
        set(plotl6, 'YData', epy_1)
        set(plotl7, 'XData', epx2_1)
        set(plotl7, 'YData', epy2_1)
        
        %% Right Plot
        set(plotr1, 'XData', CR2a(i,3).*cos(a) + CR2a(i,1))
        set(plotr1, 'YData', CR2a(i,3).*sin(a) + CR2a(i,2))
        set(plotr2, 'XData', CR2b(i,3).*cos(a) + CR2b(i,1))
        set(plotr2, 'YData', CR2b(i,3).*sin(a) + CR2b(i,2))
        set(plotr3, 'XData', crx2(1))
        set(plotr3, 'YData', cry2(1))
        set(plotr3a, 'XData', crx2(2))
        set(plotr3a, 'YData', cry2(2))
        set(plotr4, 'XData', pupil2(i,1))
        set(plotr4, 'YData', pupil2(i,2))
        set(plotr5, 'XData', pupil2(i,3)*cos(the)*cos(pupil2(i,5)) - sin(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,1))
        set(plotr5, 'YData', pupil2(i,3)*cos(the)*sin(pupil2(i,5)) + cos(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,2))
        set(plotr6, 'XData', epx_2)
        set(plotr6, 'YData', epy_2)
        set(plotr7, 'XData', epx2_2)
        set(plotr7, 'YData', epy2_2)
    end
    
    pause(0.001)
end
toc
%% Store results
results.pupil1 = pupil1;
results.pupil2 = pupil2;
results.cr1a = CR1a;
results.cr2a = CR2a;
results.cr1b = CR1b;
results.cr2b = CR2b;

%% Plot and save
figure(2);clf
plotresults(results)
save('videoresults.mat','results')
fprintf('\nResults saved\n')
fprintf('Processing time %f per 100 images\n',t/n *100)
warning on

