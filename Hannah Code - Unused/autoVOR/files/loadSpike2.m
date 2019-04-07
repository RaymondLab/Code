function data = loadSpike2(pathname, filename, offset1,offset2, channels,seg)

if ~exist('pathname','var')
    pathname = cd;
end

if ~exist('channels','var')
    channels = [1 2 3 4 5 6];
end

if ~exist('filename','var')
    try
        [filename, pathname] = uigetfile( {'*.smr','Spike2 (*.smr)'},'Pick an smr file');
    catch
    end
end

if ~exist('offset2','var')
    offset1 = input('Offset voltage 1: ');
    offset2 = input('Offset voltage 2: ');
end

%% Load data
    [~,filenameroot,ext] = fileparts(fullfile(pathname,filename));

%     data = importSpike(fullfile(pathname,[filenameroot ext]),[1 2 3 4 5 6 7   9 10]);
data = importSpike(fullfile(pathname,[filenameroot ext]),channels);

if exist('seg','var')
    data = datseg(data,seg);
end

% Add a chair velocity channel (not provided in D019)
ind = datchanind(data,'hhpos');
fs = data(ind).samplerate; % samplerate
data(end+1) = dat(smooth([diff(smooth(data(ind).data,50,'moving')); 0],50,'moving')*fs,'hhvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');

% Add a drum velocity channel (not provided in D019)
ind = datchanind(data,'htpos');
data(end+1) = dat(smooth([diff(smooth(data(ind).data,50,'moving')); 0],50,'moving')*fs,'htvel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');

% Calculate eye position from magnet signal
% offset1=2.5;
% offset2=2.5;
heposdata = calcEyeAngleMag(datchandata(data,'hepos1'), datchandata(data,'hepos2'),offset1,offset2);
data(end+1) = dat(heposdata,'hepos',[],fs,data(ind).tstart,data(ind).tend,'deg');
% data(end) = filt100Hz(data(end));

% Calculate eye velocity for plotting
data(end+1) = dat(smooth([diff(smooth(heposdata,50)); 0],50)*fs,'hevel',[],fs,data(ind).tstart,data(ind).tend,'deg/s');


% deleteInds = datchanind(data,{'HHVEL','HTVEL','htpos','hhpos','hepos1','hepos2'});
% data(deleteInds)=[];
% Save the data as a MATLAB file for faster future access
% save(fullfile(pathname,filename),'data')

% figure; plot(data)



