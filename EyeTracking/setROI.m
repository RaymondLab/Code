function vid = setROI(vid, img1, img2,res, box, boxoffset)

%% Display snapshot
figure(1); 
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
h(1) = subplot(1,2,1);
imshow(img1); title('Camera 1')

h(2) = subplot(1,2,2);
imshow(img2); title('Camera 2')

%% Prompt for ROI around each eye
disp('Click on the camera coming from the left angle')
a = ginput(1);
hout = gca;

if hout == h(2) % right subplot clicked, switch cameras
    vid = [vid(2) vid(1)];
    img2temp = img1;
    img1 = img2;
    img2 = img2temp;
    subplot(1,2,1); imshow(img1); title('Camera 1')
    subplot(1,2,2); imshow(img2); title('Camera 2')    
end

disp('Drag a rectangle around the eye in camera 1')
subplot(1,2,1)
hRect = imrect;
roi = round(getPosition(hRect));

roi(4) = 2*max(box/2-roi(2), roi(2)+roi(4)-box/2); % Ensure new image is still centered
roi(2) = box/2-roi(4)/2

roi2 = roi + [(res-box)/2 0 0] + [boxoffset 0 0 0]; % vertical offset

set(vid(1), 'ROIPosition',roi2);
set(vid(2), 'ROIPosition',roi2);
close gcf

%% Write images to file
imwrite(img1, 'img1large.tiff','tiff')
imwrite(img2, 'img2large.tiff','tiff')

%{
% CLICK AND DRAG METHOD########################
% hobin's version:
function vid = setROI(vid, img1, img2) % hobin

%% Display snapshot
figure(1); 
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
h(1) = subplot(1,2,1);
imshow(img1); title('Camera 1')

h(2) = subplot(1,2,2);
imshow(img2); title('Camera 2')

%% Prompt for ROI around each eye

disp('Click on the camera coming from the left angle')
a = ginput(1);
hout = gca;
disp('Drag a rectangle around the eye in camera 1')
subplot(1,2,1);
hRect = imrect;
pos1 = round(getPosition(hRect)); 

disp('Click on the camera coming from the right angle')
a = ginput(1); 
hout = gca;
disp('Drag a rectangle around the eye in camera 2')
subplot(1,2,2);
hRect2 = imrect;
pos2 = round(getPosition(hRect2)); 

% take midpoints and recalculate to fit matrix
new_width = (pos1(3) + pos2(3)) / 2;
new_height = (pos1(4) + pos2(4)) / 2;
pos1(3) = new_width;
pos2(3) = new_width;
pos1(4) = new_height;
pos2(4) = new_height;

width = 400;
height = 250;

disp('Click on the outer CR coming from the left angle')
[x, y] = ginput(1)
hout = gca;
subplot(1,2,1);

xOffset = x - (0.5 * width) - 150;
yOffset = y - (0.5 * height - 50);
pos1 = [xOffset yOffset width height];

disp('Click on the outer CR coming from the left angle')
subplot(1,2,2);
[x, y] = ginput(1)
hout = gca;
xOffset = x - (0.5 * width);
yOffset = y - (0.5 * height);
pos2 = [xOffset yOffset width height];

set(vid(1), 'ROIPosition',pos1);
set(vid(2), 'ROIPosition',pos2);
close gcf
%% Write images to file
imwrite(img1, 'img1large.tiff','tiff')
imwrite(img2, 'img2large.tiff','tiff')
%}