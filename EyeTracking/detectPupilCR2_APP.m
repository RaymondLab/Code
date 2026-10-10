function [trackParams, frameData, plotData] = detectPupilCR2_APP( app, side, img, crxPrevious, cryPrevious, radiiPrevious, trackParams)

%% Preallocate
plotData.epx = nan;
plotData.epx2 = nan;
plotData.epy = nan;
plotData.epy2 = nan;
plotData.points = nan;

frameData.crx = [nan; nan];
frameData.cry = [nan; nan];
frameData.cr1 = [nan, nan, nan];
frameData.cr2 = [nan, nan, nan];
frameData.pupil = [nan, nan, nan, nan, nan];

%% Process image
img = double(img);
%figure(43)
%image(img); colormap jet
img(img < 30) = 0;
%figure(44); colormap jet
%image(img)
gaussian_smooth_image = @(I, sigma) imfilter(I, fspecial('gaussian', [ceil(2.5*sigma) ceil(2.5*sigma)], sigma), 'symmetric');
InoCR = img;
InoCR = gaussian_smooth_image(InoCR,3);
%figure(45); colormap jet
%image(InoCR)
InoCR(InoCR < 30) = 0;
%figure(46); colormap jet
%image(InoCR)

%% Detect Edges
newimg = edge(InoCR, 'Roberts', 8)*100;

%% Remove outer edge Points
newimg(~trackParams.pos2) = 0;
[row,col] = find(newimg);
allPoints = [col, row];

%% Find corneal reflections
try 
    if ~isempty(crxPrevious) && ~any(isnan(crxPrevious))

        % make initial pass on CR location % circle fit
        CRPoints(1) = rangesearch(allPoints,[crxPrevious(1),cryPrevious(1)],ceil(radiiPrevious)+2);
        CRPoints(2) = rangesearch(allPoints,[crxPrevious(2),cryPrevious(2)],ceil(radiiPrevious)+2);

        [cr1xc(1), cr1yc(1), radii(1)] = circfit(allPoints(CRPoints{1},1), allPoints(CRPoints{1},2));
        [cr2xc(1), cr2yc(1), radii(2)] = circfit(allPoints(CRPoints{2},1), allPoints(CRPoints{2},2));

        iterations = 1;
    while 1 && iterations < 11
        % Use center of circle to find new set of points & circle fit
        CRPoints(1) = rangesearch(allPoints,[cr1xc(end),cr1yc(end)],ceil(radii(1))+2);
        CRPoints(2) = rangesearch(allPoints,[cr2xc(end),cr2yc(end)],ceil(radii(2))+2);

        [cr1xc(end+1),cr1yc(end+1), radii(1)] = circfit(allPoints(CRPoints{1},1), allPoints(CRPoints{1},2));
        [cr2xc(end+1),cr2yc(end+1), radii(2)] = circfit(allPoints(CRPoints{2},1), allPoints(CRPoints{2},2));
        
        % if center hasn't moved, break 
        if cr1xc(end) == cr1xc(end-1) && cr1yc(end) == cr1yc(end-1)
            if cr2xc(end) == cr2xc(end-1) && cr2yc(end) == cr2yc(end-1)
                break
            end
        end
        
        % if you haven't reached best location in 5 iterations, break
        iterations = iterations + 1;
    end        
       
    if iterations == 10
        warning('could not find optimal CR')
    end
    

    centers = [cr1xc(end), cr1yc(end); cr2xc(end), cr2yc(end)];
    else
        [~, centers, radii] = CircularHough_Grd(newimg,trackParams.radiiCR ,trackParams.CRthresh,trackParams.CRfilter,1);
        % CRs must have appropriate radii
        centers(radii < trackParams.radiiCR(1) | radii > trackParams.radiiCR(2), :) = [];
        radii(radii < trackParams.radiiCR(1) | radii > trackParams.radiiCR(2)) = [];
        CRPoints(1) = rangesearch(allPoints,centers(1,:),ceil(radii(1))+2);
        CRPoints(2) = rangesearch(allPoints,centers(2,:),ceil(radii(2))+2);
    end
catch
    [~, centers, radii] = CircularHough_Grd(newimg,trackParams.radiiCR ,trackParams.CRthresh,trackParams.CRfilter,1);
    % CRs must have appropriate radii
    centers(radii < trackParams.radiiCR(1) | radii > trackParams.radiiCR(2), :) = [];
    radii(radii < trackParams.radiiCR(1) | radii > trackParams.radiiCR(2)) = [];
end

%% Find potential CRs
warning on
if size(centers,1) > 2
    try
        % if more than 2 detected, save the closest options to previous CRs
        for i = 1:length(radii)
            X = [crxPrevious(1),cryPrevious(1); centers(i,:)];
            cr1Dists(i) = pdist(X,'euclidean');
            X = [crxPrevious(2),cryPrevious(2); centers(i,:)];
            cr2Dists(i) = pdist(X,'euclidean');
        end
        [~, cr1Indx] = min(cr1Dists);
        [~, cr2Indx] = min(cr2Dists);
        
        centers = [centers(cr1Indx,:); centers(cr2Indx,:)];
        radii = [radii(cr1Indx); radii(cr2Indx)];

    catch
        for i = 1:length(radii)
            brightness(i) = InoCR(round(centers(i,2)), round(centers(i,1)));
        end
        [~, minIndx] = min(brightness);
        centers(minIndx,:) = [];
        radii(minIndx, :) = [];
    end

