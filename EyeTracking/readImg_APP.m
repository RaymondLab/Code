function [img1, img2] = readImg_APP(imAdjust, frame, pos1, pos2)
    %% Load sample images
    img1 = imread(fullfile(cd, 'img1.tiff'),'Index',frame);
    img2 = imread(fullfile(cd, 'img2.tiff'),'Index',frame);

    % Upsample image for better detection of CR
    img1 = imresize(img1,2);
    img2 = imresize(img2,2);

    % Enhance contrast
    if imAdjust
        img1 = imadjust(img1);
        img2 = imadjust(img2);
    end
    if exist('pos2','var')
        img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
        img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));
    end
end