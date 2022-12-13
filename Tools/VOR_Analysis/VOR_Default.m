function params = VOR_Default(params)
%{
VOR_Default

This script takes information stored inside of an smr file and
    1) preprocces it
    2) run the default sine analysis script

This is a modified version of Hannah Payne's script 'runVOR'.

Requires three files to be stored in the current folder
  1. '.smr' data file with channels named 'hepos' etc
  2. '.csv' or '.xls' or 'xlsx' spreadsheet with time segments for analysis
  3. 'calib.mat' file with scaleCh1 and scaleCh2 specifying scale factors
  from calibration (one channel should be 0)

Max Gagnon 8/6/18

%}

%% === Import start/stop times from .smr file ========================== %%



%% === Import Time Segments ============================================ %%
T = readtable(fullfile(params.folder,[params.file '.xlsx']));

% Remove NaN values from T
goodRows = ~isnan(table2array(T(:,2)));
params.segAmt = sum(goodRows);
T = T(goodRows,:);


% Used for some of Jaydev & Sriram's Experiments Summer 2019
[params.segStarts, params.segEnds] = extractSineSegs_B(params.folder);

if length(params.segStarts) ~= params.segAmt
    % Old Version
    [params.segStarts, params.segEnds] = extractSineSegs(params.folder);
    if length(params.segStarts) ~= params.segAmt
        % New Version
        [params.segStarts, params.segEnds] = extractSegmentTimes(params.folder);
        if length(params.segStarts) ~= params.segAmt
            error(sprintf(['\n\n\nSegment Count Error \n', ...
               'Segments Listed in Excel File: ', num2str(params.segAmt), '\n', ...
               'Segments Found After Listed Start Time: ', num2str(length(params.segStarts)), '\n', ...
               'Listed start time needs to be before the first segment starts\n\n']))
        end
    end
end

% Pull out start/end times and frequency
frequency = T.Frequency;
timepts = T.TimePoint;

% Create labels for graphs
timePoints = strrep(cellstr(num2str(T.TimePoint)), ' ', '');
labels = strcat(timePoints, {' min  '}, T.Type, {'  '}, num2str( T.Frequency), { 'Hz'});

%% === Import Calibration File ========================================= %%

% try to find calib file automatically, otherwise prompt user
clear params.fileCalib

if exist(fullfile(params.folder, [params.file '_calib.mat']), 'file')
    params.fileCalib = [params.file '_calib.mat'];
    params.folderCalib = params.folder;
elseif exist(fullfile(params.folder,[params.file '_cali.mat']), 'file')
    params.fileCalib = [params.file '_cali.mat'];
    params.folderCalib = params.folder;
elseif exist(fullfile(params.folder, 'manual_calib.mat'), 'file')
    params.fileCalib = 'manual_calib.mat';
    params.folderCalib = params.folder;
else
    [params.fileCalib, params.folderCalib] = uigetfile( {'*.mat','Matlab (.mat)'},'Pick a calibration file with scale factors','calib.mat');
end

%% === Import Spike2 Data ============================================== %%

% if no smr file found automatically, prompt user
if ~exist(fullfile(params.folder, [params.file '.smr']), 'file')
    [params.file, params.folder] = uigetfile( {'*.smr','Spike2 (*.smr)'},'Pick an smr or pre-loaded .mat file');
end

% Load data from Spike2
chanlist = readSpikeFile(fullfile(params.folder,[params.file '.smr']),[]);
chanindsAll = [chanlist.number];
chanlabels = {'hhpos','htpos','hepos1','hepos2','hepos','vepos','hhvel','htvel','TTL3','TTL4'};
chaninds = find(      arrayfun(@(x) any(strcmp(x.title,chanlabels)),chanlist)     );
rawdata = importSpike(fullfile(params.folder,[params.file '.smr']),chanindsAll(chaninds));

%% === Calculate Drum and Chair Velocities ============================= %%
data = rawdata;
fs = data(1).samplerate;
%ADD for new rig setup (Changed by:Sima 2.2.22)
if data(1).samplerate == 'event'
    fs = data(3).samplerate ;
