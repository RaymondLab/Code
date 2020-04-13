function newStack = preprocessImages(stack, pos, enchanceContrast)

    % Upsample image for better detection of CR
    newStack = imresize(stack,2);

    % Gaussian Filter
    newStack = imfilter(newStack, fspecial('gaussian',3,.5));

    % Enhance Image Contrast
    % (cannot be done to stack, must loop)
    if enchanceContrast
        for i = 1:size(newStack,3)
            newStack(:,:,i) = imadjust(newStack(:,:,i));
        end
    end
    
    % Select elipse ROI
    % (cannot be done to stack, must loop)
    for i = 1:size(newStack,3)
        tempImage = newStack(:,:,i);
        tempImage(~pos) = nan;
        newStack(:,:,i) = tempImage;
    end
    
    % conver timage to double
%     newStackdouble = im2double(newStack);
 
end