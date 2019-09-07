function chanData = maestro2dat(filename, samplerate)

    % Assume sample rate of 50,000
    if ~exist('samplerate','var')
        samplerate = 50000;
    end
    
    %% Load Ephys Data
    ephys = openmaestro(filename);
    
    if isempty(ephys)
        warning('Something went wrong!')
        chanData = [];
        return
    end
    
    timeVec = 0:1/samplerate:(length(ephys)-1)/samplerate;
    tstart = timeVec(1);
    tend   = timeVec(end);
    
    %% Store data in dat format
    chanData = dat(ephys, 'Ephys',8,samplerate,tstart(1),tend(end),'mV?');