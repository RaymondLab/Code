% OPENSINGLE Opens a single file for analysis (Lisberger lab format)
%   beh = opensingle(filename) Opens the file into Hannah's dat format
%   including manual alignment of complex spikes
%   beh = opensingle(filename, loadCS) 
%
%   Hannah Payne 2012
%   https://sites.google.com/a/srscicomp.com/maestro/data-analysis/supported-matlab-tools/readcxdata
% 
%   Edited 9/20/16 
%       1. fix calibration factor for chair: step SS should be 15.0 -
%       15.1, eye should not overshoot target
%       2. Using 100 Hz low pass filtered eye velocity instead of 25 Hz
%       3. Option to load or not load CS

%    ch1: hgpos
%    ch2: hevel
%    ch4: hhvel
%    ch6: htpos
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [beh, shiftAmt, shiftConfidence] = opensingleMAXEDIT(filename, ephys_exists, full_ephys)

    %% Opens Cntrlx file in Matlab and saves as "behavior"
    chanAmt = 6; %6: Jennifer, 7: Akira
    behavior = readcxdata(filename, 0, chanAmt);
    if isempty(behavior.data)
        return
    end
    
    %% Flip data for elvis so that contra is up and ipsi is down
    if ~isempty(regexp(filename,'da','once'))
        behavior.data = -behavior.data;
    end
    
    % Assigns structures in "behavior" to specific signals
    bSamplerate = 500;
    eSamplerate = 50000;
    %eSamplerate = 1000;
    hgpos = behavior.data(1,:) *12.5 *(1/bSamplerate);
    vepos = behavior.data(2,:) *12.5 *(1/bSamplerate);
    hevel = behavior.data(3,:) *0.09189;
    htpos = behavior.data(4,:) *12.5 *(1/bSamplerate);
    hhvel = behavior.data(5,:) *0.09189;
    hdvel = behavior.data(6,:) *0.09189;
    if chanAmt == 7
        unknown = behavior.data(7,:);
    end
    
  
    % Fix the offset of hhvel
    hhvel = hhvel-mean(hhvel);

    % create time vectors 
    timebehavior = 0:1/bSamplerate:(length(htpos)-1)/bSamplerate;

    % ms --> s
    timeofcomplexspikes = behavior.sortedSpikes{1}*0.001;
    timeofsimplespikes = (behavior.spikes)*0.001;
    if isempty(timeofsimplespikes)
        timeofsimplespikes = (behavior.events)*0.001;
    end
    
    shiftAmt = NaN;
    shiftConfidence = NaN;
    if ephys_exists       
        %% Load Ephys Data
        ephys = openmaestro(full_ephys);
        timeEphys = 0:1/eSamplerate:(length(ephys)-1)/eSamplerate;

        %% Allign Ephys Data
        eventsSampleTime = timeofsimplespikes * eSamplerate;
        eventsSampleTime = eventsSampleTime(100:150);
        eventsSampleTime = round(eventsSampleTime);
        eventsSampleTime = eventsSampleTime - eventsSampleTime(1);
        sumofthings = nan(length(ephys),1);

        for x = 1:length(ephys)
            if max(eventsSampleTime + x) > 400000
                break
            end
            sumofthings(x) = sum(ephys(eventsSampleTime + x));
        end
        
        maxMatchValue = max(abs(sumofthings));
        maxSumLoc = timeEphys(find(abs(sumofthings) == maxMatchValue));

        % Modify ephys
        if maxMatchValue > 30
            shiftAmt = -(maxSumLoc - timeofsimplespikes(100));
            timeEphys = timeEphys + shiftAmt;
            
            figure(9);clf
            plot(timeEphys, abs(sumofthings))
            ylim([0 100])
            if ~isempty(maxSumLoc)
                vline(maxSumLoc + shiftAmt)
                xlim([maxSumLoc-1 maxSumLoc+1])
            end
             shiftConfidence = maxMatchValue;
             
            figure(10); clf
            plot(timeEphys, ephys);
            vline(timeofsimplespikes(1:100))
            xlim([.5 1])
        else
            shiftAmt = 0;
            shiftConfidence = 0;
        end
    end
           

    
    %% Save data in a dat structure
    tstart = timebehavior(1);
    tend   = timebehavior(end);
    
    % Calculate Velocity
    veltau = .01;
    bSamplerate = 500;
    htvel = movingslopeCausal(htpos,round(bSamplerate*veltau))*bSamplerate;
    

    % Store data
    beh        = dat(hgpos,'Horz Gaze Vel',  1,bSamplerate,tstart, tend,'deg');
    beh(end+1) = dat(vepos,'Vert Eye Pos',   2,bSamplerate,tstart, tend,'deg');
    beh(end+1) = dat(hevel,'Horz Eye Pos',   3,bSamplerate,tstart, tend,'deg/s');
    beh(end+1) = dat(htpos,'Horz Target Pos',4,bSamplerate,tstart, tend,'deg');
    beh(end+1) = dat(hhvel,'Horz Head Vel',  5,bSamplerate,tstart, tend,'deg/s');
    beh(end+1) = dat(hdvel,'Horz d Vel (eye2)',     6,bSamplerate,tstart, tend,'deg/s');
    beh(end+1) = dat(htvel,'Horz Target Vel',7,bSamplerate,tstart, tend,'deg/s');
    if ephys_exists
        beh(end+1) = dat(ephys, 'Ephys',8,50000,timeEphys(1),timeEphys(end),'mV?');
    else
        beh(end+1) = dat([], 'Ephys',8,50000,tstart,tend,'mV?');
    end
    if chanAmt == 7
        beh(end+1) = dat(unknown, 'Unknown',9,bSamplerate, tstart, tend,'?');
    end
    beh(end+1) = dat(timeofsimplespikes,'ss', 10,'event',tstart, tend,'s');
    beh(end+1) = dat(timeofcomplexspikes,'cs',11,'event',tstart, tend,'s');