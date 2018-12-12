function [omitH, omitCenters, eye_pos_filt, eye_vel_pfilt] = desaccadeVel3(eye_pos_raw, samplerate, presaccade, postsaccade, freq, params, fit1)
% LOW PASS ON POSITION
N = 4;
fc = 15;
[bb,aa] = butter(N, fc/samplerate, 'low');
eye_pos_filt = filtfilt(bb,aa,eye_pos_raw);

% CALC VEL - use Hannah's calulation method, not the 'diff()' function.
veltau = .01;
eye_vel_pfilt = movingslopeCausal(eye_pos_filt,round(samplerate*veltau))*samplerate;
eye_vel_praw = movingslopeCausal(eye_pos_raw,round(samplerate*veltau))*samplerate;

%% REMOVE EXPMT FREQ
option = 2;

N = 6;
fc = freq+7;
[bb,aa] = butter(N, fc/samplerate, 'high');
try
    eye_vel_pfilt2 = filtfilt(bb,aa,eye_vel_pfilt);
catch
    eye_vel_pfilt2 = filter(bb,aa,eye_vel_pfilt);
    print('FAIL')
end
    
eye_vel_mse = (eye_vel_pfilt - fit1).^2;


% OPTION 1 - USE HIGH PASS
if option == 1
    omitCenters = abs(eye_vel_pfilt2) > params.saccadeThresh;
% OPTION 2 - USE MSE OF 'FIT'
elseif option == 2
    omitCenters = eye_vel_mse > params.saccadeThresh;
end

%%
% remove points around omit centers as defined by pre & post saccade time
sacmask = ones(1,presaccade+postsaccade);

% filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(omitCenters),sacmask);
rejecttemp2 = rejecttemp1(presaccade:presaccade+length(eye_pos_raw)-1);

% eyevel with desaccade segments removed
eyevelOut = eye_pos_filt;
eyevelOut(logical(rejecttemp2))= NaN;
omitH = isnan(eyevelOut);


%% FOR TESTING, DEBUGGING, AND TWEAKING DESACCADE %%%%%%%%%%%%%%%%%%%%%%%%
if params.NoiseAnalysis
    
    % find start and end times of sacs
    sac_start = strfind(omitH', [0 1]);
    sac_end = strfind(omitH', [1 0]);
    if ~isempty(sac_end) || ~isempty(sac_start)
        if sac_end(1) < sac_start(1)
            sac_start = [1 sac_start];
        end

        if sac_end(end) < sac_start(end)
            sac_end = [sac_end length(omitH)];
        end
    end
    
    x = [sac_start; sac_end; sac_end; sac_start];
    y = [-200;-200;200;200];
    y = repmat(y,[1 size(x, 2)]);
    
    %% Plot Basic Visuals
    figure(99)
    
    ha = tight_subplot(3,1,[.01 .03],[.1 .01],[.01 .01]);

    axes(ha(1))
    plot(eye_pos_raw, 'r')
    hold on
    plot(eye_pos_filt, 'k', 'LineWidth', 1.5)    
    title('Position')
    PrevYlim = ylim;
    patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
    ylim(PrevYlim);
    hold off
    
    axes(ha(2))
    plot(eye_vel_praw, 'r')
    hold on
    plot(eye_vel_pfilt, 'k', 'LineWidth', 1.5)
    title('Velocity')
    patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
    ylim([-200 200])
    hold off
    
    axes(ha(3))
    plot((eye_vel_pfilt - fit1).^2, 'k', 'LineWidth', 1.5)
    hline(params.saccadeThresh, 'b')
    patch(x, y.*100, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
    ylim([0 10000])
    
    %% Plot frequency spectrum as check on experiment freq
    do_100 = 1 ;
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
        plot(eye_pos_raw)
        hold on
        eye_pos_des = eye_pos_raw;
        eye_pos_des(omitH) = NaN;
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
        eye_pos_filt_des(omitH) = NaN;
        plot(eye_pos_filt_des)
        preLim = ylim;
        patch(x, y, 'k', 'FaceAlpha',.1, 'LineStyle', 'none');
        ylim(preLim)
        hold off
        title('Filtered Pos')

        axes(ha(3))
        plot(eye_vel_praw)
        hold on
        eye_vel_praw(omitH) = NaN;
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
        filtP_eye_vel(omitH) = NaN;
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
        eye_vel02_praw = movingslopeCausal(eye_pos_raw,round(samplerate*veltau))*samplerate;
        veltau = .03;
        eye_vel03_praw = movingslopeCausal(eye_pos_raw,round(samplerate*veltau))*samplerate;
        veltau = .04;
        eye_vel04_praw = movingslopeCausal(eye_pos_raw,round(samplerate*veltau))*samplerate;
        veltau = .05;
        eye_vel05_praw = movingslopeCausal(eye_pos_raw,round(samplerate*veltau))*samplerate;
        
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
    pause
end




