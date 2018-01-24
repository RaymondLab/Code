tic
%% open/read file and set up Environment
%clear;clc;close all
activateCEDS64

% Start Time
START_TIME = 0;
%AstSamples = floor(START_TIME * 1000);
AstSamples = 1;
% Wavelength
WAVELENGTH = 999;
% path to file


files = [
    %"Z:\1_Ruth Empson\151217 VOR\segment_1.smr"
    %"Z:\1_Ruth Empson\151217 VOR\segment_2.smr"
    %"Z:\1_Ruth Empson\151217 VOR\segment_3.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_4.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_5.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_6.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_7.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_8.smr"
    "Z:\1_Ruth Empson\151217 VOR\segment_9.smr"
    %"Z:\1_Ruth Empson\151217 VOR\segment_10.smr"
    ];

% Pre-allocate Vectors
offTotal = zeros(WAVELENGTH + 1, 1);
offCount = 0;
onTotal = zeros(WAVELENGTH + 1, 1);
onCount = 0;
badCount = 0;
sineTotal = zeros(WAVELENGTH + 1,1);

for q = 1:length(files)
    fhand1 = CEDS64Open(files{q});
    fprintf('\nSTARTING PART: %d\n', q)
    %% Gather data from specific channels
    % sineWave channel (8)
    [ ~, sineWave, ~ ] = CEDS64ReadWaveF(fhand1, 1, 600000000, 0);

    % ePhys channel (11)
    [ ~, ePhys, ~ ] = CEDS64ReadWaveF(fhand1,32, 600000000, 0);

    % light / dark channel (9)
    [ ~, tickTimes] = CEDS64ReadMarkers(fhand1, 9, 200, 0);


    %% CREATE TIMELINE OF 1s & 0s FOR ON/OFF LIGHT

    lightonoff = zeros(length(ePhys),1);

    for j = 1:length(tickTimes)
        if tickTimes(j).m_Code1 == 1
            windowStart = tickTimes(j).m_Time / 100;
            % if the file ends with the light on, then use end of file
            try
                windowEnd = tickTimes(j+1).m_Time / 100;
            catch
                windowEnd = length(lightonoff);
            end
            oneVec = ones(windowEnd - windowStart, 1);
            lightonoff(windowStart:windowEnd-1) = oneVec;
        end
    end



    %% PLOT EACH WAVE

    % how many sine waves can we use? 
    waveCount = floor((length(sineWave) - AstSamples) / WAVELENGTH);

    currentLocation = AstSamples;

    


    for i = 1:(waveCount - 1)

        hold on
        % get the proper ephys and sinewave slice
        waveform = ePhys( currentLocation : ( currentLocation + WAVELENGTH ));
        sineWaveSlice = sineWave( currentLocation : ( currentLocation + WAVELENGTH ));
        sineTotal = sineTotal + sineWaveSlice;

        % plot the slice
        figure(1)
        plot(sineWaveSlice, 'k')


        % light on?
        if lightonoff(currentLocation, 1) == 1
            if lightonoff(currentLocation + WAVELENGTH, 1) == 1
                onTotal = onTotal + waveform;
                onCount = onCount + 1;
                figure(2)
                plot(waveform,'k')
            else
                badCount = badCount + 1;
            end
        % light off?
        elseif lightonoff(currentLocation, 1) == 0
            if lightonoff(currentLocation + WAVELENGTH, 1) == 0
                offTotal = offTotal + waveform;
                offCount = offCount + 1;
                figure(3)
                plot(waveform,'k')
            else
                badCount = badCount + 1;
            end
        end

        currentLocation = currentLocation + WAVELENGTH + 1;
    end
end


% Calculate means
onMean = onTotal ./ onCount;
offMean = offTotal ./ offCount;

figure(1)
title('All Sine Waves')

figure(3)
plot(offMean,'r')
title('All Light OFF Waveforms and Their Mean')

figure(2)
plot(onMean,'r')
title('All Light ON Waveforms and Their Mean')

figure(5)
plot(onMean)
title('Light ON Mean')

figure(6)
plot(offMean)
title('Light OFF Mean')

figure(7)
hold on
plot(offMean, 'r')
plot(onMean, 'b')
title('Light OFF Mean & Light ON Mean')
legend('Light OFF Mean', 'Light ON Mean')


fprintf('There were:\n%d bad waveforms\n%d good waveforms\n\n', badCount, (offCount + onCount))
toc
