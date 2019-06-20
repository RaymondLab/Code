function setupEyeAnalysis

%% DEFAULT PARAMETERS
% Pupil radius initial parameters
radiiPupil = 50;  % default radius in pixels

% X & Y Padding around Pupil in pixels
xpad = 100;
ypad = 40;

% corneal refleaction radii bounds
radiiCR1 = [6 12]; 
radiiCR2 = [6 12];

% Fraction features needed for pupil detection
minfeatures = .5;

% Improve image contrast
imAdjust = 1;

% Select initial pupil location automatically or manually
manual = 1;


%% ALLOW PARAMETER ADJUSTMENT AND TEST
ok = 'No';
while strcmp(ok,'No')
    
    % Get input
    prompt = {'Pupil Radius (Pixels):', ...
              'X-padding around Pupil (Pixels):', ...
              'Y-padding around Pupil (Pixels):', ...
              'Corneal Reflection 1 Radii Bounds:', ...
              'Corneal Reflection 2 Radii Bounds:', ...
              'Minimum Features:', ...
              'Image Adjust?', ...
              'Select Pupil Center Manually?'};
          
    dlg_title = 'Settings for eyeAnalysis';
    defAns =   cellfun(@num2str,{radiiPupil, xpad, ypad, radiiCR1, radiiCR2, minfeatures, imAdjust, manual},'UniformOutput',0);
    answerStr = inputdlg(prompt,dlg_title,1,defAns);
    answerNum = cellfun(@str2num, answerStr,'UniformOutput',0);
    [radiiPupil, xpad, ypad, radiiCR1, radiiCR2, minfeatures, imAdjust, manual]= answerNum{:};
    
    %% Test it
    % Area to subselect
    
    % Run test of setttings and save them
    videoTest(radiiPupil,[xpad ypad],radiiCR1,radiiCR2,minfeatures,'ImAdjust',imAdjust,'Manual',manual)
    
    %% Ask if ok
    ok = questdlg('Accept settings?','Accept settings?','Yes','No','Yes');    
end

end