% DETECTPUPILCR detects pupil and corneal reflection in the eye image
%
% Input:
% img           = input image
% pupilStart    = start point for starburst algorithm for pupil
% radiiPupil    = guess of pupil radius
% edgeThresh    = threshold for detecting pupil
%
% radiiCR       = guess of CR radius
% CRthresh      = threshold for CR
% CRfilter      = filter size for CR
%
% Output:
% pupil_ellipse = 5-vector of the ellipse parameters of pupil
%   [cx cy  a b theta]
%   cx - the x coordinate of ellipse center
%   cy - the y coordinate of ellipse center
%   a - the ellipse axis of x direction
%   b - the ellipse axis of y direction
%   theta - the orientation of ellipse
% cr1 and cr2 = 3-vector of the circle parameters of the corneal reflection
%   [crx cry crr]
%   crx - the x coordinate of circle center
%   cry - the y coordinate of circle center
%   crr - the radius of circle
% points        = actual points on pupil detected
% edgeThresh    = actual edgeThresh used for pupil
%
% Authors: Hannah Payne
% Date: 2014
%
%
%
% MODIFIED FROM:
%
% Starburst Algorithm
%
% This source code is part of the starburst algorithm.
% Starburst algorithm is free; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% Starburst algorithm is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with cvEyeTracker; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%
% Starburst Algorithm - Version 1.0.0
% Part of the openEyes ToolKit -- http://hcvl.hci.iastate.edu/openEyes
% Release Date:
% Authors : Dongheng Li <donghengli@gmail.com>
%           Derrick Parkhurst <derrick.parkhurst@hcvl.hci.iastate.edu>
% Copyright (c) 2005
% All Rights Reserved.

function [trackParams, frameData, plotData] = detectPupilCR_APP( app, side, img, crxPrevious, cryPrevious, trackParams)

%% Process imputs
gridthresh = trackParams.CRthresh;
fltr4LM_R = trackParams.CRfilter;
img = double(img);

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

%% Find corneal reflections

% only search through portion of image, Corneal reflections shouldn't move
try 
    if ~isempty(crxPrevious) && ~any(isnan(crxPrevious))

        TOP     = max( min(cryPrevious) - max(trackParams.radiiCR)*2, 1 );
        BOTTOM  = min( max(cryPrevious) + max(trackParams.radiiCR)*2, size(img,1) );
        LEFT    = max( min(crxPrevious) - max(trackParams.radiiCR)*2, 1 );
        RIGHT   = min( max(crxPrevious) + max(trackParams.radiiCR)*2, size(img,2) );

        newImg = img(TOP:BOTTOM, LEFT:RIGHT);
        [~, circen, crr] = CircularHough_Grd(newImg,trackParams.radiiCR ,gridthresh,fltr4LM_R,1);

        %DEBUG FIGURES
%         figure(3); clf; hold on
%         image(img)
%         rectangle('Position', [LEFT (BOTTOM-abs(TOP-BOTTOM)) abs(RIGHT-LEFT) abs(TOP-BOTTOM)]) 
%         scatter(circen(:,1)+LEFT, circen(:,2)+TOP)
%         hold off
%         figure(5); clf
%         surf(img)
%         colormap(jet)
%         shading interp
        
%         figure(4); clf; hold on
%         image(newImg)
%         scatter(circen(:,1), circen(:,2))
%         hold off

        circen(:,1) = circen(:,1)+ LEFT-1;
        circen(:,2) = circen(:,2)+ TOP-1;
        
        for i = length(circen):-1:1
            img(floor(circen(i,2)), floor(circen(i,1)));
            if img(floor(circen(i,2)), floor(circen(i,1))) == 0
                circen(i,:) = [];
                crr(i) = [];
            elseif img(floor(circen(i,2)), floor(circen(i,1))) < 150
                circen(i,:) = [];
                crr(i) = [];
            end
        end
    else
        [A, circen, crr] = CircularHough_Grd(img,trackParams.radiiCR ,gridthresh,fltr4LM_R,1);
    end
