tic
%% open/read file and set up Environment
activateCEDS64
WAVELENGTH = 999;
file = 'Z:\1_Maxwell_Gagnon\ProjectData_Ruth\191217\191217_VSFP_Mouse_1_x2_VOR.smr';
fhand1 = CEDS64Open(file);

% Drum Position
[ ~, sineWave, ~ ] = CEDS64ReadWaveF(fhand1, 3, 600000000, 0);
% FLUOR Signal
[ ~, chan11, ~ ] = CEDS64ReadWaveF(fhand1, 11, 600000000, 0);
% FLOUR Signal
[ ~, chan12, ~ ] = CEDS64ReadWaveF(fhand1, 12, 600000000, 0);
         
segments = [930.15445210 969.83098830 1
            992.31735100 1029.8619466 1 
            1042.9677707 1084.8385133 1
            1085.9562587 1384.6236020 0 
            1402.9495546 1440.0079165 1
            1440.9634385 1739.9182796 0 
            1753.0031288 1794.8710889 1
            1796.0031261 2094.8435283 0
            2106.0245725 2149.8540037 1
            2151.0239975 2449.8290190 0
            2461.0247765 2504.9129316 1
            2506.0347693 2804.8608218 0
            2817.0392619 2860.1302735 1
            2861.0646947 3160.2033961 0
            3173.3433451 3214.9971012 1
            3237.4859525 3274.9658370 1
            3287.1091840 3329.8321359 1
            3642.1625700 3684.9957142 1
            ];


%% CYCLE THROUGH EACH SEGMENT       
for i = 1:length(segments)
    
    segStart = floor(segments(i,1) * 1000);
    segEnd = floor(segments(i,2) * 1000);
    waveCount = floor((segEnd - segStart) / WAVELENGTH);
    waveStart = segStart;
    
    % LIGHT
    if segments(i,3) == 0
        for j=1:waveCount
            % extract slices of data
            sineSlicesLIGHT(:,j) = sineWave(waveStart:(waveStart+WAVELENGTH));
            chan11SlicesLIGHT(:,j) = chan11(waveStart:(waveStart+WAVELENGTH));
            chan12SlicesLIGHT(:,j) = chan12(waveStart:(waveStart+WAVELENGTH));
            % update wave start time
            waveStart = waveStart + WAVELENGTH + 1;
        end
        
    % DARK 
    elseif segments(i,3) == 1
        for j=1:waveCount
            % extract slices of data
            sineSlicesDARK(:,j) = sineWave(waveStart:(waveStart+WAVELENGTH));
            chan11SlicesDARK(:,j) = chan11(waveStart:(waveStart+WAVELENGTH));
            chan12SlicesDARK(:,j) = chan12(waveStart:(waveStart+WAVELENGTH));
            % update wave start time
            waveStart = waveStart + WAVELENGTH + 1;
        end
    end
end

%% CHANNEL 11: Acceptor
%% SINEWAVES
% LIGHT
figure(1)
plot(sineSlicesLIGHT, 'b')
hold on
plot(mean(sineSlicesLIGHT,2), 'r')
title('LIGHT: Sinewaves Overlay')
% DARK
figure(2)
plot(sineSlicesDARK, 'k')
hold on
plot(mean(sineSlicesLIGHT,2), 'r')
title('DARK: Sinewaves Overlay')

%% Plot Overlays
% LIGHT
figure(3)
plot(chan11SlicesLIGHT, 'b')
hold on
plot(mean(chan11SlicesLIGHT,2), 'r')
title('LIGHT: Acceptor Overlay')
% DARK
figure(4)
plot(chan11SlicesDARK, 'k')
hold on
plot(mean(chan11SlicesDARK,2), 'r')
title('DARK: Acceptor Overlay')

%% Plot MEANS
% LIGHT
figure(5)
plot(mean(chan11SlicesLIGHT,2), 'b')
title('LIGHT: Acceptor Mean')
% DARK
figure(6)
plot(mean(chan11SlicesDARK,2), 'k')
title('DARK: Acceptor Mean')
% BOTH
figure(7)
plot(mean(chan11SlicesLIGHT,2), 'b')
hold on
plot(mean(chan11SlicesDARK,2), 'k')
title('DARK & LIGHT: Acceptor Means')

%% CHANNEL 12: DONOR
%% Plot Overlays
% LIGHT
figure(8)
plot(chan12SlicesLIGHT, 'b')
hold on
plot(mean(chan12SlicesLIGHT,2), 'r')
title('LIGHT: Donor Overlay')
% DARK
figure(9)
plot(chan12SlicesDARK, 'k')
hold on
plot(mean(chan12SlicesDARK,2), 'r')
title('DARK: Donor Overlay')

%% Plot MEANS
% LIGHT
figure(10)
plot(mean(chan12SlicesLIGHT,2), 'b')
title('LIGHT: Donor Mean')
% DARK
figure(11)
plot(mean(chan12SlicesDARK,2), 'k')
title('DARK: Donor Mean')
% BOTH
figure(12)
plot(mean(chan12SlicesLIGHT,2), 'b')
hold on
plot(mean(chan12SlicesDARK,2), 'k')
title('DARK & LIGHT: Donor Means')

         
         
