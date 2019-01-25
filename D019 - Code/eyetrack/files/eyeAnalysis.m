%  results = eyeAnalysis
% Run this to eye track on saved image files
% Adds to a results structure that already has time info
% to do - have ROI picked automatically based on pupil radius size, and
% move with pupil

%% Parameters - try changing if needed
load settings
prevsettings = 1;

% Shouldn't need to change unless setup changes drastically
edgeThresh1 = 35; % Initial gradient threshold of pupil edge detection for cam 1
edgeThresh2 = 35; % Initial gradient threshold of pupil edge detection for cam 2
plotall= 1;
debugOn = 0;

%% Load results time file
figure(1); clf;  set(1,'WindowStyle','docked')  

load(fullfile(cd,'time.mat'));

n = length(results.time1);
info1 = imfinfo('img1.tiff');
info2 = imfinfo('img2.tiff');
n_images = numel(info1);
if n ~= n_images
    error('time stamps dont match number of images')
end

disp(repmat('.',1,sum(mod(1:n,30)==0)))

pupil1 = NaN(n,5);
pupil2 = NaN(n,5);
CR1a = NaN(n,3);
CR2a = NaN(n,3);
CR1b = NaN(n,3);
CR2b = NaN(n,3);

warning off

tic
h = waitbar(0,'0 % analyzed');
  
%% Start looping
for i = 1:n
% i = i-1;
    % Make a progress bar
    if mod(i,30) ==0
        
        waitbar(i/n,h,sprintf('%.0f %% analyzed',i/n*100));
        
%         fprintf('.');

        % Store results & save incrementally
        results.pupil1 = pupil1;
        results.pupil2 = pupil2;
        results.cr1a = CR1a;
        results.cr2a = CR2a;
        results.cr1b = CR1b;
        results.cr2b = CR2b;
        save('videoresults.mat','results')

        figure(2); set(gcf,'WindowStyle','docked') 
        plotresults(results)
    end
    
	% Load images
    img1 = imread(fullfile(cd, 'img1.tiff'),'Index',i,'Info',info1);
    img2 = imread(fullfile(cd, 'img2.tiff'),'Index',i,'Info',info2);
    
    % Upsample image for better detection of CR
    img1 = imresize(img1,2);
    img2 = imresize(img2,2);
       
    % Enhance contrast
    if imAdjust
        img1 = imadjust(img1);
        img2 = imadjust(img2);
    end
    
    % Use the previous pupil location as a starting point
    if i~=1
        pupilStart1 = pupil1(i-1,:);
        pupilStart2 = pupil2(i-1,:);
    end
    
    % Select ROI
    img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
    img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));
        
    img1 = imfilter(img1, fspecial('gaussian',3,.5));
    img2 = imfilter(img2, fspecial('gaussian',3,.5));    
    
    try
        %% CAMERA 1
        figure(1); subplot(1,2,1); cla;    
        [pupil1(i,:), CR1a(i,:), CR1b(i,:),points1, edgeThresh1] = detectPupilCR(...
            img1,'radiiPupil',radiiPupil,'radiiCR',radiiCR1,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart1,...
            'CRthresh',CRthresh1,'CRfilter',CRfilter1,'PlotOn',plotall,...
            'MinFeatures',minfeatures,'debugOn',debugOn);
    catch msgid
        fprintf('Error in cam 1 img %i\n',i)
        msgid
        edgeThresh1 = 35;
    end
    
    try
        %% CAMERA 2
        figure(1); subplot(1,2,2); cla
        [pupil2(i,:), CR2a(i,:),CR2b(i,:), points2, edgeThresh2] = detectPupilCR(...
            img2,'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);

    catch msgid
        fprintf('Error in cam 2 img %i\n',i)
        msgid
        edgeThresh2 = 35;                
    end;
    
    drawnow;
end

close(h);

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
t=toc;
fprintf('Processing time %f per 100 images\n',t/n *100)
warning on

