%% Open File
clear;clc;
dbstop if error
smrFile = 'G:\My Drive\Expmt Data\2019_07 - Alex Bonsai+Spike2 Sync Test Files\0805\data0805.smr';

%% Step 1 Allign Data

% Read Bonsai csv Files
dataTable = readtable('G:\My Drive\Expmt Data\2019_07 - Alex Bonsai+Spike2 Sync Test Files\0805\data0805.csv');
testTable = readtable('G:\My Drive\Expmt Data\2019_07 - Alex Bonsai+Spike2 Sync Test Files\0805\test0805.csv');

% Extract the Time Stamps
aa = dataTable.Var1;
bb = testTable.Var1(contains(testTable.Var2, 'True'));

% Use only relative time
bb = bb - aa(1);
aa = aa - aa(1);

% Extract TTL+ Pulses from smr file
chanlist = readSpikeFile(smrFile,[]);
chanindsAll = [chanlist.number];
rawdata = importSpike(smrFile,chanindsAll(8));
TTLpos = rawdata(1).data;

% ms --> s
bb = bb ./ 1000;
aa = aa ./ 1000;

eventDiff = (bb - TTLpos);
%% debug plotting
figure()
ha = tight_subplot(2,1,[0 0],[.03 .03],[.03 .03]);
axes(ha(1))
vline([0; bb], 'k')
xlim([0 200])
axes(ha(2))
vline([0; TTLpos], 'k')
xlim([0 200])
%linkaxes(ha, 'x')

bbIntervals = bb(2:end) - bb(1:end-1);
TTLposIntervals = TTLpos(2:end) - TTLpos(1:end-1);
figure()
scatter(TTLposIntervals, zeros(1,length(TTLposIntervals))); hold on
scatter(bbIntervals, ones(1,length(bbIntervals)));
xlim([.999 1.004])
ylim([-.5 1.5])
%% Step 2 SMR Modification

% Copy File
newSmrHandle = smrCopy(smrFile, '_FP');

% Add fist channel
data = [];
samplerate = 20000;
title = 'chan1';
units = 'n/a';
smrAddChan(newSmrHandle, data, samplerate, title, units);

% Add Second Channel
data = [];
samplerate = 20000;
title = 'chan2';
units = 'n/a';
smrAddChan(newSmrHandle, data, samplerate, title, units);

% Add Third Channel
data = [];
samplerate = 20000;
title = 'chan3';
units = 'n/a';
smrAddChan(newSmrHandle, data, samplerate, title, units);

%% tidy up
CEDS64CloseAll();
unloadlibrary ceds64int;