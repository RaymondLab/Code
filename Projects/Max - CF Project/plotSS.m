%% plot simple spikes in range of xlims

xlimits = xlim();

spikeTimes = (recData(8).data);

spikeTimes(spikeTimes < xlimits(1)) = [];
spikeTimes(spikeTimes > xlimits(2)) = [];


vline(spikeTimes, 'k')


diff(xlim)
