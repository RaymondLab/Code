% testradiipupil
% Test pupil radius parameters for initial search
function [pupilStart1,pupilStart2] = testradiipupil(img1, img2, radiiPupil,dbgon)

%% Reserved parameters
alphaFRST = 0.5;           % Sensitivity to radial symmetry
fracRemove = .15;

%% Camera 1
% Take the radial transform
imgRadialPupil = Radial_Sym_Transform(img1, radiiPupil, alphaFRST);
imgRadialPupil = removeborder(imgRadialPupil, fracRemove);

% Find the lowest point (for dark pupil)
[pupilY1, pupilX1] = find(min(imgRadialPupil(:))==imgRadialPupil,1);
pupilStart1 = [pupilX1 pupilY1];

if dbgon
    figure; subplot(2,2,1); imagesc(imgRadialPupil); colormap(gray);hold on; plot(pupilStart1(1), pupilStart1(2),'+r')
    axis image;box off
end

% gap1 = (nanmedian(imgRadialPupil(:))-min(imgRadialPupil(:))) % more is better

%% Camera 2
% Take the radial transform
imgRadialPupil = Radial_Sym_Transform(img2, radiiPupil, alphaFRST);
imgRadialPupil = removeborder(imgRadialPupil, fracRemove);

% Find the lowest point (for dark pupil)
[pupilY2, pupilX2] = find(min(imgRadialPupil(:))==imgRadialPupil,1);
pupilStart2 = [pupilX2 pupilY2];

if dbgon
    subplot(2,2,2); imagesc(imgRadialPupil); colormap(gray);hold on; plot(pupilStart2(1), pupilStart2(2),'+r')
    axis image;box off
end

% gap2 = (nanmedian(imgRadialPupil(:))-min(imgRadialPupil(:))) % more is better

end

function img = removeborder(img, frac)
[r, c] = size(img);
mask = true(r,c);
mask(1:round(r*frac),:) = false;
mask(round(r*(1-frac)):end,:) = false;
mask(:,1:round(c*frac)) = false;
mask(:,round(c*(1-frac)):end) = false;
img(~mask)=NaN;
end
