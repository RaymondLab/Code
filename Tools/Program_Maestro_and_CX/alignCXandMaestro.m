function [behaviorDat, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorDat, ephysData, plotOn)

    % Don't plot by default
    if ~exist('plotOn','var')
        plotOn = 0;
    end
    
    
    eSamplerate = 50000;%ephysDat.samplerate;
    %ephysData = datchandata(ephysDat,'Ephys');
    timeEphys = 0:1/eSamplerate:(length(ephysData)-1)/eSamplerate;
    
    %% Allign Ephys Data
    spikesForAlignment = 100:120;
    
    timeofsimplespikes = datchandata(behaviorDat,'ss');    
    eventsSampleTime = timeofsimplespikes * eSamplerate;
    eventsSampleTime = eventsSampleTime(spikesForAlignment);
    eventsSampleTime = round(eventsSampleTime);
    eventsSampleTime = eventsSampleTime - eventsSampleTime(1);
    
    sumofthingsInitial = nan(length(ephysData),length(eventsSampleTime));
    
    for x = 1:length(ephysData)
        if max(eventsSampleTime + x) > min([150000, length(ephysData)])
            break
        end
        sumofthingsInitial(x,:) = sum(ephysData(eventsSampleTime + x));
    end
    
    sumofthings = sum(sumofthingsInitial,2);
    %% Modify ephys
    maxMatchValue = max(abs(sumofthings));
    maxSumLoc = timeEphys(find(abs(sumofthings) == maxMatchValue));
    maxSumLoc = maxSumLoc(1);
    
    if maxMatchValue > 30
        shiftAmt = -(maxSumLoc - timeofsimplespikes(100));
        timeEphys = timeEphys + shiftAmt;
        shiftConfidence = maxMatchValue;
        
        if plotOn
            figure(9);clf
            plot(timeEphys, abs(sumofthings))
            %ylim([0 100])
            if ~isempty(maxSumLoc)
                vline(maxSumLoc + shiftAmt, ':r')
                xlim([maxSumLoc-1 maxSumLoc+1])
            end

            figure(10); clf
            plot(timeEphys, ephysData);
            vline(timeofsimplespikes(1:100), '--r')
            xlim([.5 1])
        end
        

    else
        shiftAmt = 0;
        shiftConfidence = 0;
    end
    
    %% add shifted ephys channel to behavior structure
    behaviorDat(end+1) = dat(ephysData, 'Ephys', length(behaviorDat)+1, eSamplerate, timeEphys(1),timeEphys(end),'mV?');