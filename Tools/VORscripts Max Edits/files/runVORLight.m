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
% Type (VORD/Generalization/Step)           - STRING% Time point (0, 5, 10...) (for plotting    - NUMERIC
% Frequency (only if sinusoidal, else blank)- NUMERIC
% Start Time                                - NUMERIC (s)
% End Time                                  - NUMERIC (s)
%
%   DEPENDENCIES
%       dat folder
%       VORsinefit.m
%       plotVOR.m

close all
pathname = cd;
[~, filenameroot] = fileparts(pathname);

%% ------------------------ Import time segments------------------------ %%
tFilename = [filenameroot '.xlsx'];
T = readtable(fullfile(pathname,tFilename));

% Look for stim segments (to plot average traces) - place word STIM
% anywhere in "Type" entry in excel file
STIMmask = ~cellfun(@isempty,regexpi(T.Type,'STIM'));

% Check start times
if any((T.EndTime-T.StartTime)<0); error('Make sure end times are after start times'); end

% Create labels for graphs
labels = strcat(T.Type, {' '}, num2str( T.Frequency), { 'Hz '}, num2str(T.TimePoint),{'min'});

%% ---------------------------Import calibration file -------------------%%
try  % Look in current folder
    filelist = dir;
    calIndex = ~cellfun(@isempty,strfind({filelist.name}, 'calib'));   
    % if no 'calib' file is found, try looking for alternative naming
    % format
    if sum(calIndex) == 0
        altName = strcat(filenameroot, '_', 'cali.mat');
        calIndex = contains({filelist.name}, altName);
    end
    filenameCal = filelist(calIndex).name; pathnameCal = cd;
catch % close popup to enter manually
    [filenameCal, pathnameCal] = uigetfile( {'*.mat','Matlab (.mat)'},'Pick a calibration file with scale factors','calib.mat');
end

%% ------------------------Import Spike2 data ---------------------------%%

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

%% Calculate eye pos and eye head visual velocities
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
if isempty(datchan(data,'hhvel'))
    ind = datchanind(data,'hhpos');
    data(end+1) = dat(smooth([diff(smooth(data(ind).data,50,'moving')); 0],50,'moving')*fs,'hhvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');
end

%% Calculate eye position from magnet signal
% Load calibration factors or enter manually
if filenameCal
    load(fullfile(pathnameCal, filenameCal));    
    if ~strncmpi(pathnameCal, cd, min(length(cd),length(pathnameCal)))
        copyfile(fullfile(pathnameCal, filenameCal),fullfile(cd, filenameCal))
    end       
else   % If no calib file available, enter manually
    figure; plot(datchan(data,{'hhvel','htvel','hepos1','hepos2'})); xlim([StartTime(2) EndTime(2)])
    scaleCh1 = input('Scale1: ');
    scaleCh2 = input('Scale2: ');   
    save(fullfile(cd, 'manual_calib.mat'), 'scaleCh1','scaleCh2') % Save scale factors
end

% Calculate scaled eye position
heposdata = scaleCh1*datchandata(data,'hepos1')+ scaleCh2*datchandata(data,'hepos2');
data(end+1) = dat(heposdata,'hepos',[],fs,data(1).tstart,data(1).tend,'deg');

% Filter with 100 Hz lowpass
data(end) = datlowpass(data(end),100);

% Calculate eye velocity 
veltau = .01; % s
hevel = movingslopeCausal(datchandata(data,'hepos'),round(fs*veltau))*fs;
data(end+1) = dat(hevel,'hevel',[],fs,data(1).tstart,data(1).tend,'deg/s');





%%  -----------------------------------------------------
%  ----------Set final parameters - desaccading----------
%  -----------------------------------------------------
velthres = 80;    % *** SET THRESHOLD HERE ***Higher threshold means fewer saccades will be detected
% load settings

%% -------------Run sine analysis for each relevant segment -------------%%
ploton = 1; % Change to 0 to turn off plots
result = VORsineFit(data, T.StartTime, T.EndTime, T.Frequency, labels, T.TimePoint,velthres, ploton);
fprintf('Artifacts: \n%f\nRsquare: \n%f\n',mean(result.data(:,12)),mean(result.data(:,13)))

% Plot results
figure(200)
norm = 0; % 0 plot absolute amp; 1 plot gain; 2 plot normalized gain

%plotVOR(result,'all',norm);
% Maxwell G. Hack, fixes final plot. Remove if needed 11-17
plotVORm(result,'all',norm);

title(sprintf('%s: %s',filenameroot), 'Interpreter', 'none')
print(fullfile(pathname, 'resultfig.jpg'),'-djpeg')
% print(fullfile(pathname, 'resultfig.pdf'),'-painters')

%% ---Run STIM analysis for each relevant segment (aligns on rising pulse of TTL)---
resultStim = [];
resultStep = [];
velthresStim = velthres;

if any(STIMmask)
    resultStim = VORstim(data, T.StartTime, T.EndTime, T.Frequency, labels, T.TimePoint,velthresStim, ploton, STIMmask);    
    resultsFilename =  'resultStim';
    save(fullfile(pathname, resultsFilename),'resultStim','velthresStim');
end

%% -------------Save results -------------
save(fullfile(pathname, 'result'), 'result','resultStep','resultStim');

% Save threshold settings
save(fullfile(pathname, 'settings'),'velthres','velthresStim')

% Append results to Excel
xlswrite(fullfile(pathname,tFilename),{'Delta [t30 - t0]'}, 'Sheet1', 'A20'); 
xlswrite(fullfile(pathname,tFilename),result.data(:,4:end),'Sheet1','J2');
xlswrite(fullfile(pathname,tFilename),result.header(4:end),'Sheet1','J1');
figure(200)