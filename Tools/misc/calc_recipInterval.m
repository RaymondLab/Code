function firingRate = calc_recipInterval(spikeTimes, ephysLength, sampleRate)

    firingRate = nan(ephysLength,1);
    
    AAA = spikeTimes(2:end) - spikeTimes(1:end-1);
    
    eIndex = 0;
    tic
    for i = 1:length(firingRate)
        
        if eIndex >= length(spikeTimes)
            break
        end
        
        if (i / sampleRate) >= spikeTimes(eIndex+1)
            eIndex = eIndex + 1;
        end
        
        if eIndex == 1 || eIndex == 0
            continue
        end
        
        if AAA(eIndex-1) > ((i / sampleRate) - spikeTimes(eIndex))
           firingRate(i) = 1/AAA(eIndex-1);
        else
            firingRate(i) = 1/AAA(eIndex);
        end
    end
    toc
end