function [img] = readImg_APP(imAdjust, cam, frame, pos1, pos)
    %% Load sample images
    img = imread(fullfile(cd, ['img' cam, '.tiff']),'Index',frame);

    % Upsample image for better detection of CR
    img = imresize(img,2);

    % Enhance contrast
    if imAdjust
        img = imadjust(img);
    end
    if exist('pos','var')
        img = img(pos(2):pos(2)+pos(4), pos(1):pos(1)+pos(3));
    end
end