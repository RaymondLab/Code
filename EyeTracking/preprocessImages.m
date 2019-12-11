function newStack = preprocessImages(stack, pos, enchanceContrast)

    % Upsample image for better detection of CR
    newStack = imresize(stack,2);
    
    % Select ROI
    newStack = newStack(pos(2):pos(2)+pos(4), pos(1):pos(1)+pos(3), :);
    
    % Gaussian Filter
    newStack = imfilter(newStack, fspecial('gaussian',3,.5));
    
    % Enhance Image Contrast (cannot be done to stack, must loop)
    if enchanceContrast
        for i = 1:size(newStack,3)
            newStack(:,:,i) = imadjust(newStack(:,:,i));
        end
    end
 
end