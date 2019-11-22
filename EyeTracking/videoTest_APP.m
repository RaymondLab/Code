function videoTest_APP(app, radiiPupil, varargin)

manual = 1;
p = inputParser;
addOptional(p,'RadiiCR1',[10 16])
addOptional(p,'RadiiCR2',[10 16])
addOptional(p,'MinFeatures',.7)
addParamValue(p,'Manual',0)
addParamValue(p,'ImAdjust',0)
addParamValue(p,'Frame',1) % Frame of image to use
addParamValue(p,'CRthresh1',10)
addParamValue(p,'CRthresh2',10)
addParamValue(p,'CRfilter1',6)
addParamValue(p,'CRfilter2',6)

parse(p,varargin{:})
radiiCR1 = p.Results.RadiiCR1;
radiiCR2 = p.Results.RadiiCR2;
CRthresh1 = p.Results.CRthresh1;
CRthresh2 = p.Results.CRthresh2;
CRfilter1 = p.Results.CRfilter1;
CRfilter2 = p.Results.CRfilter2;
minfeatures = p.Results.MinFeatures;
imAdjust = p.Results.ImAdjust;

edgeThresh1 = app.edgeThreshCam1EditField.Value; % Initial gradient threshold of pupil edge detection for cam 1
edgeThresh2 = app.edgeThreshCam2EditField.Value; % Initial gradient threshold of pupil edge detection for cam 2
plotall= 1;
debugOn = 0;
ok = 0;


%% Load image to test
frame = 1;
[img1large, img2large] = readImg_APP(imAdjust, frame);

%% User finds pupil center and analysis ROI
[pupilStartLarge1,pupilStartLarge2] = testradiipupilmanual_APP(app, img1large, img2large);

disp('Draw a box around analysis ROI.')
disp('When finished, press any key.');

subplot(1,2,1);
hRecta = drawrectangle;
pos1 = round(hRecta.Position);
pupilStart1 = [round(pupilStartLarge1(1)) - pos1(1), round(pupilStartLarge1(2)) - pos1(2)];

subplot(1,2,2);
hRectb = drawrectangle; 
pos2 = round(hRectb.Position);
pupilStart2 =  [round(pupilStartLarge2(1)) - pos2(1), round(pupilStartLarge2(2)) - pos2(2)];

pause
close all;

while ~ok && frame<10
    
    %% Select ROI
    [img1, img2] = readImg_APP(imAdjust, frame, pos1, pos2);
    
    %% CAMERA 1
    try
        [pupil1, CR1a, CR1b] = detectPupilCR_APP(...
            app,1, img1, 1, [], [], ...
            'radiiPupil',radiiPupil,    'radiiCR',radiiCR1,...
            'EdgeThresh',edgeThresh1+3, 'pupilStart',pupilStart1,...
            'CRthresh',CRthresh1,       'CRfilter',CRfilter1, ...
            'PlotOn',plotall,           'MinFeatures',minfeatures,...
            'debugOn',debugOn);
        ok = 1;
    catch msgid
        warning(msgid.message)
        ok = 0;
    end
    
    %% CAMERA 2
    try
        [pupil2, CR2a, CR2b] = detectPupilCR_APP(...
            app,0, img2,1, [], [], ...
            'radiiPupil',radiiPupil,'radiiCR',radiiCR2,...
            'EdgeThresh',edgeThresh2+3,'pupilStart',pupilStart2,...
            'CRthresh',CRthresh2,'CRfilter',CRfilter2,'PlotOn',plotall,...
            'MinFeatures', minfeatures,'debugOn',debugOn);
        continue;
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
disp(['Pupil 1 : ', num2str(max(pupil1(3:4)))]);
disp(['Pupil 2 : ', num2str(max(pupil2(3:4)))]);
disp(['CR 1a : ', num2str(CR1a(3))]);
disp(['CR 1b : ', num2str(CR1b(3))]);
disp(['CR 2a : ', num2str(CR2a(3))]);
disp(['CR 2b : ', num2str(CR2b(3))]);

%% Save settings
save('settings','pos1','pos2','radiiPupil','minfeatures',...
    'radiiCR1','CRthresh1','CRfilter1','radiiCR2','CRthresh2','CRfilter2',...
    'imAdjust','pupilStart1','pupilStart2','manual')

end