function [imageStack, n_images] = getImageStack(file, customEndFrame)

    info = imfinfo(file);

    nImage = info(1).Height;
    mImage = info(1).Width;
    % n_images = length(info);
    n_images = customEndFrame;
    imageStack = zeros(nImage,mImage,n_images,'uint8');
    TifLink = Tiff(file, 'r');

    for i=1:n_images
        TifLink.setDirectory(i);
        imageStack(:,:,i) = TifLink.read();
    end
    
    TifLink.close();
    
end
