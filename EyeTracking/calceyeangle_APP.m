function posH = calceyeangle_APP(frameData_cam1, frameData_cam2, theta)

%% Angle between two cameras in degree  5/22 DONT CHANGE
if ~exist('theta','var')
    theta = 39.8;
end

%% Horizontal
d1 = [frameData_cam1.pupil_x] - [frameData_cam1.cr1_x];
d2 = - [frameData_cam2.pupil_x] + [frameData_cam2.cr2_x];

posH = atand(sind(theta) ./ (d2./d1 + cosd(theta)));


%% Vertical (less exact but pretty close) TODO, it works, but only with
% old 'results' data structure. Need to make work with new 'frameData' data
% structure. We don't use vertical position for anything as of April 2020,
% so not a high priority to fix

% width = 30; % width of medfilt for removing alignment points
% if nargout>1
% 
%     removeoutliers = @(x) (abs(x-medfilt1(x,width)) > 2*nanstd(medfilt1(x,width)));
% 
%     rP = calcEyeRadius(results,theta);
% 
%     cr1y = results.cr1a(:,2);
%     cr1y(removeoutliers(cr1y))= NaN;
%     cr1y = inpaint_nans(cr1y);
%     cr1y = medfilt1(cr1y,3);
% 
%     cr2y = results.cr2b(:,2);
%     cr2y(removeoutliers(cr2y))= NaN;
%     cr2y = inpaint_nans(cr2y);
%     cr1y = medfilt1(cr1y,3);
% 
%     posV1 = real(asind((results.pupil1(:,2) - cr1y)./rP)); % in degrees cam 1 estimate
%     posV2 = real(asind((results.pupil2(:,2) - cr2y)./rP)); % in degrees cam 2 estimate
% 
%     if std(posV1) < std(posV2)
%         posV = posV1;
%     else
%         posV = posV2;
%     end
% end
% 
% %% Outputs
% if nargout == 1
%     varargout = {posH};
% elseif nargout == 2
%     varargout = {posH, posV};
% else
%     varargout = {posH, posV1, posV2};
% end
