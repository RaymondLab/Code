function smrAddChan(smrHandle, chandata, samplerate, title, units)

fprintf('Adding new channel...')

% find/create a free/new channel and gather relevant data
newChan             = CEDS64GetFreeChan( smrHandle );
i64Div              = CEDS64SecsToTicks( smrHandle, 1/samplerate ); % The channel sample interval as an integral divide down from the file time base (with a minimum value of 1).
iType               = 1; % The type of waveform channel to create as 1 for a 16-bit integers or 9 for a RealWave channel.

createret = CEDS64SetWaveChan(smrHandle, newChan, i64Div, iType, samplerate);

if createret ~= 0, warning('Channel not created correctly'); end

% add data to the new channel
fillret = CEDS64WriteWave(smrHandle, newChan, int32(chandata), i64Div)
if fillret < 0, warning('Channel not filled correctly'); end

% Add channel info
CEDS64ChanTitle( smrHandle, newChan, title)
CEDS64ChanUnits( smrHandle, newChan, units)




fprintf('\n...Complete!\nChannel Added!\n\n')
