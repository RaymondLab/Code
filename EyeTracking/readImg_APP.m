function [img] = readImg_APP(imAdjust, cam, frame, roi)
    %% Load sample images
    img = imread(fullfile(cd, ['img' num2str(cam), '.tiff']),'Index',frame);
   
    % Upsample image for better detection of CR
    img = imresize(img,2);

    % Enhance contrast
    if imAdjust
        img = imadjust(img);
    end
    
    if exist('roi','var')
        img(~roi) = nan;
    end

end