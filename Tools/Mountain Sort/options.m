ops.target                  = ''; % target .smr file to use
ops.method                  = 'mountainSort';   % ['plexon' or 'mountainSort'] What method did you use to sort spikes? 
ops.chanNum                 = 8 ;               % What chan # were the waveforms extracted from?
ops.chanName                = {'epthys', 'ephys2'};        % name of chan
ops.spike_window_waveform   = [-.0004, .0004];  % [(ms), (ms)] t before and t after the 'spike time' listed in the mda/txt file to generate the actual waveform
ops.sampleRate              = 50000;            % sample rate in Hz of recording
ops.newFileName             = ('_MS.smr');    % new ending for file name. This will replace '.smr'
ops.maxPoints2Read          = 200000000;         % maximum number of points to read in a channel. INCREASE this when an ephys channel doesn't get copied completely. DECREASE to solve some memory peoblems. 
ops.waveformChans           = 1;                % Number of channels in waveform (single electrode = 1, tetrode - 4, etc...)
ops.chanTitle               = 'Title';
ops.chanComment             = sprintf('Spikes obtained through %s', ops.method);
ops.chanUnits               = 'V';