function sdf = plotSpikeDensityfunction(spikeTimes, kernel_sd)%% Spike Density Function

%% Get Data
ephysSampleRate = 50000;

spikeTimes = round(spikeTimes*100000)/100000;

timeVec = [0:1/ephysSampleRate:max(spikeTimes)]';
timeVec = round(timeVec*100000)/100000;

binned = timeVec == spikeTimes';
binned = sum(binned,2);


%% Kernel

edges = -3 * kernel_sd : 1/ephysSampleRate : 3 * kernel_sd;
kernel = normpdf(edges, 0, kernel_sd);
%kernel = kernel * 1/ephysSampleRate;
sdf = conv(binned, kernel);
%center = ceil(length(edges)/2);


