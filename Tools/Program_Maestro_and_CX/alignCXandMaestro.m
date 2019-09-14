function [behaviorDat, shiftAmt, shiftConfidence] = alignCXandMaestro(behaviorDat, ephysDat, plotOn)

    % Don't plot by default
    if ~exist('plotOn','var')
        plotOn = 0;
    end
    
    
    eSamplerate = ephysDat.samplerate;
    ephysData = datchandata(ephysDat,'Ephys');
    timeEphys = 0:1/eSamplerate:(length(ephysData)-1)/eSamplerate;
    
    %% Allign Ephys Data
    spikesForAlignment = 100:150;
    
    timeofsimplespikes = datchandata(behaviorDat,'ss');    
    eventsSampleTime = timeofsimplespikes * eSamplerate;
    eventsSampleTime = eventsSampleTime(spikesForAlignment);
    eventsSampleTime = round(eventsSampleTime);
    eventsSampleTime = eventsSampleTime - eventsSampleTime(1);
    
    sumofthings = nan(length(ephysData),1);
    
    for x = 1:length(ephysData)
        if max(eventsSampleTime + x) > length(ephysData)
            break
        end
        sumofthings(x) = sum(ephysData(eventsSampleTime + x));
    end
    
    %% Modify ephys
    maxMatchValue = max(abs(sumofthings));
    maxSumLoc = timeEphys(find(abs(sumofthings) == maxMatchValue));
    
    if maxMatchValue > 30
        shiftAmt = -(maxSumLoc - timeofsimplespikes(100));
        timeEphys = timeEphys + shiftAmt;
        shiftConfidence = maxMatchValue;
        
        if plotOn
            figure(9);clf
            plot(timeEphys, abs(sumofthings))
            ylim([0 100])
            if ~isempty(maxSumLoc)
                vline(maxSumLoc + shiftAmt)
                xlim([maxSumLoc-1 maxSumLoc+1])
            end

            figure(10); clf
            plot(timeEphys, ephysData);
            vline(timeofsimplespikes(1:100))
            xlim([.5 1])
        end
        

    else
        shiftAmt = 0;
        shiftConfidence = 0;
    end
    
    %% add shifted ephys channel to behavior structure
    behaviorDat(end+1) = dat(ephysData, 'Ephys', length(behaviorDat)+1, eSamplerate, timeEphys(1),timeEphys(end),'mV?');