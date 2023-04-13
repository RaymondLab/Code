function [saccadeLocs, eye_pos_filt, eye_vel_pfilt] = desaccadeVel_A(data, samplerate, freq, presaccade, postsaccade, thresh, minDataLength)
accel = 0;

% STEP 1:  LOW PASS ON POSITION
N = 4;
fc = 15;
nq = samplerate / 2;
[bb, aa] = butter(N, fc / nq, 'low');
eye_pos_filt = filtfilt(bb,aa,data);


% STEP 2: CALC VEL - use Hannah's calulation method, not the 'diff()' function.
veltau = .01;
eye_vel_pfilt = movingslopeCausal(eye_pos_filt,round(samplerate*veltau))*samplerate;
eye_vel_praw = movingslopeCausal(data,round(samplerate*veltau))*samplerate;


% STEP 3: REMOVE EXPMT FREQ by taking squared error from initial fit guess
segLength = length(data);
timeVec = 0:( 1/samplerate ):(segLength-1)/samplerate;

y1 = sin(2*pi*freq*timeVec(:));
y2 = cos(2*pi*freq*timeVec(:));
constant = ones(segLength,1);

vars = [y1 y2 constant];
keep = abs(eye_vel_pfilt) < 5*std(abs(eye_vel_pfilt)) + mean(abs(eye_vel_pfilt));
b = regress(eye_vel_pfilt(keep), vars(keep,:));
fit1 = vars *b;

eye_vel_se = (eye_vel_pfilt - fit1).^2;


% STEP 4: Remove all points higher than thresh
badDataLocations = eye_vel_se > thresh;


% STEP 5: remove points around omit centers as defined by pre & post saccade time
presaccade = round((presaccade/1000)*samplerate);
postsaccade = round((postsaccade/1000)*samplerate);
sacmask = ones(1,presaccade+postsaccade);

% filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(badDataLocations),sacmask);
rejecttemp2 = rejecttemp1(presaccade:postsaccade+length(data)-1);

% eyevel with desaccade segments removed
tempTrace = eye_pos_filt;
tempTrace(logical(rejecttemp2))= NaN;
saccadeLocs = isnan(tempTrace);

% STEP 6: Remove any 'good data' portions that are too small