elseif size(centers,1) == 1
    warning('Detected less than two CRs')
    
else
    % Make sure crs go from left to right
    if centers(1,1) > centers(2, 1)
        centers = flip(centers,1);
        radii = flip(radii);
    end
end
warning off

%% Save and remove CR points
cr1 = [centers(1,:), radii(1)];
cr2 = [centers(2,:), radii(2)];
crx = centers(:,1);
cry = centers(:,2);
crPoints = [allPoints([CRPoints{1}],:); allPoints([CRPoints{2}],:)];
% remove CR points and area around CR points from allPoints
CR1plus = rangesearch(allPoints,[centers(1,1),centers(1,2)],ceil(radii(1))*2);
CR2plus = rangesearch(allPoints,[centers(2,1),centers(2,2)],ceil(radii(1))*2);
CRallplus = [CR1plus{:}, CR2plus{:}];
allPoints(CRallplus,:) = [];

%% Find guess for pupil center using radial symmetry transform
if isempty(trackParams.pupilStart) || any(isnan(trackParams.pupilStart)) || trackParams.pupilStart(1)==0
    alphaFRST = 0.5;           % Sensitivity to radial symmetry
    imgRadialPupil = Radial_Sym_Transform(newimg, trackParams.radiiPupil, alphaFRST);
    [pupilY, pupilX] = find(min(imgRadialPupil(:))==imgRadialPupil);
    trackParams.pupilStart = [pupilX pupilY];
end

%% Remove Erroneous pupil edge points (outliers)
% Remove points that are too far away from the mean
for i = 1:length(allPoints)
    X = [mean(allPoints(:,1)), mean(allPoints(:,2)); allPoints(i,1), allPoints(i,2)];
    d(i) = pdist(X,'euclidean');
end
TF = isoutlier(d);
allPoints(TF, :) = [];

% Hannah's method? Not really sure how this works - max
epy = allPoints(:,2);
epx = allPoints(:,1);
[~, inliers] = fit_ellipse_ransac(epx(:), epy(:), trackParams.radiiPupil);    
epx2 = epx(inliers);
epy2 = epy(inliers);

%% Fit Elipse
ellipseResult = fit_ellipse(epx2,epy2);
pupil(1) = ellipseResult.X0_in;
pupil(2) = ellipseResult.Y0_in;
pupil(3) = ellipseResult.a;
pupil(4) = ellipseResult.b;
pupil(5) = -ellipseResult.phi;
points = [epx2(:), epy2(:)];

A = mean(img, 1);
B = mean(img, 2);
s = find(A > 0, 1);
b = find(B > 0, 1);

ss = length(A) - find(flip(A) > 0, 1);
cr2Indx = length(B) - find(flip(B) > 0, 1);

% remove more points?
for i = 1:length(allPoints)
    %[RSS(i), XYproj] = Residuals_ellipse(X(2,:),pupil);
end

%% debug plotting
% figure(26)
% % subplot(1,3,1:2)
% image(newimg); hold on
% % plot cr points
% scatter(crPoints(:,1), crPoints(:,2), '.c');
% % plot pupil points
% scatter(allPoints(inliers,1), allPoints(inliers,2), '.k');
% % center of pupil
% scatter(mean(allPoints(inliers,1)), mean(allPoints(inliers,2)), '.r');
% 
% % subplot(1,3,3)
% % histogram(d, 100)

%% Plotting
if trackParams.plotOn
    
    % prep
    a = 0:.1:2*pi;
    the=linspace(0,2*pi,100);
    fig = app.UIAxes2_2;
    hold(fig, 'on');
    
    
    % image
    imagesc(fig, img);  colormap(fig, gray);%  axis off; axis image
    xlim(fig, [s, ss]);
    ylim(fig, [b, cr2Indx]);

    
    % corneal Reflection 1
    plot(fig, cr1(3).*cos(a) + cr1(1), cr1(3).*sin(a)+cr1(2),'b')
    plot(fig, crx(1), cry(1),'+b')
    
    % Corneal Reflection 2
    plot(fig, cr2(3).*cos(a) + cr2(1), cr2(3).*sin(a)+cr2(2),'c')
    plot(fig, crx(2), cry(2),'+c')
    
    % Pupil
    line(fig, pupil(3)*cos(the)*cos(pupil(5)) - sin(pupil(5))*pupil(4)*sin(the) + pupil(1), ...
              pupil(3)*cos(the)*sin(pupil(5)) + cos(pupil(5))*pupil(4)*sin(the) + pupil(2), 'Color', 'r');
    plot(fig, pupil(1), pupil(2),'+r','LineWidth',2, 'MarkerSize',10)
    
    if exist('epx','var')
        plot(fig, epx, epy,'.c')
        plot(fig, epx2, epy2,'.y')
    end
    hold(fig, 'off');
end

%% Add data to frameData object
plotData.epx = epx;
plotData.epx2 = epx2;
plotData.epy = epy;
plotData.epy2 = epy2;
plotData.points = points;

frameData.crx = crx;
frameData.cry = cry;
frameData.cr1 = cr1;
frameData.cr2 = cr2;
frameData.pupil = pupil;


