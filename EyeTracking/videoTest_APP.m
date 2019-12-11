function videoTest_APP(app, cam, radiiPupil, varargin)

manual = 1;
p = inputParser;
addOptional(p,'RadiiCR',[10 16])
addOptional(p,'MinFeatures',.7)
addParamValue(p,'Manual',0)
addParamValue(p,'ImAdjust',0)
addParamValue(p,'Frame',1) % Frame of image to use
addParamValue(p,'CRthresh1',10)
addParamValue(p,'CRthresh2',10)
addParamValue(p,'CRfilter1',6)
addParamValue(p,'CRfilter2',6)

parse(p,varargin{:})
radiiCR = p.Results.RadiiCR;
CRthresh = p.Results.CRthresh1;
CRthresh2 = p.Results.CRthresh2;
CRfilter = p.Results.CRfilter1;
CRfilter2 = p.Results.CRfilter2;
minfeatures = p.Results.MinFeatures;
imAdjust = p.Results.ImAdjust;

edgeThresh1 = app.edgeThreshEditField.Value; % Initial gradient threshold of pupil edge detection for cam 1
plotall= 1;
debugOn = 0;
ok = 0;


%% Load image to test
frame = 1;
[imgLarge] = readImg_APP(imAdjust, cam, frame);

%% User finds pupil center and analysis ROI
[pupilStartLarge] = testradiipupilmanual_APP(app, imgLarge);

disp('Draw a box around analysis ROI.')
disp('When finished, press any key.');

hRecta = drawrectangle;
pos = round(hRecta.Position);
pupilStart = [round(pupilStartLarge(1)) - pos(1), round(pupilStartLarge(2)) - pos(2)];

pause
close all;

while ~ok && frame<10
    
    %% Select ROI
    [img] = readImg_APP(imAdjust, cam, frame, pos);
    
    %% CAMERA 1
    try
        [pupil, CRa, CRb] = detectPupilCR_APP(...
            app,1, img, 1, [], [], ...
            'radiiPupil',radiiPupil,    'radiiCR',radiiCR,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart,...
            'CRthresh',CRthresh,       'CRfilter',CRfilter, ...
            'PlotOn',plotall,           'MinFeatures',minfeatures,...
            'debugOn',debugOn);
        ok = 1;
    catch msgid
        warning(msgid.message)
        ok = 0;
    end
    
    % Try next frame if bad image
    frame = frame + 1;
end

%% Print radii information for user
disp(' ')
disp(' ')
disp('Radii: ')
disp(['Pupil: ', num2str(max(pupil(3:4)))]);
disp(['CR a : ', num2str(CRa(3))]);
disp(['CR b : ', num2str(CRb(3))]);


%% Save settings
save('settings','pos','radiiPupil','minfeatures',...
    'radiiCR','CRthresh','CRfilter','CRthresh2','CRfilter2',...
    'imAdjust','pupilStart','manual')

end