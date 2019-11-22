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
 
%     for i = 1:n_images
%         img = stack(:,:,i);
% 
%         % Upsample image for better detection of CR
%         img = imresize(img,2);
% 
%         % Enhance contrast
%         if enchanceContrast
%             img = imadjust(img);
%         end
% 
%         % Select ROI
%         img = img(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
% 
%         img = imfilter(img, fspecial('gaussian',3,.5));
% 
%         if i == 1
%             newStack = zeros(size(img,1),size(img,2),n_images,'uint8');
%         end
% 
%         newStack(:,:,i) = img;
%     end
end