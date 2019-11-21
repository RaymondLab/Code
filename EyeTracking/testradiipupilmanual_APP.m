% testradiipupil
% Test pupil radius parameters for initial search
function [pupilStart] = testradiipupilmanual_APP(app, img)
    
% Camera 1
figure('units','normalized','outerposition',[0 0 1 1]); clf
imagesc(img); colormap(gray); axis image;box off

%% Get pupil center manually
disp('Click on pupil center')
[x, y] = ginput(1);

pupilStart = [x y];

hold on; plot(pupilStart(1), pupilStart(2),'+r')

end

