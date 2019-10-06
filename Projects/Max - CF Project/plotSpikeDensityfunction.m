function sdf = plotSpikeDensityfunction(spikeTimes, kernel_sd)%% Spike Density Function

%% Get Data
spikeTimes = round(spikeTimes*1000)/1000;

timeVec = [0:1/1000:33.0160]';
timeVec = round(timeVec*1000)/1000;

binned = timeVec == spikeTimes';
binned = sum(binned,2);


%% Kernel
edges = -3 * kernel_sd : .001 : .3 * kernel_sd;
kernel = normpdf(edges, 0, kernel_sd);
kernel = kernel * .001;
sdf = conv(binned, kernel);
center = ceil(length(edges)/2);

%figure(1);clf
%plot(sdf);
%ylim([-.2 .2])
