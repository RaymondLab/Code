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

function [trackParams, newFrame, plotData] = detectPupilCR_APP( app, img, referenceFrame, newFrame, trackParams)

%% Process imputs
img = double(img);

%% Preallocate
plotData.epx = nan;
plotData.epx2 = nan;
plotData.epy = nan;
plotData.epy2 = nan;
plotData.points = nan;

%% Find corneal reflections

% only search through portion of image, Corneal reflections shouldn't move
try 
    if ~isempty([referenceFrame.cr1_x,referenceFrame.cr2_x]) && ~any(isnan([referenceFrame.cr1_x,referenceFrame.cr2_x]))

        TOP     = floor(max( min([referenceFrame.cr1_y,referenceFrame.cr2_y]) - max([referenceFrame.cr1_r,referenceFrame.cr2_r])*2, 1 ));
        BOTTOM  = floor(min( max([referenceFrame.cr1_y,referenceFrame.cr2_y]) + max([referenceFrame.cr1_r,referenceFrame.cr2_r])*2, size(img,1) ));
        LEFT    = floor(max( min([referenceFrame.cr1_x,referenceFrame.cr2_x]) - max([referenceFrame.cr1_r,referenceFrame.cr2_r])*2, 1 ));
        RIGHT   = floor(min( max([referenceFrame.cr1_x,referenceFrame.cr2_x]) + max([referenceFrame.cr1_r,referenceFrame.cr2_r])*2, size(img,2) ));

        newImg = img(TOP:BOTTOM, LEFT:RIGHT);
        [~, circen, crr] = CircularHough_Grd(newImg,trackParams.radiiCR ,trackParams.CRthresh,trackParams.CRfilter,1);

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
%         
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
        [A, circen, crr] = CircularHough_Grd(img,trackParams.radiiCR ,trackParams.CRthresh,trackParams.CRfilter,1);
    end
catch
    [A, circen, crr] = CircularHough_Grd(img,trackParams.radiiCR ,trackParams.CRthresh,trackParams.CRfilter,1);
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

if isempty(ellipseResult.X0_in)
    newFrame.pupil_x = nan;
    newFrame.pupil_y = nan;
    newFrame.pupil_r1 = nan;
    newFrame.pupil_r2 = nan;
    newFrame.pupil_angle = nan;
else
    newFrame.pupil_x = ellipseResult.X0_in;
    newFrame.pupil_y = ellipseResult.Y0_in;
    newFrame.pupil_r1 = ellipseResult.a;
    newFrame.pupil_r2 = ellipseResult.b;
    newFrame.pupil_angle = -ellipseResult.phi;
end

newFrame.cr1_x = crx(1);
newFrame.cr1_y = cry(1);
newFrame.cr1_r = crr(1);
newFrame.cr2_x = crx(2);
newFrame.cr2_y = cry(2);
newFrame.cr2_r = crr(2);

points = [epx2(:), epy2(:)];

%% Plotting
if trackParams.plotOn
    
    fig = app.UIAxes2_2;
    imagesc(fig, img);  colormap(fig, gray);
    
    aaa = find(nanmean(img,1));
    bbb = find(nanmean(img, 2));
    xlim(fig, [min(aaa), max(aaa)]);
    ylim(fig, [min(bbb), max(bbb)]);
    
    hold(fig, 'on');
    a = 0:.1:2*pi;
    plot(fig, newFrame.cr1_r.*cos(a) + newFrame.cr1_x, newFrame.cr1_r.*sin(a)+newFrame.cr1_y,'b')
    plot(fig, newFrame.cr2_r.*cos(a) + newFrame.cr2_x, newFrame.cr2_r.*sin(a)+newFrame.cr2_y,'c')
    plot(fig, newFrame.cr1_x, newFrame.cr1_y,'+b')
    plot(fig, newFrame.cr2_x, newFrame.cr2_y,'+c')
    
    % Plot ellipse
    the=linspace(0,2*pi,100);
    line(fig, newFrame.pupil_r1*cos(the)*cos(newFrame.pupil_angle) - sin(newFrame.pupil_angle)*newFrame.pupil_r2*sin(the) + newFrame.pupil_x, ...
        newFrame.pupil_r1*cos(the)*sin(newFrame.pupil_angle) + cos(newFrame.pupil_angle)*newFrame.pupil_r2*sin(the) + newFrame.pupil_y,...
        'Color','m');
    
    plot(fig, newFrame.pupil_x, newFrame.pupil_y,['+', 'm'],'LineWidth',2, 'MarkerSize',10)
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


