    function [pos1, pos2, pupilStart1, pupilStart2] = convertPosition(pupilStart1large,pupilStart2large, radiiPupil, ROIpad, imgSize)
      

roiwidth = mean(radiiPupil)*2+ROIpad(1);  % [x]
roiheight = mean(radiiPupil)*2+ROIpad(2); % [y]
    
%% Select ROI
pos1 = round([pupilStart1large 0 0] + [-roiwidth/2 -roiheight/2 roiwidth roiheight]);
pos2 = round([pupilStart2large 0 0] + [-roiwidth/2 -roiheight/2 roiwidth roiheight]);
pos1(1:2) = max(pos1(1:2),1);
pos2(1:2) = max(pos2(1:2),1);
pos1(3:4) = min(pos1(3:4),fliplr(imgSize)-pos1(1:2));
pos2(3:4) = min(pos2(3:4),fliplr(imgSize)-pos2(1:2));
% img1 = img1(pos1(2):pos1(2)+pos1(4), pos1(1):pos1(1)+pos1(3));
% img2 = img2(pos2(2):pos2(2)+pos2(4), pos2(1):pos2(1)+pos2(3));


pupilStart1 = pos1(3:4)/2;
pupilStart2 = pos2(3:4)/2;
