function sdf = plotSpikeDensityfunction(spikeTimes, kernel_sd)%% Spike Density Function

%% Get Data
ephysSampleRate = 50000;
spikeTimes = round(spikeTimes * ephysSampleRate);
binned = zeros(spikeTimes(end),1);


for i = 1:length(spikeTimes)
    binned(spikeTimes(i)) = 1;
end

%% Kernel
edges = -3 * kernel_sd : 1/ephysSampleRate : 3 * kernel_sd;
kernel = normpdf(edges, 0, kernel_sd);
sdf = conv(binned, kernel);


