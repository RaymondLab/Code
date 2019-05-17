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
% a is x and y corrdinates. unused?
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
% imrect is function to create a drag-able rectangle. hrect is 1x4 [Xoffset, Yoffset, Width, Height]
hRect = imrect;
roi = round(getPosition(hRect));

% Ensure new image is still centered. Make sure center of pupil is the center of the box
roi(4) = 2*max(box/2-roi(2), roi(2)+roi(4)-box/2);
roi(2) = box/2-roi(4)/2

roi2 = roi + [(res-box)/2 0 0] + [boxoffset 0 0 0]; % vertical offset

set(vid(1), 'ROIPosition',roi2);
set(vid(2), 'ROIPosition',roi2);
close gcf

%% Write images to file
imwrite(img1, 'img1large.tiff','tiff')
imwrite(img2, 'img2large.tiff','tiff')
