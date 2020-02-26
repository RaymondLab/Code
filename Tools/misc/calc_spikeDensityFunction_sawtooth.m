function spikeDensityFunction = calc_spikeDensityFunction_sawtooth(spikeTimes, kernel_sd, samplerate)

% Get Data
spikeTimes = round(spikeTimes * samplerate);
binned = zeros(spikeTimes(end),1);

for i = 1:length(spikeTimes)
    binned(spikeTimes(i)) = 1;
end

% Kernel
edges = -5 * kernel_sd : 1/samplerate : 5 * kernel_sd;
kernel = flip(edges(1:length(edges)));
spikeDensityFunction = conv(binned, kernel);

end
