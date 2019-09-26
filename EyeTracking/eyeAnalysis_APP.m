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


% for plotting
a = 0:.1:2*pi;
the=linspace(0,2*pi,100);

%% Get Images
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

%% Pre-process Stack of images
tic
img1 = ImageStack1(:,:,1);
img2 = ImageStack2(:,:,1);

% Upsample image for better detection of CR
img1 = imresize(img1,2);
img2 = imresize(img2,2);

% Enhance contrast
if app.ImproveImageContrastCheckBox.Value
    img1 = imadjust(img1);
    img2 = imadjust(img2);
end

% Select ROI
img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));

img1 = imfilter(img1, fspecial('gaussian',3,.5));
img2 = imfilter(img2, fspecial('gaussian',3,.5));

% Pre Allocate 3D Matrix using the gathered size, and store
ImageStack1B = zeros(size(img1,1),size(img1,2),n_images,'uint8');
ImageStack2B = zeros(size(img2,1),size(img2,2),n_images,'uint8');
ImageStack1B(:,:,1) = img1;
ImageStack2B(:,:,1) = img2;


for i = 2:n_images
    img1 = ImageStack1(:,:,i);
    img2 = ImageStack2(:,:,i);
    
    % Upsample image for better detection of CR
    img1 = imresize(img1,2);
    img2 = imresize(img2,2);
    
    % Enhance contrast
    if app.ImproveImageContrastCheckBox.Value
        img1 = imadjust(img1);
        img2 = imadjust(img2);
    end
    
    % Select ROI
    img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
    img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));
        
    img1 = imfilter(img1, fspecial('gaussian',3,.5));
    img2 = imfilter(img2, fspecial('gaussian',3,.5));
    ImageStack1B(:,:,i) = img1;
    ImageStack2B(:,:,i) = img2;
end
toc

%% steup Figures
cla(app.UIAxes2);
cla(app.UIAxes2_2);
cla(app.UIAxes3);
cla(app.UIAxes3_2);

%plottedImage1 = imshow(ImageStack1B(:,:,1),'Parent',app.UIAxes2);
%plottedImage2 = imshow(ImageStack2B(:,:,1),'Parent',app.UIAxes2_2);

plottedImage1 = imagesc(app.UIAxes2, ImageStack1B(:,:,1));
plottedImage2 = imagesc(app.UIAxes2_2, ImageStack2B(:,:,1));

%xlim(app.UIAxes2, [0, size(img1,1)]);
%ylim(app.UIAxes2, [0, size(img1,2)]);
hold(app.UIAxes2, 'on');
colormap(app.UIAxes2, gray);

