function fhand2 = smrCopy(smrFile, ending)

maxPointsToRead = 200000000;

%% Open file & gather info
activateCEDS64;
fhand1 = CEDS64Open(smrFile);
if (fhand1 <= 0);  fprintf(fhand1); CEDS64ErrorMessage(fhand1); unloadlibrary ceds64int; return; end
[~, OldFileId]  = CEDS64AppID( fhand1 );
timebase 		= CEDS64TimeBase( fhand1 );
maxchans 		= CEDS64MaxChan( fhand1 );

%% Create new file & set info to match original file
newFile = strrep(smrFile, '.smr', [ending, '.smr']);
fhand2 = CEDS64Create( newFile, maxchans);
if (fhand2 <= 0);  fprintf(fhand2); CEDS64ErrorMessage(fhand2); unloadlibrary ceds64int; return; end
CEDS64TimeBase( fhand2, timebase );
CEDS64AppID( fhand2, OldFileId );

%% copy all existing channels from original file (fhand1) to new file
fprintf('\nCopied Channels:')
for m = 1:maxchans
    chan = CEDS64ChanType( fhand1, m );

    if (chan > 0) % is there a channel m?
        chandiv = CEDS64ChanDiv( fhand1, m );
        rate = CEDS64IdealRate( fhand1, m );
    end

    switch(chan)
        case 0 % there is no channel with this number
        case 1 % ADC channel ( this is typically the ephys channel )
            [~, shortvals, shorttime] = CEDS64ReadWaveS( fhand1, m, maxPointsToRead, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 1, rate );
            CEDS64WriteWave( fhand2, m, shortvals, shorttime );
            fprintf(' %d', m)
        case 2 % Event Fall
            [~, evtimes] = CEDS64ReadEvents( fhand1, m, maxPointsToRead, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 2 );
            CEDS64WriteEvents( fhand2, m, evtimes );
            fprintf(' %d', m)
        case 3 % Event Rise
            [~, evtimes] = CEDS64ReadEvents( fhand1, m, maxPointsToRead, 0 );
            CEDS64SetEventChan( fhand2, m, rate, 3 );
            CEDS64WriteEvents( fhand2, m, evtimes );
            fprintf(' %d', m)
        case 4 % Event Both
            [~, levtimes, levinit] = CEDS64ReadLevels(fhand1, m, maxPointsToRead, 0);
            CEDS64SetLevelChan( fhand2, m, rate );
            CEDS64SetInitLevel( fhand2, m, levinit );
            CEDS64WriteLevels( fhand2, m, levtimes );
            fprintf(' %d', m)
        case 5 % Marker
            [~, markervals] = CEDS64ReadMarkers( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetMarkerChan( fhand2, m, rate, 5 );
            CEDS64WriteMarkers( fhand2, m, markervals );
            fprintf(' %d', m)
        case 6 % Wave Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, wmarkervals] = CEDS64ReadExtMarks( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetExtMarkChan(fhand2, m, rate, 6, Rows, Cols, chandiv);
            CEDS64WriteExtMarks( fhand2, m, wmarkervals);
            fprintf(' %d', m)
        case 7 % Real Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, rmarkervals] = CEDS64ReadExtMarks( fhand1, m, maxPointsToRead, 0 );
            CEDS64SetExtMarkChan( fhand2, m, rate, 7, Rows, Cols, -1);
            CEDS64WriteExtMarks( fhand2, m, rmarkervals);
            fprintf(' %d', m)
        case 8 % Text Mark
            [ ~, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand1, m );
            [~, tmarkervals] = CEDS64ReadExtMarks( fhand1, m, 100, 0 ); % NOTE: The maxpoints is lower than other channels!! 
            CEDS64SetExtMarkChan( fhand2, m, rate, 8, Rows, Cols, -1 );
            CEDS64WriteExtMarks( fhand2, m, tmarkervals); 
            fprintf(' %d', m)         
        case 9 % Realwave
            [~, floatvals, floattime] = CEDS64ReadWaveF( fhand1, m, maxPointsToRead, 0 );
            CEDS64SetWaveChan( fhand2, m, chandiv, 9, rate );
            CEDS64WriteWave( fhand2, m, floatvals, floattime );
            fprintf(' %d', m)
    end

    % copy units, comments, offsets etc.
    if (chan > 0)
        [ ~, sComment ] = CEDS64ChanComment( fhand1, m );
        [ ~ ] = CEDS64ChanComment( fhand2, m, sComment );
        [ ~, dOffset ] = CEDS64ChanOffset( fhand1, m );
        [ ~ ] = CEDS64ChanOffset( fhand2, m, dOffset );
        [ ~, dScale ] = CEDS64ChanScale( fhand1, m );
        [ ~ ] = CEDS64ChanScale( fhand2, m, dScale );
        [ ~, dTitle ] = CEDS64ChanTitle( fhand1, m );
        [ ~ ] = CEDS64ChanTitle( fhand2, m, dTitle );
        [ ~, sUnits ] = CEDS64ChanUnits( fhand1, m );
        [ ~ ] = CEDS64ChanUnits( fhand2, m, sUnits );
    end
end

fprintf('\n...Complete!\nAll channels copied!\n')