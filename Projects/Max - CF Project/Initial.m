%% Combine Motor & Ephys Files into a Spike2 .smr

%% Reset Everything
clear;clc;close all


%% Setup
ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing\D1_1995';
%ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);
%bFiles(~contains({bFiles.name}, 'unit')) = [];

%% Match the corresponding ephys folders with thier motor folders
for j = 1:length(bFiles)
    
    ephys_exists = 0;
    ePath = [];
    
    % Jennifer's naming Scheme
    eFile = strrep(bFiles(j).name, 'da', 'du');
    eFile = strrep(eFile, '.0', '.');

    % Akira's Naming Scheme
    %if ~contains(bFiles(j).name, 'unit')
    %    continue
    %end
    % Akira's Ephys naming Scheme
     %eFile = strrep(bFiles(j).name, '.0', '.');
     %eFile = strrep(eFile, 'unit', 'U');
     
    % Search through LburgFiles to see if it exists
    ephys_loc = find(contains({bFiles.name}, eFile));
     
    % Extract ephys Data 
    if ephys_loc > 0
        ephys_exists = 1;
        ePath = fullfile(bFiles(ephys_loc).folder, bFiles(ephys_loc).name)
    else
        warning([eFile ': No Ephys'])
        continue
    end
    
    % Extract behavior Data
    try
        bPath = fullfile(bFiles(j).folder, bFiles(j).name)
        beh = opensingleMAXEDIT(bPath, ephys_exists, ePath);
    catch
        warning([bPath, ' Failed'])
        continue
    end
    
    % Plot each channel in overview plot
    figure(1); clf
    ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);
    
    for q = 1:8
        
        axes(ha(q))
        if isempty(beh(q).data)
            title([beh(q).chanlabel, ' is empty'])
            continue
        end

        samplerate = beh(q).samplerate;
        timeVec = 0:(1/samplerate):length(beh(q).data)/samplerate;
        timeVec(end) = [];

        % Plot
        plot(timeVec, beh(q).data)
        title(beh(q).chanlabel)

        % only show Tick labels on bottom
        if q ~= length(ha)
            xlimMax = max(timeVec);
            xticks([]);
            xticklabels([]);
        else
            vline(beh(end-1).data(1:20));
            figure(4);clf
            fa = tight_subplot(2,1,[0 0],[.03 .03],[.03 .03]);
            axes(fa(1))
            plot(timeVec, beh(q).data)
            xlim([0 .5])
            axes(fa(2))
            vline(beh(end-1).data(1:50));
            xlim([0 .5])
            figure(1)
        end
    end

    %% Method 3
    % Initialize ephys and event channel vectors.
%     rng('default') ;        % To produce the same 'random' vector each time.
%     t = randi(100,100,1) ;  % Artificial ephys trace.
%     t = -(t-mean(t)) ;      % Use minima for convenience, since fewer than maxima.
%     t(t>46) = 100 ;         % Knowing the vector, create 6 spike peaks.
%     e = [22; 32; 40; 92]+4 ;% Four detected spikes when using 7ms window, offset.
% 
%     % Find where ISI distributions overlap?
%     tpeak = find(t>60) ;    % --This threshold would have to be input manually.
%     isiE = diff(e) ;
%     isiT = diff(tpeak) ;
%     j = 1 ;                 % 1-second initial window size.
%     while length(isiT) > length(isiE)   % While the numel e & t mismatch,
%        while find(isiT<j) > 0              % While spikes still occur within (J ms) window,
%            tpeak(find(isiT<j,1)+1) = [] ;  % Delete those spikes one-by-one,
%            isiT = diff(tpeak) ;            % And recompute the ISI times.
%        end
%        j = j+1 ;                       % Increment window size up by 1
%     end
% 
%     if (isiE - isiT) == 0   % If the ISI times match, you win!
%        sprintf('Event 1 happens at %g seconds',tpeak(1))
%     else
%        disp('Need to truncate ephys data into a different time range')
%     end
    %% Method 2
%     eventsSampleTime = beh(end-1).data * samplerate;
%     eventsSampleTime = eventsSampleTime(1:20);
%     eventsSampleTime = round(eventsSampleTime);
%     % zero c
%     eventsSampleTime = eventsSampleTime - eventsSampleTime(1);
%     sumofthings = nan(length(beh(q).data),1);
%     stdofthings = nan(length(beh(q).data),1);
% 
%     for x = 1:length(beh(q).data)
%         if max(eventsSampleTime + x) > length(beh(q).data);
%             break
%         end
%         sumofthings(x) = sum(beh(q).data(eventsSampleTime + x));
%         stdofthings(x) = std(beh(q).data(eventsSampleTime + x));
%     end
%     
%     figure()
%     plot(timeVec, abs(sumofthings))
%     yyaxis right
%     plot(timeVec, -stdofthings)
%     ylim([0 .2])   
    %% Method 1
%     if ~isempty(beh(q).data)
% 
%         [pks, locs] = findpeaks(-1*beh(q).data);
%         peak1Val = max(pks);
%         peak1sec = locs(pks == peak1Val);
% 
%         locs(pks == peak1Val) = [];
%         pks(pks == peak1Val) = [];
% 
%         peak2Val = max(pks);
%         peak2sec = locs(pks == peak2Val);
% 
%         % distance between the two peaks
%         peaksDist = abs(peak2sec - peak1sec);
% 
%         targetZones = (beh(end-1).data)*samplerate + peaksDist;
%         accuracy = nan(length(targetZones),2);
%         for x = 1:length(targetZones)
%             [accuracy(x,1), accuracy(x,2)] = min(abs(beh(end-1).data*samplerate - targetZones(x)));
%         end
% 
%         [~, event1num] = min(accuracy(:,1));
%         event1sec = beh(end-1).data(event1num);  
%         event2num = accuracy(event1num, 2);
%         event2sec = beh(end-1).data(event2num);
% 
%         abs(event1sec - event2sec)
%         abs(peak1sec/samplerate - peak2sec/samplerate)
% 
%     %     figure(6);clf
%     % 
%     %     ja = tight_subplot(2,1,[0 0],[.03 .03],[.03 .03]);
%     %     adjustmentVal = beh(end-1).data - abs(peak1sec/samplerate - event1sec);
%     %     adjustmentVal(adjustmentVal < 0) = [];
%     %     axes(ja(1))
%     %     plot(timeVec, beh(q).data)
%     %     vline(peak1sec/samplerate)
%     %     vline(peak2sec/samplerate)
%     %     %vline(adjustmentVal)
%     %     axes(ja(2))
%     %     vline(adjustmentVal(1:200))
%     end
    %%
    linkaxes(ha, 'x')
    %xlim([0 .5])
    disp(length(beh(8).data) / length(beh(1).data))

    figure(2)
    title(bFiles(j).name)
    disp(timeVec(1));
    figure(4)
    if ephys_loc > 0
        disp('apple')
    end
    clc
    fclose('all')
end