
% poorly written, please forgive!


commonSpikes = ones(1, length(data.default(2,:)));
% this removes the NOT common spikes, reset justTimes to contain running
% list of common spikes. If a spikes doesn't exist in a particular file, it
% will be removed. 
justTimes = data.default(2,:);
length(justTimes)

commonSpikes = ismember(justTimes, data.white_false(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.mask_art_true(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.clip_size_2msec(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.clip_size_1msec(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.clip_size_1p33msec(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.detect_thresh_3p2(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)

commonSpikes = ismember(justTimes, data.detect_thresh_2p8(2,:));
justTimes = justTimes(commonSpikes);
length(justTimes)


univSpikes = justTimes;


% removed replicated spikes times
spikeDups = ismember(data.default(2,:), univSpikes);
data.default = data.default(2,~spikeDups);

spikeDups = ismember(data.white_false(2,:), univSpikes);
data.white_false = data.white_false(2,~spikeDups);

spikeDups = ismember(data.mask_art_true(2,:), univSpikes);
data.mask_art_true = data.mask_art_true(2,~spikeDups);

spikeDups = ismember(data.clip_size_2msec(2,:), univSpikes);
data.clip_size_2msec = data.clip_size_2msec(2,~spikeDups);

spikeDups = ismember(data.clip_size_1msec(2,:), univSpikes);
data.clip_size_1msec = data.clip_size_1msec(2,~spikeDups);

spikeDups = ismember(data.clip_size_1p33msec(2,:), univSpikes);
data.clip_size_1p33msec = data.clip_size_1p33msec(2,~spikeDups);

spikeDups = ismember(data.detect_thresh_3p2(2,:), univSpikes);
data.detect_thresh_3p2 = data.detect_thresh_3p2(2,~spikeDups);

spikeDups = ismember(data.detect_thresh_2p8(2,:), univSpikes);
data.detect_thresh_2p8 = data.detect_thresh_2p8(2,~spikeDups);

data.univSpikes = univSpikes;


% make mda files
writemda(data.white_false, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\white_false.mda') 
writemda(data.default, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\default.mda')
writemda(data.mask_art_true, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\mask_art_true.mda')
writemda(data.clip_size_2msec, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\clip_size_2msec.mda')
writemda(data.clip_size_1msec, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\clip_size_1msec.mda')
writemda(data.clip_size_1p33msec, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\clip_size_1p33msec.mda')
writemda(data.detect_thresh_3p2, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\detect_thresh_3p2.mda')
writemda(data.detect_thresh_2p8, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\detect_thresh_2p8.mda')
writemda(data.univSpikes, 'Z:\1_Maxwell_Gagnon\Code\aaMiscWorkspace\SpikeComparisonTests\univSpikes.mda')
