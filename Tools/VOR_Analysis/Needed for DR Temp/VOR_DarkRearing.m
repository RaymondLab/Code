function VOR_DarkRearing(params)


%% runVOR   Analyze VOR behavioral data directly from Spike2 files (.smr)
%
% modified from SineFitBNwSlip_GenSD_auto 8/2012 by Hannah Payne:
%   - automatically import files directly from Spike2 (.smr) to Matlab
%   - improve readability/maintainability
%   - Display saccade elimination traces
%
% Requires three files to be stored in the current folder
%   1. '.smr' data file with channels named 'hepos' etc
%   2. '.csv' or '.xls' or 'xlsx' spreadsheet with time segments for analysis
%   3. 'calib.mat' file with scaleCh1 and scaleCh2 specifying scale factors
%   from calibration (one channel should be 0)
%
% Format for excel file: Include headers (name must be exact, but not case sensitive)
% Type (VORD/Generalization/Step)           - STRING
% Time point (0, 5, 10...) (for plotting    - NUMERIC
% Frequency (only if sinusoidal, else blank)- NUMERIC
% Start Time                                - NUMERIC (s)
% End Time                                  - NUMERIC (s)
%
%   DEPENDENCIES
%       dat folder
%       VORsinefit.m
%       plotVOR.m

%% === Setup =========================================================== &&

% if nothing was input into the function, use default settings
 if ~exist('params','var')
     params.do_individual = 1;
     params.saccadePre = .075;
     params.saccadePost = .2;
     params.saccadeThresh = .55;
 end

pathname = cd;
[~, filenameroot] = fileparts(pathname);

ploton = params.do_individual;
saccadeWindow = [params.saccadePre, params.saccadePost];
saccadeThresh = params.saccadeThresh;

%% === Import Time Segments ============================================ %%
tFilename = [filenameroot '.xlsx'];
T = readtable(fullfile(pathname,tFilename));

VORDmask = ~cellfun(@isempty,regexpi(T.Type,'VORD'));
STIMmask = ~cellfun(@isempty,regexpi(T.Type,'STIM'));

% Pull out start/end times and frequency
tstart = T.StartTime;
tstop = T.EndTime;
frequency = T.Frequency;
timepts = T.TimePoint;
if any((tstop-tstart)<0); error('Make sure end times are after start times'); end

% Create labels for graphs
labels = strcat(T.Type, {' '}, num2str( T.Frequency), { 'Hz '}, num2str(T.TimePoint),{'min'});

%% === Import Calibration File ========================================= %%
% try to find automatically
filelist = dir;
clear filenameCal
for i = 1:length(filelist)
    if contains(filelist(i).name, 'calib.mat') || contains(filelist(i).name, 'cali.mat')
        filenameCal = filelist(i).name;
        pathnameCal = cd;
        break
    end
end

% if no calib file found automatically, prompt user
if ~exist("filenameCal", 'var')
    [filenameCal, pathnameCal] = uigetfile( {'*.mat','Matlab (.mat)'},'Pick a calibration file with scale factors','calib.mat');
end

%% === Import Spike2 Data ============================================== %%

if ~exist(fullfile(pathname, [filenameroot '.smr']),'file')
    [filename, pathname] = uigetfile( {'*.smr','Spike2 (*.smr)'},'Pick an smr or pre-loaded .mat file');
    [~,filenameroot] = fileparts(fullfile(pathname,filename));
end

%  Load data from Spike2
chanlist = readSpikeFile(fullfile(pathname,[filenameroot '.smr']),[]);
chanindsAll = [chanlist.number];
chanlabels = {'hhpos','htpos','hepos1','hepos2','hepos','vepos','hhvel','htvel','htvel','TTL3','TTL4'};
chaninds = find(arrayfun(@(x) any(strcmp(x.title,chanlabels)),chanlist));
rawdata = importSpike(fullfile(pathname,[filenameroot '.smr']),chanindsAll(chaninds));

%% === Calculate Drum and Chair Velocities ============================= %%
data = rawdata;
fs = data(1).samplerate;

% Add a drum velocity channel if needed
if isempty(datchan(data,'htvel'))
    ind = datchanind(data,'htpos');
    if ~isempty(ind)
    data(end+1) = dat(smooth([diff(smooth(data(ind).data,50)); 0],50)*fs,'htvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');
    end
end

% Add a chair velocity channel if needed
if isempty(datchan(data,'hhvel')) || max(datchandata(data,'hhvel'))<.1
    data(datchanind(data,'hhvel')) = [];
    ind = datchanind(data,'hhpos');
    data(end+1) = dat(smooth([diff(smooth(data(ind).data,50,'moving')); 0],50,'moving')*fs,'hhvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');
end

%% === Scale Eye Chans and Calculate Eye Velocity ====================== %%
% Load calibration factors or enter manually
if filenameCal
    load(fullfile(pathnameCal, filenameCal));
    if ~strncmpi(pathnameCal, cd, min(length(cd),length(pathnameCal)))
        copyfile(fullfile(pathnameCal, filenameCal),fullfile(cd, filenameCal))
    end
else   % If no calib file available, enter manually
    figure; plot(datchan(data,{'hhvel','htvel','hepos1','hepos2'})); xlim([tstart(2) tstop(2)])
    scaleCh1 = input('Scale1: ');
    scaleCh2 = input('Scale2: ');
    save(fullfile(cd, 'manual_calib.mat'), 'scaleCh1','scaleCh2') % Save scale factors
end

% Calculate scaled eye position
heposdata = scaleCh1*datchandata(data,'hepos1') + scaleCh2*datchandata(data,'hepos2');
data(end+1) = dat(heposdata,'hepos',[],fs,data(1).tstart,data(1).tend,'deg');

% Filter with 100 Hz lowpass
data(end) = datlowpass(data(end),100);

% Calculate eye velocity for plotting
veltau = .01;
hevel = movingslopeCausal(datchandata(data,'hepos'),round(fs*veltau))*fs;
data(end+1) = dat(hevel,'hevel',[],fs,data(1).tstart,data(1).tend,'deg/s');

%% === Run Sine Analysis for Each Relevant Segment ===================== %%
velthres = 80;    % *** SET THRESHOLD HERE ***Higher threshold means fewer saccades will be detected
result = VORsineFit(data, T.StartTime, T.EndTime, T.Frequency, labels, T.TimePoint,velthres, ploton);
fprintf('Artifacts: \n%f\nRsquare: \n%f\n',mean(result.data(:,12)),mean(result.data(:,13)))

%% === Plot Final Results ============================================== %%
figure(200)
norm = 0; % 0 plot absolute amp; 1 plot gain; 2 plot normalized gain
plotVORm(result,'all',norm);
title(sprintf('%s: %s',filenameroot), 'Interpreter', 'none')
print(fullfile(pathname, 'resultfig.jpg'),'-djpeg')

%% ---Run STIM analysis for each relevant segment (aligns on rising pulse of TTL)---
resultStim = [];
resultStep = [];
velthresStim = velthres;

if any(STIMmask)
    resultStim = VORstim(data, tstart, tstop, frequency, labels, timepts,velthresStim, pulseDur, ploton, STIMmask);
    resultsFilename =  'resultStim';
    save(fullfile(pathname, resultsFilename),'resultStim','velthresStim');
end

%% === Save Results ==================================================== %%
save(fullfile(pathname, 'result'), 'result','resultStep','resultStim');

% Save threshold settings
save(fullfile(pathname, 'settings'),'velthres','velthresStim')

% Append results to Excel
xlswrite(fullfile(pathname,tFilename),{'Delta [t30 - t0]'}, 'Sheet1', 'A20');
xlswrite(fullfile(pathname,tFilename),result.data(:,4:end),'Sheet1','J2');
xlswrite(fullfile(pathname,tFilename),result.header(4:end),'Sheet1','J1');

fprintf('Results saved in %s\n', pathname)
