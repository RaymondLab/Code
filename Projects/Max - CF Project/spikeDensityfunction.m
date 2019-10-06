function sdf = plotSpikeDensityfunction(spikeTimes)%% Spike Density Function

%% Get Data
spikeTimes = round(spikeTimes*1000)/1000;

timeVec = [0:1/1000:33.0160]';
timeVec = round(timeVec*1000)/1000;

binned = timeVec == spikeTimes';
binned = sum(binned,2);


%% Kernel
kernel_sd = .05;
edges = -3 * kernel_sd : .001 : .3 * kernel_sd;
kernel = normpdf(edges, 0, kernel_sd);
kernel = kernel * .001;
s = conv(binned, kernel);
center = ceil(length(edges)/2);

figure();
plot(s);
ylim([-.3 .3])
hold on
