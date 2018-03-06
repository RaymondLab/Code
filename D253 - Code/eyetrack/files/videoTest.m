function videoTest(radiiPupil, varargin)

p = inputParser;
addOptional(p,'ROIpad',[60 40]) % width x height
addOptional(p,'RadiiCR1',[10 16])
addOptional(p,'RadiiCR2',[10 16])
addOptional(p,'MinFeatures',.7)
addParamValue(p,'Manual',0)
addParamValue(p,'ImAdjust',0)
addParamValue(p,'Frame',1) % Frame of image to use
addParamValue(p,'CRthresh1',10)
addParamValue(p,'CRthresh2',10)
addParamValue(p,'CRfilter1',6)
addParamValue(p,'CRfilter2',6)

parse(p,varargin{:})
ROIpad = p.Results.ROIpad; %[xpad, ypad]
radiiCR1 = p.Results.RadiiCR1;
radiiCR2 = p.Results.RadiiCR2;
CRthresh1 = p.Results.CRthresh1;
CRthresh2 = p.Results.CRthresh2;
CRfilter1 = p.Results.CRfilter1;
CRfilter2 = p.Results.CRfilter2;
minfeatures = p.Results.MinFeatures;
manual = p.Results.Manual;
imAdjust = p.Results.ImAdjust;
% roiwidth = ROIdim(1);
% roiheight = ROIdim(2);


%% Load image to test
frame = 1;
[img1large, img2large] = readImg(frame);

%% Test pupil location
% figure; set(1,'WindowStyle','docked')
if length(radiiPupil)==1
    radiiPupil  = [radiiPupil(1)-20 radiiPupil(1)+20]; % Guess pupil radius in pixels
end

if manual
    [pupilStartLarge1,pupilStartLarge2] = testradiipupilmanual(img1large, img2large);
else
    [pupilStartLarge1,pupilStartLarge2] = testradiipupil(img1large, img2large, radiiPupil,0); % dbgon=0
end

%% convert to small ROI
[pos1, pos2, pupilStart1, pupilStart2] = convertPosition(pupilStartLarge1,pupilStartLarge2,radiiPupil, ROIpad, size(img1large));

edgeThresh1 = 35; % Initial gradient threshold of pupil edge detection for cam 1
edgeThresh2 = 35; % Initial gradient threshold of pupil edge detection for cam 2
plotall= 1;
debugOn = 0;

ok = 0;
while ~ok && frame<10
    
    %% Select ROI
    [img1, img2] = readImg(frame, pos1, pos2);
    
    %% CAMERA 1
    try
        figure; subplot(1,2,1); cla;    set(2,'WindowStyle','docked')
        [pupil1, CR1a, CR1b] = detectPupilCR(...
            img1,'radiiPupil',radiiPupil,'radiiCR',radiiCR1,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart1,...
            'CRthresh',CRthresh1,'CRfilter',CRfilter1,'PlotOn',plotall,...
            'MinFeatures',minfeatures,'debugOn',debugOn);
        ok = 1;
    catch msgid
        warning(msgid.message)
        ok = 0;
    end    
    
    %% CAMERA 2
    try
        subplot(1,2,2); cla
        [pupil2, CR2a,CR2b] = detectPupilCR(...
            img2,'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        continue;
    catch msgid
        warning(msgid.message)
        ok = 0;
    end
    
    % Try next frame if bad image
    frame = frame + 1;        
end


if manual
    meanPupilradius = mean([max(pupil1(3:4)) max(pupil2(3:4))])
else
    
    %% Run again using found pupil center and radius
    for k = 1:10
        try 
        meanPupilradius = mean([max(pupil1(3:4)) max(pupil2(3:4))])
        radiiPupil = [meanPupilradius-20 meanPupilradius+20]; % Guess pupil radius in pixels
        
        pupilStartLarge1 = pupilStartLarge1 + pupil1(1:2) - pupilStart1;
        pupilStartLarge2 = pupilStartLarge2 + pupil2(1:2) - pupilStart2;
        
        [pos1, pos2, pupilStart1, pupilStart2] = convertPosition(pupilStartLarge1, pupilStartLarge2, radiiPupil, ROIpad, size(img1large));
        
        [img1, img2] = readImg(frame, pos1, pos2);
        subplot(1,2,1); cla;    set(2,'WindowStyle','docked')
        [pupil1, CR1a, CR1b] = detectPupilCR(...
            img1,'radiiPupil',radiiPupil,'radiiCR',radiiCR1,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart1,...
            'CRthresh',CRthresh1,'CRfilter',CRfilter1,'PlotOn',plotall,...
            'MinFeatures',minfeatures,'debugOn',debugOn);
        subplot(1,2,2); cla
        [pupil2, CR2a,CR2b] = detectPupilCR(...
            img2,'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        drawnow;
        if sum(abs([pupil1(1:2) - pupilStart1  pupil2(1:2) - pupilStart2]))<10; break; end
        catch
            disp('Detection failed, try manually')
            return
        end
    end
end
meanCRradius = mean([CR1a(3)  CR1b(3) CR2a(3) CR2b(3)])

%% Save settings
save('settings','pos1','pos2','radiiPupil','minfeatures',...
    'radiiCR1','CRthresh1','CRfilter1','radiiCR2','CRthresh2','CRfilter2',...
    'imAdjust','ROIpad','pupilStart1','pupilStart2','manual')

    function [img1, img2] = readImg(frame, pos1, pos2)
        %% Load sample images
        img1 = imread(fullfile(cd, 'img1.tiff'),'Index',frame);
        img2 = imread(fullfile(cd, 'img2.tiff'),'Index',frame);
        
        % Upsample image for better detection of CR
        img1 = imresize(img1,2);
        img2 = imresize(img2,2);
        
        % Enhance contrast
        if imAdjust
            img1 = imadjust(img1);
            img2 = imadjust(img2);
        end        
        if exist('pos2','var')
            img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
            img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));
        end        
    end

end