function [amp, phase, freq] = fit_sineWave(data, samplerate, freq)


% set up thing to fit
segLength = length(data);
segTime = (1:segLength)/samplerate; 


if ~exist('freq', 'var')
    
    Y = fft(data(~isnan(data)));
    P2 = abs(Y/segLength);
    powerTrace = P2(1:segLength/2+1);
    powerTrace(2:end-1) = 2*powerTrace(2:end-1);
    freqDomain = samplerate*(0:(segLength/2))/segLength;
    
    minFreq = .1;
    powerTrace(freqDomain < minFreq) = [];
    freqDomain(freqDomain < minFreq) = [];
    
    pks = findpeaks(powerTrace, samplerate);
    biggestPeak = max(pks);
    exactFreq = freqDomain(find(powerTrace == biggestPeak));
    roundedFreq = round(exactFreq, 1);
    freq = roundedFreq;
    
end

y1 = sin(2*pi*freq*segTime(:));
y2 = cos(2*pi*freq*segTime(:));
constant = ones(segLength,1);
vars = [y1 y2 constant];

% Do regression, calculate amplitude and phase
[b,~,~,~,stat] = regress(data, vars);
amp = sqrt(b(1)^2+b(2)^2);
phase = rad2deg(atan2(b(2), b(1)));

end