%xlim(app.UIAxes2_2, [0, size(img2,1)]);
%ylim(app.UIAxes2_2, [0, size(img2,2)]);
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
        save('videoresults.mat','results')
        app.UIAxes3;
        plotresults_APP(app, results)
    end
    
	% Load images
    img1 = ImageStack1B(:,:,i);
    img2 = ImageStack2B(:,:,i);
    
    % Use the previous pupil location as a starting point
    if i~=1
        pupilStart1 = pupil1(i-1,:);
        pupilStart2 = pupil2(i-1,:);
    end  
    
    try
        %% CAMERA 1
        [pupil1(i,:), CR1a(i,:), CR1b(i,:),points1, edgeThresh1, crx1, cry1, epx_1, epy_1, epx2_1, epy2_1] = detectPupilCR_APP(...
            app, 1, img1, 0, ...
            'radiiPupil',radiiPupil,'radiiCR',radiiCR1,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart1,...
            'CRthresh',CRthresh1,'CRfilter',CRfilter1,'PlotOn',plotall,...
            'MinFeatures',minfeatures,'debugOn',debugOn);
        
    catch msgid
        fprintf('Error in cam 1 img %i\n',i)
        msgid.message
        edgeThresh1 = 35;
    end

    
    try
        %% CAMERA 2
        [pupil2(i,:), CR2a(i,:),CR2b(i,:), points2, edgeThresh2, crx2, cry2, epx_2, epy_2, epx2_2, epy2_2] = detectPupilCR_APP(...
            app, 0, img2, 0, ...
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

        % Corneal Reflection 1
        plotl2 = plot(app.UIAxes2, CR1b(i,3).*cos(a) + CR1b(i,1), CR1b(i,3).*sin(a) + CR1b(i,2),'c');
        
        plotl3 = plot(app.UIAxes2, crx1, cry1,'+r');
        
        % Center of Pupil
        plotl4 = plot(app.UIAxes2, pupil1(i,1), pupil1(i,2),'+y','LineWidth',2, 'MarkerSize',10);
        
        % Pupil Elipse
        plotl5 = line(app.UIAxes2, ...
            pupil1(i,3)*cos(the)*cos(pupil1(i,5)) - sin(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,1), ...
            pupil1(i,3)*cos(the)*sin(pupil1(i,5)) + cos(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,2),...
            'Color','w');

        plotl6 = plot(app.UIAxes2, epx_1, epy_1,'.c');
        plotl7 = plot(app.UIAxes2, epx2_1, epy2_1,'.y');
        %plotl8 = plot(app.UIAxes2, points1(1,:), points1(1,:),'.y');
        
        %% Right Plot
        % Corneal Reflection 1
        plotr1 = plot(app.UIAxes2_2, CR2a(i,3).*cos(a) + CR2a(i,1), CR2a(i,3).*sin(a) + CR2a(i,2),'b');

        % Corneal Reflection 1
        plotr2 = plot(app.UIAxes2_2, CR2b(i,3).*cos(a) + CR2b(i,1), CR2b(i,3).*sin(a) + CR2b(i,2),'c');
        
        plotr3 = plot(app.UIAxes2_2, crx2, cry2,'+r');
        
        % Center of Pupil
        plotr4 = plot(app.UIAxes2_2, pupil2(i,1), pupil2(i,2),'+y','LineWidth',2, 'MarkerSize',10);
        
        % Pupil Elipse
        plotr5 = line(app.UIAxes2_2, ...
            pupil2(i,3)*cos(the)*cos(pupil2(i,5)) - sin(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,1), ...
            pupil2(i,3)*cos(the)*sin(pupil2(i,5)) + cos(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,2),...
            'Color','w');
        
        plotr6 = plot(app.UIAxes2_2, epx_2, epy_2,'.c');
        plotr7 = plot(app.UIAxes2_2, epx2_2, epy2_2,'.y');
        %plotr8 = plot(app.UIAxes2_2, points2(1,:), points2(1,:),'.y');
    else
        %% Left Plot
        set(plotl1, 'XData', CR1a(i,3).*cos(a) + CR1a(i,1))
        set(plotl1, 'YData', CR1a(i,3).*sin(a) + CR1a(i,2))
        set(plotl2, 'XData', CR1b(i,3).*cos(a) + CR1b(i,1))
        set(plotl2, 'YData', CR1b(i,3).*sin(a) + CR1b(i,2))
        set(plotl3, 'XData', crx1)
        set(plotl3, 'YData', cry1)
        set(plotl4, 'XData', pupil1(i,1))
        set(plotl4, 'YData', pupil1(i,2))
        set(plotl5, 'XData', pupil1(i,3)*cos(the)*cos(pupil1(i,5)) - sin(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,1))
        set(plotl5, 'YData', pupil1(i,3)*cos(the)*sin(pupil1(i,5)) + cos(pupil1(i,5))*pupil1(i,4)*sin(the) + pupil1(i,2))
        set(plotl6, 'XData', epx_1)
        set(plotl6, 'YData', epy_1)
        set(plotl7, 'XData', epx2_1)
        set(plotl7, 'YData', epy2_1)
        %set(plotl8, 'XData', points1(1,:))
        %set(plotl8, 'YData', points1(1,:))
        
        %% Right Plot
        set(plotr1, 'XData', CR2a(i,3).*cos(a) + CR2a(i,1))
        set(plotr1, 'YData', CR2a(i,3).*sin(a) + CR2a(i,2))
        set(plotr2, 'XData', CR2b(i,3).*cos(a) + CR2b(i,1))
        set(plotr2, 'YData', CR2b(i,3).*sin(a) + CR2b(i,2))
        set(plotr3, 'XData', crx2)
        set(plotr3, 'YData', cry2)
        set(plotr4, 'XData', pupil2(i,1))
        set(plotr4, 'YData', pupil2(i,2))
        set(plotr5, 'XData', pupil2(i,3)*cos(the)*cos(pupil2(i,5)) - sin(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,1))
        set(plotr5, 'YData', pupil2(i,3)*cos(the)*sin(pupil2(i,5)) + cos(pupil2(i,5))*pupil2(i,4)*sin(the) + pupil2(i,2))
        set(plotr6, 'XData', epx_2)
        set(plotr6, 'YData', epy_2)
        set(plotr7, 'XData', epx2_2)
        set(plotr7, 'YData', epy2_2)
        %set(plotr8, 'XData', points2(1,:))
        %set(plotr8, 'YData', points2(1,:))
    end
    
    drawnow;
end

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
t=toc
fprintf('Processing time %f per 100 images\n',t/n *100)
warning on

