%%
function varargout = eyecam_APP2(app, vid, vars, eyetrack, nframes)

%% Defaults for missing inputs
if ~exist('eyetrack','var')
    eyetrack = 0;
end

if ~exist('nframes','var')
    nframes = 180*30;
end

%%  Prep
start(vid(1));
start(vid(2));
AAA = figure(3);
fhandle = figure(1);
i = 0;

%% Imgage Color properties
cMap = gray(256); % Most of the image is grayscale
cMap(1,:) = [0 0 1]; % Last row is blue.
cMap(256,:) = [1 0 0]; % Last row is red.

%% Add a figure to begin recording for EyeTrack
if eyetrack
    screensize = get(0,'Screensize');
    [screensize(3)/2+9  49 screensize(3)/2-16 screensize(4)-132]
    set(gcf, 'Position', [screensize(3)/2+9  49 screensize(3)/2-16 screensize(4)-132]); %
    msgh = msgbox('Press OK to start calibration');
    set(msgh, 'Position', [screensize(3:4)-[630 425] 120 50])

    trigger(vid)
    img1 = getdata(vid(1),1)';
    img2 = getdata(vid(2),1)';
    % because of the older logitech camera set up in D253, the images need to be rotates. This is not needed for the ELP cameras
    %img1_all = uint8(zeros(size(img1,1),size(img1,2),nframes)); %D253
    %img2_all = uint8(zeros(size(img1,1),size(img1,2),nframes)); %D253
    img1_all = uint8(zeros(size(img1,2),size(img1,1),nframes));  %D019
    img2_all = uint8(zeros(size(img1,2),size(img1,1),nframes));  %D019
else
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
end


%% Plot first frame

[img1, ~] = getsnapshot(vid(1));
[img2, ~] = getsnapshot(vid(2));

subplot(1,2,1)
himg1 = imshow(img1); hold on;
colormap(cMap);
plot(size(img1,2)/2, size(img1,1)/2,'+r', 'MarkerSize',1000);


subplot(1,2,2)
himg2 = imshow(img2); hold on;
colormap(cMap);
plot(size(img1,2)/2, size(img1,1)/2,'+r', 'MarkerSize',1000);


%% collect images until user closes  window
tic
while ishandle(fhandle)

    % Quit if enough frames are captured
    if eyetrack && i>=nframes
        close(gcf)
        pause(.1)
        break
    end

    if ~exist('msgh','var') ||  ~ishandle(msgh)
        i = i + 1;

        [img1, ~] = getsnapshot(vid(1));
        [img2, ~] = getsnapshot(vid(2));

        time3(i) = toc;

        if mod(i, 30) == 0
            fps = 1/(mean(time3(end-28:end) - time3(end-29:end-1)));
            hold on
            AAA;
            scatter(i, fps);
            hold off
        end

    else
        img1  = getdata(vid(1),1);
        img2  = getdata(vid(2),1);
    end
    
    % hobin don't know why things were rotated but I left them unrotated
    % maybe unrotating them will give me an error later on
    img1 = rot90(img1,-1); 
    img1 = rot90(img1,-1);
    img2 = rot90(img2,-1); 
    img2 = rot90(img2,-1);
    
    % Store images in large 3D matrix only when doing eyetrack
    if eyetrack  && i > 0
        %i % counter
        img1_all(:,:,i) = img1;
        img2_all(:,:,i) = img2;
    end
    
    % Update Image
    set(himg1, 'CData',img1);
    set(himg2, 'CData',img2);
end

stop(vid);

%% Define outputs
if exist('time1','var')
    meanFrameRate = mean(1./diff(time1))
    results.time1 = time1';
    results.time2 = time2';
    results.time3 = time3'; % double check
end

if nargout==1
    varargout = {results};
elseif nargout==2
    varargout = {img1 img2};
end

%% Save images if running an expmt
if eyetrack
    try
        % Save the resulting timestamps
        save('time', 'results');

        %% Save as tiff    - make sure windows explorer is closed!
        tic

        dbstop if error
        disp('Saving images')

        saveastiff(img1_all, fullfile(pwd,'img1.tiff'));
        saveastiff(img2_all, fullfile(pwd,'img2.tiff'));

        dbclear if error
        fprintf('\n%d frames saved in current folder\n',i)
        t = toc;
        fprintf('%f sec elapsed per 100 images.\n',t/i*100)

    catch msgid
        disp(msgid.message) % If you get an error here, run the cell above:
        keyboard            % ("%% Save as tiff")
    end
end
