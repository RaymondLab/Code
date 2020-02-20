function firingRate = calc_recipInterval(spikeTimes, ephysLength, sampleRate)

    firingRate = nan(ephysLength,1);
    
    AAA = spikeTimes(2:end) - spikeTimes(1:end-1);
    BBB = AAA(1:end-1) - AAA(2:end);
    
    for w = 1:length(BBB)
        if BBB(w) > 0
            firingRate(round(spikeTimes(w+1)*sampleRate:spikeTimes(w+2)*sampleRate)) = 1/AAA(w);
        else
            start   = spikeTimes(w+1)*sampleRate;
            middle  = spikeTimes(w+1)*sampleRate + AAA(w)*sampleRate;
            stop    = spikeTimes(w+2)*sampleRate;

            firingRate(round(start : middle)) = 1/AAA(w);
            firingRate(round(middle+1 : stop)) = 1/AAA(w+1);
        end
    end
end