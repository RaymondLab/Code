function vid = setROI(vid, img1, img2,res, boxsize, boxoffset)

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
pos1 = round(getPosition(hRect));

%% Set new ROI
roi = pos1;

% Ensure new image is still centered. Make sure center of pupil is the center of the box
roi(3) = 2*max(boxsize/2-roi(1), roi(1)+roi(3)-boxsize/2); % Ensure new image is still centered
roi(1) = boxsize/2-roi(3)/2

% Situates roi in the context of field of view of entire camera (which has
% dimenstions given by res)
finalROI = [roi(1) 500-roi(2)-roi(4) roi(3) roi(4)] + [(res-boxsize)/2 0 0] + [0 boxoffset 0 0]; % vertical offset
% Second element of finalROI is 500-roi(2)-roi(4) because the camera
% counts vertical pixels from the bottom instead of the top. hRect counts
% pixels from the top; thus there is a conversion.

set(vid(1), 'ROIPosition',finalROI);
set(vid(2), 'ROIPosition',finalROI);
close gcf


%% Write images to file
imwrite(img1, 'img1large.tiff','tiff')
imwrite(img2, 'img2large.tiff','tiff')
