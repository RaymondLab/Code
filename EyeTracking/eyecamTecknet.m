function varargout = eyecamTecknet(vid, eyetrack, duration)
% Preview mode:  eyecam(vid)
% Eye track mode: eyeresults = eyecam(vid, 1, filepathname)

if ~exist('eyetrack','var')
    eyetrack = 0;
end

if ~exist('duration','var')
    duration = 60;
end

himg1 = [];
himg2 = [];
time1 = [];
time2 = [];

start(vid(1));
start(vid(2));

src = getselectedsource(vid(1));
fps = str2num(get(src,'FrameRate'));
nframes = duration*fps;
% try

fhandle = figure(1);

% Add a figure to begin recording
if eyetrack
    screensize = get(0,'Screensize');
    set(gcf, 'Position', [screensize(3)/2+9  49 screensize(3)/2-16 screensize(4)-132]); %
    msgh = msgbox('Press OK to start calibration');
    set(msgh, 'Position', [screensize(3:4)-[630 425] 120 50])
    
    trigger(vid)
    img1 = getdata(vid(1),1); %*** changed'
    img2 = getdata(vid(2),1); %*** changed'
    img1_all = uint8(zeros(size(img1,1),size(img1,2),nframes));
    img2_all = uint8(zeros(size(img1,1),size(img1,2),nframes));
else
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
end

i = 0;



%% collect images until user closes  window
while ishandle(fhandle)
    
    if eyetrack && i>=nframes
        close(gcf)
        pause(.1)
        break
    end
    
    trigger(vid)
    if ~exist('msgh','var') ||  ~ishandle(msgh)
        i = i + 1;
        
        [img1, time1(i)] = getdata(vid(1),1);
        [img2, time2(i)] = getdata(vid(2),1);
        
        
        if i==30
            fps = 30/(time1(i) - time1(i-29))
        end
        
    else
        img1  = getdata(vid(1),1);
        img2  = getdata(vid(2),1);
        
    end
    
    img1 = rot90(img1,2); %*** CHANGED FOR TECKNET CAMERAS - installed upside down
    img2 = rot90(img2,2); %*** CHANGED FOR TECKNET CAMERAS - installed upside down
    
    if i > 0     % Store images in large 3D matrix  
        img1_all(:,:,i) = img1;
        img2_all(:,:,i) = img2;        
    end
    
    % Plot everything the first time
    if isempty(himg1) && isempty(himg2)
        subplot(1,2,1)
        himg1 = imshow(img1);
        
        cMap = gray(256); % Most of the image is grayscale
        cMap(1,:) = [0 0 1]; % Last row is blue.
        cMap(256,:) = [1 0 0]; % Last row is red.
        colormap(cMap);
        
        hold on;
        
        if ~exist('h','var')
            h(1) = plot(size(img1,2)/2, size(img1,1)/2,'+r', 'MarkerSize',1000);
        end
        
        subplot(1,2,2)
        himg2 = imshow(img2);
        hold on;     colormap(cMap);
        
        if length(h)<2
            h(2) = plot(size(img1,2)/2, size(img1,1)/2,'+r', 'MarkerSize',1000);
        end
        
        % After the first time just update
    elseif ishandle(himg1) && ishandle(himg2)
        set(himg1, 'CData',img1);
        set(himg2, 'CData',img2);
    end    
end

stop(vid);
if exist('time1','var')
    fps_mean = mean(1./diff(time1))
    results.time1 = time1';
    results.time2 = time2';
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
        disp('Saving images...')
        
        saveastiff(img1_all, 'img1.tiff');
        saveastiff(img2_all, 'img2.tiff');
        
        dbclear if error
        fprintf('%d frames saved in current folder\n',i)
        t = toc;
        
    catch msgid
        disp(msgid.message) % If you get an error here, run the cell above:
        keyboard            % ("%% Save as tiff")
    end   
end
