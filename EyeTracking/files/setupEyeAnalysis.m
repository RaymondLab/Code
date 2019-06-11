function setupEyeAnalysis

%% DEFAULT PARAMETERS
% Pupil radius initial parameters
radiiPupil = 90;  % default radius in pixels

xpad = 120;
ypad = 40;

% corneal refleaction radii bounds
radiiCR1 = [12 17]; 
radiiCR2 = [12 17];

% Fraction features needed for pupil detection
minfeatures = .5;

% Improve image contrast
imAdjust = 1;


% Select initial pupil location automatically or manually
manual=0;


%% ALLOW PARAMETER ADJUSTMENT AND TEST
ok = 'No';
while strcmp(ok,'No')
    
    % Get input
    prompt = {'radiiPupil:','ROI x pad:','ROI y pad:', 'radiiCR1:','radiiCR2:','minfeatures:','imAdjust:','manual:'};
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