goodStarts = strfind(saccadeLocs', [1 0]);
goodEnds = strfind(saccadeLocs', [0 1]);

if isempty(goodStarts)
    % BOTH are empty 
    if isempty(goodEnds)
        
    % START is empty
    else
        goodStarts = 1;
    end
else
    % END is empty
    if isempty(goodEnds)
        goodEnds = length(saccadeLocs);
        
    % NEITHER are empty
    else
        if goodEnds(1) < goodStarts(1)
            goodStarts = [1 goodStarts];
        end
        
        if goodEnds(end) < goodStarts(end)
            goodEnds = [goodEnds length(saccadeLocs)];
        end
    end
end  

for ii = 1:length(goodStarts)
    if (goodEnds(ii) - goodStarts(ii)) < minDataLength
        saccadeLocs(goodStarts(ii):goodEnds(ii)) = 1;
        goodStarts(ii) = NaN;
        goodEnds(ii) = NaN;
    end
end
    
%% FOR TESTING, DEBUGGING, AND TWEAKING DESACCADE %%%%%%%%%%%%%%%%%%%%%%%%
if 1

    
    % find start and end times of sacs
    sacStarts = strfind(saccadeLocs', [0 1]);
    sacEnds = strfind(saccadeLocs', [1 0]);
    
    if isempty(sacStarts)
        % BOTH are empty 
        if isempty(sacEnds)

        % START is empty
        else
            sacStarts = 1;
        end
    else
        % END is empty
        if isempty(sacEnds)
            sacEnds = length(saccadeLocs);

        % NEITHER are empty
        else
            if sacEnds(1) < sacStarts(1)
                sacStarts = [1 sacStarts];
            end

            if sacEnds(end) < sacStarts(end)
                sacEnds = [sacEnds length(saccadeLocs)];
            end
        end
    end
    
    x = [sacStarts; sacEnds; sacEnds; sacStarts];
    x = x/samplerate;
    y = [-20000;-20000;20000;20000];
    y = repmat(y,[1 size(x, 2)]);
    
    if isempty(x)
        x = [];
        y = [];
    end
    
    %% Plot Basic Visuals
    figure();clf
    
    ha = tight_subplot(3,1,[.02 .02],[.03 .02],[.03 .01]);

    axes(ha(1))
    plot(timeVec, data, 'r')
    hold on
    plot(timeVec, eye_pos_filt, 'k', 'LineWidth', 1.5)    
    title('Position')
    PrevYlim = ylim;
    patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
    ylim(PrevYlim);
    xlim([0 max(timeVec)])
    xticks([])
    hold off
    box off
    
    if accel
        % Plot
        axes(ha(2))
        plot(eye_acc_praw, 'r')
        hold on
        plot(timeVec, eye_acc_pfilt, 'k', 'LineWidth', 1.5)
        title('Accel')
        ylim([-15000 15000])
        patch(x, y, 'k', 'FaceAlpha',.5, 'LineStyle', 'none');
        xlim([0 max(timeVec)])
        xticks([])
        hold off
        box off
        
        axes(ha(3))
        plot(timeVec, abs(eye_acc_pfilt), 'k', 'LineWidth', 1.5)
        hline(450, 'b')
        patch(x, y.*100, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim([0 2500])
        xlim([0 max(timeVec)])
        box off
        
       
    else
        axes(ha(2))
        plot(timeVec, eye_vel_praw, 'r')
        hold on
        plot(timeVec, eye_vel_pfilt, 'k', 'LineWidth', 1.5)
        title('Velocity')
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        try
            ylim([median(eye_vel_praw)*-800 median(eye_vel_praw)*800]);
        catch 
            ylim([median(eye_vel_praw)*800 median(eye_vel_praw)*-800]);
        end
        xlim([0 max(timeVec)])
        xticks([])
        hold off
        box off
        
        axes(ha(3))
        plot(timeVec, (eye_vel_pfilt - fit1).^2, 'k', 'LineWidth', 1.5)
        hline(thresh, 'b')
        patch(x, y.*100, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim([0 4*thresh])
        xlim([0 max(timeVec)])
        linkaxes(ha(:), 'x')
        box off
    end
    

    %% Plot frequency spectrum as check on experiment freq
    do_100 = 0 ;
    if do_100
        figure(100)
        L = length(eye_vel_pfilt);
        Y = fft(eye_vel_pfilt);
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = samplerate*(0:(L/2))/L;
        plot(f,P1) 
        title(num2str(freq))
    end

    %% Plot raw and filtered w/ desaccaded
    do_101 = 0;
    if do_101

        figure(101)
        ha = tight_subplot(4,1,[.01 .03],[.1 .01],[.01 .01]);


        axes(ha(1))
        plot(data)
        hold on
        eye_pos_des = data;
        eye_pos_des(saccadeLocs) = NaN;
        plot(eye_pos_des)
        preLim = ylim;
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim(preLim)
        hold off
        title('Raw Pos')

        axes(ha(2))
        plot(eye_pos_filt);
        hold on
        eye_pos_filt_des = eye_pos_filt;
        eye_pos_filt_des(saccadeLocs) = NaN;
        plot(eye_pos_filt_des)
        preLim = ylim;
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim(preLim)
        hold off
        title('Filtered Pos')

        axes(ha(3))
        plot(eye_vel_praw)
        hold on
        eye_vel_praw(saccadeLocs) = NaN;
        plot(eye_vel_praw)
        preLim = ylim;
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim(preLim)
        hold off
        title('Raw Vel')

        axes(ha(4))
        filtP_eye_vel = diff(eye_pos_filt);
        plot(filtP_eye_vel);
        hold on
        filtP_eye_vel(saccadeLocs) = NaN;
        plot(filtP_eye_vel)
        preLim = ylim;
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim(preLim)
        hold off
        title('Filtered Vel')
    end
    
    %% Plot Different ways of getting Vel
    do_102 = 0;
    if do_102
        lw = 1;
        eye_vel01_praw = eye_vel_praw;
        veltau = .02;
        eye_vel02_praw = movingslopeCausal(data,round(samplerate*veltau))*samplerate;
        veltau = .03;
        eye_vel03_praw = movingslopeCausal(data,round(samplerate*veltau))*samplerate;
        veltau = .04;
        eye_vel04_praw = movingslopeCausal(data,round(samplerate*veltau))*samplerate;
        veltau = .05;
        eye_vel05_praw = movingslopeCausal(data,round(samplerate*veltau))*samplerate;
        
        A = figure(102);clf
        ha = tight_subplot(6,1,[.01 .03],[.1 .01],[.04 .01]);
        
        axes(ha(1))
        plot(eye_vel_praw, 'k'); hold on
        grid on
         
        axes(ha(2))
        plot(eye_vel_praw, 'k'); hold on
        plot(eye_vel02_praw, 'r', 'LineWidth', lw)
        grid on
        
        axes(ha(3))
        plot(eye_vel_praw, 'k'); hold on
        plot(eye_vel03_praw, 'r', 'LineWidth', lw)
        grid on
        
        axes(ha(4))
        plot(eye_vel_praw, 'k'); hold on
        plot(eye_vel04_praw, 'r', 'LineWidth', lw)
        grid on 
        
        axes(ha(5))
        plot(eye_vel_praw, 'k'); hold on
        plot(eye_vel05_praw, 'r', 'LineWidth', lw)
        grid on 
        
        axes(ha(6))
        plot(eye_vel_praw, 'k'); hold on
        plot(eye_vel_pfilt, 'r', 'LineWidth', lw)
        grid on 
        
        linkaxes(ha)
        A.Color = 'w';
    end
    
      
    %disp('a')
end




