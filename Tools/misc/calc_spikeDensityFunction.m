function spikeDensityFunction = calc_spikeDensityFunction(spikeTimes, kernel_sd, samplerate)

% Get Data
spikeTimes = round(spikeTimes * samplerate);
binned = zeros(spikeTimes(end),1);

for i = 1:length(spikeTimes)
    binned(spikeTimes(i)) = 1;
end

% Kernel
edges = -5 * kernel_sd : 1/samplerate : 5 * kernel_sd;
kernel = normpdf(edges, 0, kernel_sd);
spikeDensityFunction = conv(binned, kernel);

end
