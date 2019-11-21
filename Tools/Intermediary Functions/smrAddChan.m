function smrAddChan(smrHandle, chandata, samplerate, title, units, offset)

fprintf('Adding new channel...')

% find/create a free/new channel and gather relevant data
newChanNum             = CEDS64GetFreeChan( smrHandle )
i64Time              = CEDS64SecsToTicks( smrHandle, offset )
% i64Div              = CEDS64SecsToTicks( smrHandle, 0-offset );
i64Div = 1/(samplerate*CEDS64TimeBase(smrHandle))
% SampleRateInHz = 1.0/(CEDS64ChanDiv(smrHandle, 1)*CEDS64TimeBase(smrHandle));
iType               = 1; % The type of waveform channel to create as 1 for a 16-bit integers or 9 for a RealWave channel.
% Prep Data
%chandata = int32(chandata*100);

createret = CEDS64SetWaveChan(smrHandle, newChanNum, i64Div, iType, samplerate);

if createret ~= 0, warning('Channel not created correctly'); end

% add data to the new channel
fillret = CEDS64WriteWave(smrHandle, newChanNum, int32(chandata), i64Time);
if fillret < 0, warning('Channel not filled correctly'); end

% Add channel info
CEDS64ChanTitle( smrHandle, newChanNum, title)
CEDS64ChanUnits( smrHandle, newChanNum, units)




fprintf('\n...Complete!\nChannel Added!\n\n')