end
% Add a drum velocity channel if needed
if isempty(datchan(data,'htvel')) || max(datchandata(data,'htvel'))<.1
    data(datchanind(data,'htvel')) = [];
    ind = datchanind(data,'htpos');
    if ~isempty(ind)
        data(end+1) = dat(smooth([diff(smooth(data(ind).data,50)); 0],50)*fs,'htvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');
    end
end

% Add a chair velocity channel if needed
if isempty(datchan(data,'hhvel')) || max(datchandata(data,'hhvel'))<.1
    data(datchanind(data,'hhvel')) = [];
    ind = datchanind(data,'hhpos');
    if ~isempty(ind)
        data(end+1) = dat(smooth([diff(smooth(data(ind).data,50)); 0],50)*fs,'hhvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');
    end
end

%% === Scale Eye Chans and Calculate Eye Velocity ====================== %%

% Load calibration factors, otherwise prompt user
if params.fileCalib
    load(fullfile(params.folderCalib, params.fileCalib));
    if ~strncmpi(params.folderCalib, cd, min(length(cd),length(params.folderCalib)))
        copyfile(fullfile(params.folderCalib, params.fileCalib),fullfile(cd, params.fileCalib))
    end
else   
    figure; plot(datchan(data,{'hhvel','htvel','hepos1','hepos2'})); xlim([params.segStarts(2) params.segEnds(2)])
    scaleCh1 = input('Scale1: ');
    scaleCh2 = input('Scale2: ');
    save(fullfile(cd, 'manual_calib.mat'), 'scaleCh1','scaleCh2') % Save scale factors
end

% Calculate scaled eye position
%First check for eye magnets channel be in the same size (Added by:Sima 2.2.22)
sizehepos1 = size(datchandata(data,'hepos1'));
sizehepos2 = size(datchandata(data,'hepos2'));
datahepos1 = datchandata(data,'hepos1');
datahepos2 = datchandata(data,'hepos2');
if sizehepos1 == sizehepos2
    heposdata = scaleCh1*datahepos1 + scaleCh2*datahepos2;
else
    %error(sprintf('The size of the two magnets are not the same')) %In case to stop the further analysis  
    
    % In case to match the size of two channels, the end of the smaller channel padded with the last value
    if sizehepos2(1) < sizehepos1(1)
        datahepos2 = padarray(datahepos2,[sizehepos1-sizehepos2 0],'replicate','post');
        heposdata = scaleCh1*datahepos1 + scaleCh2*datahepos2;
    else
        datahepos1 = padarray(datahepos1,[sizehepos2-sizehepos1 0],'replicate','post');
        heposdata = scaleCh1*datahepos1 + scaleCh2*datahepos2;
    end
    
end

% Create and add 'horizontal eye position' channel to channel list
data(end+1) = dat(heposdata,'hepos',[],fs,data(1).tstart,data(1).tend,'deg');

% Filter with 100 Hz lowpass
data(end) = datlowpass(data(end),100);

% Calculate eye velocity for plotting
veltau = .01;
hevel = movingslopeCausal(datchandata(data,'hepos'),round(fs*veltau))*fs;

% Create and add 'horiontal eye velocity' channel to channel list
data(end+1) = dat(hevel,'hevel',[],fs,data(1).tstart,data(1).tend,'deg/s');

%% === Run Sine Analysis for Each Relevant Segment ===================== %%
if strcmp(params.analysis, 'Amin_GC_Steps')
    result = VOR_StepFit(data, frequency, labels, timepts, params);
%ADDED By Sima (4.27.2022)
elseif strcmp(params.analysis, 'No motor movment')
    result = VOR_FitNew(data, frequency, labels, timepts, params);
elseif strcmp(params.analysis, 'Sriram_OKR')
    result = VOR_SineFitSriram(data, frequency, labels, timepts, params);
else
    result = VOR_SineFit(data, frequency, labels, timepts, params);
end

% Append results to Excel
xlswrite(fullfile(params.folder,[params.file '.xlsx']),result.data(:,4:end),'Sheet1','J2');
xlswrite(fullfile(params.folder,[params.file '.xlsx']),result.header(4:end),'Sheet1','J1');

%% === Save .mat file of results ======================================= %%
save(fullfile(params.folder, 'result'), 'result','T');
save(fullfile(params.folder, [params.file, '_DatObject.mat']), 'data')
