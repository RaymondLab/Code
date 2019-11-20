%% Open File
clear;clc;
dbstop if error
smrFile = 'G:\My Drive\Expmt Data\2019_07 - Alex Bonsai+Spike2 Sync Test Files\08301\data08301.smr';

%% Step 1 Allign Data

% Read Bonsai csv Files
dataTable = readtable('G:\My Drive\Expmt Data\2019_07 - Alex Bonsai+Spike2 Sync Test Files\08301\data08301original.csv');

% Extract the Time Stamps
timeStamps_bonsai = dataTable.Var1;

% Use only relative time
timeStamps_bonsai = timeStamps_bonsai - timeStamps_bonsai(1);

% Extract TTL+ Pulses from smr file
chanlist = readSpikeFile(smrFile,[]);
chanindsAll = [chanlist.number];
rawdata = importSpike(smrFile,chanindsAll(13));
pulseTimes_start = rawdata(1).data;

% ms --> s
timeStamps_bonsai = timeStamps_bonsai ./ 1000;


%% Frames
sampleLen = timeStamps_bonsai(2:end)-timeStamps_bonsai(1:end-1);
meanFR = mean(sampleLen);
stdFR = std(sampleLen);


%% Step 2 SMR Modification

% Copy File
newSmrHandle = smrCopy(smrFile, '_FP');

% Add first channel
data = dataTable.Var3*100;
samplerate = 1/meanFR;
title = 'chan1';
units = 'n/a';
smrAddChan(newSmrHandle, data, samplerate, title, units, pulseTimes_start);

% Add Second Channel
data = dataTable.Var4*1000;
samplerate = 1/meanFR;
title = 'chan2';
units = 'n/a';
smrAddChan(newSmrHandle, data, samplerate, title, units, pulseTimes_start);

%% tidy up
CEDS64CloseAll();
unloadlibrary ceds64int;