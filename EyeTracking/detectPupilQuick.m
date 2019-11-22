function [pupil, edgeThresh, epx, epy, epx2, epy2] = detectPupilQuick(img, circen, crx, cry, crr, varargin)

%% Process imputs
p = inputParser;
addOptional(p,'pupilStart',[]);
addParamValue(p,'radiiPupil',60);
addParamValue(p,'edgeThresh',30);
addParamValue(p,'MinFeatures',.6,@(x)x<1||x>0)

parse(p,varargin{:})

pupilStart = p.Results.pupilStart;
radiiPupil = p.Results.radiiPupil;

edgeThresh = p.Results.edgeThresh;
minfeatures = p.Results.MinFeatures;

img = double(img);

%% Find corneal reflections
maxvals = diag(img(round(circen(:,2)),round(circen(:,1))));

%% Remove corneal reflection
if ~isempty(circen)
    
    removeCRthresh = max(maxvals)*3/4; % Remove any bright spots
    totalMask = img>removeCRthresh;
    InoCR = img;
    
    for i = 1:length(crx) % Remove each CR
        [X, Y] = meshgrid(1:size(img,2), 1:size(img,1));
        maskCurr = ((X-crx(i)).^2 + (Y-cry(i)).^2) < crr(i).^2;
        totalMask(maskCurr) = true;
    end
    totalMaskDilate = imdilate(totalMask,strel('disk', 8)); %***10
    InoCR(totalMaskDilate) = NaN;
    
    gaussian_smooth_image = @(I, sigma) imfilter(I, fspecial('gaussian', [ceil(2.5*sigma) ceil(2.5*sigma)], sigma), 'symmetric');
    InoCR = gaussian_smooth_image(InoCR,3);
    
else
    InoCR = img;
end

%% Find guess for pupil center using radial symmetry transform
if isempty(pupilStart) || any(isnan(pupilStart)) || pupilStart(1)==0
    alphaFRST = 0.5;           % Sensitivity to radial symmetry
    imgRadialPupil = Radial_Sym_Transform(img, radiiPupil, alphaFRST);
    [pupilY, pupilX] = find(min(imgRadialPupil(:))==imgRadialPupil);
    pupilStart = [pupilX pupilY];
end

%% Detect pupil borders using starburst algorithm
[epx, epy, edgeThresh] = starburst_pupil_contour_detection(InoCR, pupilStart(1),...
    pupilStart(2), edgeThresh,round(radiiPupil),minfeatures);
[~, inliers] = fit_ellipse_ransac(epx(:), epy(:), radiiPupil + [-15 15]);

epx2 = epx(inliers);
epy2 = epy(inliers);

% Do better fit of resulting points
ellipseResult = fit_ellipse(epx2,epy2);
pupil(1) = ellipseResult.X0_in;
pupil(2) = ellipseResult.Y0_in;
pupil(3) = ellipseResult.a;
pupil(4) = ellipseResult.b;
pupil(5) = -ellipseResult.phi;
points = [epx2(:), epy2(:)];