function allignEventsAndEphys(ephys, events, samplerate, methodNum)

timeVec = 0:( 1/samplerate ):( length(ephys)-1 )/samplerate;

%% Allign Data
switch methodNum
    case 1
        %% Method 1

        [pks, locs] = findpeaks(-1*ephys);
        peak1Val = max(pks);
        peak1sec = locs(pks == peak1Val);
        
        if length(peak1sec) > 1
            peak1sec(2:end) = [];
        end
        
        locs(pks == peak1Val) = [];
        pks(pks == peak1Val) = [];

        peak2Val = max(pks);
        peak2sec = locs(pks == peak2Val);
        
        if length(peak2sec) > 1
            peak2sec(2:end) = [];
        end
        
        % distance between the two peaks
        peaksDist = abs(peak2sec - peak1sec);

        targetZones = (events)*samplerate + peaksDist;
        accuracy = nan(length(targetZones),2);
        for x = 1:length(targetZones)
            [accuracy(x,1), accuracy(x,2)] = min(abs(events*samplerate - targetZones(x)));
        end

        [~, event1num] = min(accuracy(:,1));
        event1sec = events(event1num);
        event2num = accuracy(event1num, 2);
        event2sec = events(event2num);

        abs(event1sec - event2sec)
        abs(peak1sec/samplerate - peak2sec/samplerate)

            figure(6);clf
        
            ja = tight_subplot(2,1,[0 0],[.03 .03],[.03 .03]);
            adjustmentVal = events - abs(peak1sec/samplerate - event1sec);
            adjustmentVal(adjustmentVal < 0) = [];
            axes(ja(1))
            plot(timeVec, ephys)
            vline(peak1sec/samplerate)
            vline(peak2sec/samplerate)
            %vline(adjustmentVal)
            axes(ja(2))
            if ~isempty(adjustmentVal)
                vline(adjustmentVal(1:200))
            end

    case 2
        %% Method 2
        eventsSampleTime = events * samplerate;
        eventsSampleTime = eventsSampleTime(200:250);
        eventsSampleTime = round(eventsSampleTime);
        % zero c
        eventsSampleTime = eventsSampleTime - eventsSampleTime(1);
        sumofthings = nan(length(ephys),1);
        %stdofthings = nan(length(ephys),1);
        
        for x = 1:length(ephys)
            if max(eventsSampleTime + x) > length(ephys)
                break
            end
            sumofthings(x) = sum(ephys(eventsSampleTime + x));
            %stdofthings(x) = std(ephys(eventsSampleTime + x));
        end
        
        figure(9);clf
        plot(timeVec, abs(sumofthings))
        ylim([0 100])
        %yyaxis right
        %plot(timeVec, abs(stdofthings))
        %ylim([0 1.8])
        
        maxSumLoc = timeVec(find(abs(sumofthings) == max(abs(sumofthings))))
        %minStdLoc = timeVec(find(stdofthings == min(stdofthings)))
        if ~isempty(maxSumLoc)
            vline(maxSumLoc)
            xlim([maxSumLoc-1 maxSumLoc+1])
            %vline(minStdLoc)
        end
        
        % Find Time corrected Events
        events = events + (maxSumLoc - events(100));
    case 3
        %% Method 3
        %Initialize ephys and event channel vectors.
        rng('default') ;        % To produce the same 'random' vector each time.
        t = randi(100,100,1) ;  % Artificial ephys trace.
        t = -(t-mean(t)) ;      % Use minima for convenience, since fewer than maxima.
        t(t>46) = 100 ;         % Knowing the vector, create 6 spike peaks.
        e = [22; 32; 40; 92]+4 ;% Four detected spikes when using 7ms window, offset.

        % Find where ISI distributions overlap?
        tpeak = find(t>60) ;    % --This threshold would have to be input manually.
        isiE = diff(e) ;
        isiT = diff(tpeak) ;
        j = 1 ;                 % 1-second initial window size.
        while length(isiT) > length(isiE)   % While the numel e & t mismatch,
           while find(isiT<j) > 0              % While spikes still occur within (J ms) window,
               tpeak(find(isiT<j,1)+1) = [] ;  % Delete those spikes one-by-one,
               isiT = diff(tpeak) ;            % And recompute the ISI times.
           end
           j = j+1 ;                       % Increment window size up by 1
        end

        if (isiE - isiT) == 0   % If the ISI times match, you win!
           sprintf('Event 1 happens at %g seconds',tpeak(1))
        else
           disp('Need to truncate ephys data into a different time range')
        end
end


%% Plotting
figure(3); clf
qa = tight_subplot(1,1,[.03 .03],[.03 .03],[.03 .03]);

axes(qa(1))
plot(timeVec, ephys); hold on
try
    vline(events(1:200))
    xlim([events(125) events(150)])
end



% axes(qa(2))
% vline(events(1:100))
% %linkaxes(qa, 'x')
% xlim([0 events(50)])
% disp(1)
