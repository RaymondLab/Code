
%% Prep & params
clear;clc;close all

thresh = .0078;
window = [20 40];

% 114
file = 'Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Exp-GCamp-115-07182018-OKR only\Exp-GCamp-114-07182018-OKR only3.smr';
startT = 160;
endT = 560;

% 115
%file = 'Z:\1_Maxwell_Gagnon\ProjectData_Amin\Boris Recordings\Exp-GCamp-115-07182018-OKR only\Exp-GCamp-115-07182018-OKR only3.smr';
%startT = 149.6379 + 6; 
%endT = 615.3886 - 6;

% Extract data
chanlist = readSpikeFile(file, []);
chanindsAll = [chanlist.number];

% Acceptor
%chanlabels = {'hhpos','htpos','hepos1','hepos2','hepos','vepos','hhvel','htvel','htvel','TTL3','TTL4', 'Memorya', 'Keyboard'};

% Donor
chanlabels = {'hhpos','htpos','hepos1','hepos2','hepos','vepos','hhvel','htvel','htvel','TTL3','TTL4', 'Memoryd', 'Keyboard'};

chaninds = find(      arrayfun(@(x) any(strcmp(x.title,chanlabels)),chanlist)     );
rawdata = importSpike(file,chanindsAll(chaninds));

%% for either

% make ephys channel matrix
ephys_chan = rawdata(end-1).data(startT*1000:endT*1000);
ephys_chan_mat = vec2mat(ephys_chan,1000);
ephys_chan_mat(end,:) = [];

% make drum velocity matrix
drum_chan = rawdata(1).data(startT*1000:endT*1000);
drum_chan_mat = vec2mat(drum_chan,1000);
drum_chan_mat(end,:) = [];


% manual spike time extraction
putitive_spikes = ephys_chan > thresh;
% create spike window
for i = 1:length(putitive_spikes)
    if putitive_spikes(i) == 1
        % block out the rest of spike. Only keep initial detection point
        putitive_spikes(i+1:i+window(2)-1) = 0;
    end
end

% make matrix of spike times
putitive_spikes_mat = vec2mat(putitive_spikes, 1000);
putitive_spikes_mat(end,:) = [];

% 1000 bins (raw)
putitive_spikes_mat_raw = sum(putitive_spikes_mat);
% 500 bins
putitive_spikes_mat_500bin = putitive_spikes_mat_raw(1:2:end) + putitive_spikes_mat_raw(2:2:end);
% 250 bins
putitive_spikes_mat_250bin = putitive_spikes_mat_500bin(1:2:end) + putitive_spikes_mat_500bin(2:2:end);
% 125 bins
putitive_spikes_mat_125bin = putitive_spikes_mat_250bin(1:2:end) + putitive_spikes_mat_250bin(2:2:end);


%% plotting

figure(1)
subplot(3,1,1)
plot(nanmean(drum_chan_mat), 'k');
subplot(3,1,2)
bar(putitive_spikes_mat_125bin)
subplot(3,1,3)
plot(nanmean(ephys_chan_mat), 'k');
xlabel('Time (ms)')
