catch
    [A, circen, crr] = CircularHough_Grd(img,trackParams.radiiCR ,gridthresh,fltr4LM_R,1);
end

maxvals = diag(img(round(circen(:,2)),round(circen(:,1))));

%% Check for duplicates
i=1;
while i<size(circen,1)
    duplicates = sqrt(sum((repmat(circen(i,:),size(circen,1),1) - circen).^2,2)) <30;
    duplicates(i)=0;
    circen(duplicates,:)=[];
    crr(duplicates) = [];
    maxvals(duplicates) = [];
    i=i+1;
end
if size(circen,1)>4
    circen = circen(1:4,:);
end

cry = circen(:,2);
crx = circen(:,1);
[cry, I] = sort(cry,1,'descend');
crr = crr(I);
crx = crx(I);

%% Make sure first 2 crs go from left to right
if size(circen,1)>=2
    [crx(1:2), I] = sort(crx(1:2));
    cry(1:2) = cry(I);
    crr(1:2) = crr(I);
else
    cry(2) = NaN;
    crx(2) = NaN;
    crr(2) = NaN;
end

%% For time locking of video to light pulses (optional)
% output the high y-coordinate, but the exact x of the corresponding lower cr
if length(crx)==3
    cry(1:2) = cry(3);
elseif length(crx)==4
    cry(1:2) = cry(3:4);
end

% Put left CR first
cr1 = [crx(1) cry(1) crr(1)];
cr2 = [crx(2) cry(2) crr(2)];

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
if isempty(trackParams.pupilStart) || any(isnan(trackParams.pupilStart)) || trackParams.pupilStart(1)==0
    alphaFRST = 0.5;           % Sensitivity to radial symmetry
    imgRadialPupil = Radial_Sym_Transform(img, trackParams.radiiPupil, alphaFRST);
    [pupilY, pupilX] = find(min(imgRadialPupil(:))==imgRadialPupil);
    trackParams.pupilStart = [pupilX pupilY];
end

%% Detect pupil borders using starburst algorithm
[epx, epy, ~] = starburst_pupil_contour_detection(InoCR, trackParams.pupilStart(1),...
    trackParams.pupilStart(2), trackParams.edgeThresh,round(trackParams.radiiPupil),trackParams.minfeatures);

[~, inliers] = fit_ellipse_ransac(epx(:), epy(:), trackParams.radiiPupil + [-15 15]);
%[r, rotated_ellipse] = fit_ellipse_altMethod( epx(:),epy(:),app.UIAxes2_2 );

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

%% Plotting
if trackParams.plotOn
    
    fig = app.UIAxes2_2;
    color = 'm';
    
    imagesc(fig, img);  colormap(fig, gray);%  axis off; axis image
    xlim(fig, [0, size(img,2)]);
    ylim(fig, [0, size(img,1)]);
    hold(fig, 'on');
    a = 0:.1:2*pi;
    plot(fig, cr1(3).*cos(a) + cr1(1), cr1(3).*sin(a)+cr1(2),'b')
    plot(fig, cr2(3).*cos(a) + cr2(1), cr2(3).*sin(a)+cr2(2),'c')
    plot(fig, crx(1), cry(1),'+b')
    plot(fig, crx(2), cry(2),'+c')
    %plot(fig, rotated_ellipse(1,:),rotated_ellipse(2,:),'w' );
    
    % Plot ellipse
    the=linspace(0,2*pi,100);
    line(fig, pupil(3)*cos(the)*cos(pupil(5)) - sin(pupil(5))*pupil(4)*sin(the) + pupil(1), ...
        pupil(3)*cos(the)*sin(pupil(5)) + cos(pupil(5))*pupil(4)*sin(the) + pupil(2),...
        'Color',color);
    
    plot(fig, pupil(1), pupil(2),['+', color],'LineWidth',2, 'MarkerSize',10)
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


