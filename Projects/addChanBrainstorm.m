%% Open File
clear;clc;close all
dbstop if error
smrFile = 'C:\Users\maxwellg\Desktop\TempProjectData\Sriram\OKR\2018_09_24_2\2018_09_24_2.smr';

%% Step 1 Allign Data


%% Step 2 SMR Modification
% copy file
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