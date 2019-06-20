% testradiipupil
% Test pupil radius parameters for initial search
function [pupilStart1,pupilStart2] = testradiipupilmanual(img1, img2)
    
% Camera 1
clf; subplot(1,2,1); imagesc(img1); colormap(gray); axis image;box off

% Camera 2
subplot(1,2,2); imagesc(img2); colormap(gray);  axis image;box off

%% Get pupil center manually
disp('Click on each pupil center')
[x, y] = ginput(2);

pupilStart1 = [x(1) y(1)];
pupilStart2 = [x(2) y(2)];

subplot(1,2,1); hold on; plot(pupilStart1(1), pupilStart1(2),'+r')
subplot(1,2,2); hold on; plot(pupilStart2(1), pupilStart2(2),'+r')

end

