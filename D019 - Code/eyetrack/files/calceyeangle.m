function varargout = calceyeangle(results, theta)

%% Angle between two cameras in degree  5/22 DONT CHANGE
if ~exist('theta','var')
    theta = 39.8;
end

%% if input is a dat, convert to old results format
if isa(results,'dat')
    datflag = 1;
    R = results;
    results= [];
    
    results.pupil1 = [datchandata(R,'pupil1x') datchandata(R,'pupil1y')];
    results.pupil2 = [datchandata(R,'pupil2x') datchandata(R,'pupil2y')];
    results.cr1a = [datchandata(R,'cr1x') datchandata(R,'cr1y')];
    results.cr2b = [datchandata(R,'cr2x') datchandata(R,'cr2y')];
    width = 1000;
else
    width = 30; % width of medfilt for removing alignment points
    datflag = 0;
end

%% Horizontal
d1 =  results.pupil1(:,1) - results.cr1a(:,1);
d2 = -results.pupil2(:,1) + results.cr2b(:,1);
% d1 = d1/nanmean(results.cr1b(:,1)-results.cr1a(:,1));
% d2 = d2/nanmean(results.cr2b(:,1)-results.cr2a(:,1));        
% posH = atand(d1./d2*sind(theta) ./ (1 + d1./d2*cosd(theta)));
posH = atand(sind(theta) ./ (d2./d1 + cosd(theta))); % equivalent

%% Vertical (less exact but pretty close)
if nargout>1
    
    removeoutliers = @(x) (abs(x-medfilt1(x,width)) > 2*nanstd(medfilt1(x,width)));
    
    rP = calcEyeRadius(results,theta)
    
    cr1y = results.cr1a(:,2);
    cr1y(removeoutliers(cr1y))= NaN;
    cr1y = inpaint_nans(cr1y);
    cr1y = medfilt1(cr1y,3);
    
    cr2y = results.cr2b(:,2);
    cr2y(removeoutliers(cr2y))= NaN;
    cr2y = inpaint_nans(cr2y);
    cr1y = medfilt1(cr1y,3);
    
    posV1 = real(asind((results.pupil1(:,2) - cr1y)./rP)); % in degrees cam 1 estimate
    posV2 = real(asind((results.pupil2(:,2) - cr2y)./rP)); % in degrees cam 2 estimate
    
    if std(posV1) < std(posV2)
        posV = posV1;
    else
        posV = posV2;
    end
end

%% Outputs
if nargout == 1
    varargout = {posH};
elseif nargout == 2
    varargout = {posH, posV};
else
    varargout = {posH, posV1, posV2};
end
