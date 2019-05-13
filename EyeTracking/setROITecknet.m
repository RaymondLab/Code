function vid = setROITecknet(vid, img1, img2, res, boxsize, boxoffset)

%% Display snapshot
figure(1); 
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
h(1) =subplot(1,2,1);
imshow(img1); title('Camera 1')

h(2) =subplot(1,2,2);
imshow(img2); title('Camera 2')

%% Prompt for ROI around each eye
disp('Click on the camera coming from the left angle')
ginput(1);
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

%% Set new ROI
roi(3) = 2*max(boxsize/2-roi(1), roi(1)+roi(3)-boxsize/2); % Ensure new image is still centered
roi(1) = boxsize/2-roi(3)/2;
roi2 = roi + [res(1)/2-boxsize/2  res(2)/2-boxsize/2  0 0] + [0 boxoffset 0 0]; % vertical offset

%% Set new position
set(vid(1), 'ROIPosition',roi2);
set(vid(2), 'ROIPosition',roi2);
for i= 1:2
    src = getselectedsource(vid(i));
    src.VerticalFlip = 'on';
    src.HorizontalFlip = 'on';
end

%% Write images to file
close gcf
imwrite(img1, 'img1large.tiff','tiff')
imwrite(img2, 'img2large.tiff','tiff')

