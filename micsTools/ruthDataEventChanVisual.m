tic
%% open/read file and set up Environment
%clear;clc;close all
activateCEDS64
% Wavelength
WAVELENGTH = 1999;
file = 'Z:\1_Maxwell_Gagnon\RuthProjectData\01_10_18\apples.smr';
fhand1 = CEDS64Open(file);
 
 %% Read Channel information
 load('jan12Workspace.mat')
 % sineWave channel (8)
 %[ ~, sineWave, ~ ] = CEDS64ReadWaveF(fhand1, 1, 600000000, 0);
 % smoothed donor channel
 %[ ~, smoothDonor, ~ ] = CEDS64ReadWaveF(fhand1, 17, 600000000, 0);
 % smoothed acceptor channel
 %[ ~, smoothAccept, ~ ] = CEDS64ReadWaveF(fhand1, 18, 600000000, 0);
 % Peak Smoothed Donor EVENTS
 %[~, dEvents] = CEDS64ReadEvents(fhand1, 13, 600000000, 0);
 % Peak Smoothed Acceptor EVENTS
 %[~, aEvents] = CEDS64ReadEvents(fhand1, 15, 600000000, 0);
 
% conversion
dEvents = dEvents ./ 100;
aEvents = aEvents ./ 100;




 

















% segment data
segments = [34.4071319 80.417285 1 0.099389695
             94.4198554 140.4404009 1 0.073845455         
             151.2009841 195.6984 1 0.075338549
             195.6984 495.2002536 0 0.08428348  
             506.2521841 550.7570 1 0.076105695
             550.7570 850.2618112 0 0.052867484   
             861.2737529  905.7913 1 0.059607717
             905.7913 1205.2772104 0 0.052621968
             1216.2876268 1260.7934 1 0.072681073
             1260.7934 1560.2979148 0 0.049920258
             1571.3062592 1615.7874 1 0.079747682
             1615.7874 1915.3113427 0 0.044458184
             1926.309162 1970.8137 1 0.091103762
             1970.8137 2270.3144864 0 0.043255639
             2279.5597266 2325.5662944 1 0.08406521
             2339.6987457 2385.695773 1 0.125541727
             2396.3908364 2440.4018015 1 0.068322224
             2751.4312707 2795.4422358 1 0.045031675
             ];
         
%% EVENTS
for i = 1:length(segments)
    
    segStart = floor(segments(i,1) * 1000);
    segEnd = floor(segments(i,2) * 1000);
    
    % remove incorrect events
    if i == 1
        dEvents(dEvents < segStart) = [];
        aEvents(aEvents < segStart) = [];
    elseif i == length(segments)
        dEvents(dEvents > segEnd) = [];
        aEvents(aEvents > segEnd) = [];
    else
        dEvents(dEvents > segEnd & dEvents < (floor(segments(i+1,1) * 1000))) = [];
        aEvents(aEvents > segEnd & aEvents < (floor(segments(i+1,1) * 1000))) = [];
    end    
end

% find the dEvents that create windows that contain an aEvent
good_dEvents = [];
for i = 1:length(dEvents)
    if sum((aEvents < (dEvents(i) + 5) & aEvents > (dEvents(i) - 5))) > 0
        good_dEvents = [good_dEvents; aEvents((aEvents < (dEvents(i) + 5) & aEvents > (dEvents(i) - 5)))];
    end
end
% NOTE: When looking for the windows, you might 'find' a match, when the match is
% OUT of the sinewave section! This causes the next section to lose a few
% windows!
eventcountON = [];
eventcountOFF = [];
VORON = [];
VOROFF = [];
EPSON = [];
EPSOFF = [];
%% 
for i = 1:length(segments)
    
    segStart = floor(segments(i,1) * 1000);
    segEnd = floor(segments(i,2) * 1000);
    
    % EVENT DATA
    % find current segment's window starters
    winInSeg = good_dEvents(good_dEvents > segStart & good_dEvents < segEnd); 
    % make the start time of the segment '0'
    winInSeg = winInSeg - segStart;
    % take modulo to find relative placement
    winInSeg = mod(winInSeg, WAVELENGTH);
    
    % SINE DATA
    waveCount = floor((segEnd - segStart) / WAVELENGTH);
    waveStart = segStart;
    sineSlices = zeros(WAVELENGTH+1, waveCount);
    donorSlices = zeros(WAVELENGTH+1, waveCount);
    acceptorSlices= zeros(WAVELENGTH+1, waveCount);
    
    for j=1:waveCount
        % extract slices of data from stim, donor, & acceptor
        sineSlices(:,j) = sineWave(waveStart:(waveStart+WAVELENGTH));
        donorSlices(:,j) = smoothDonor(waveStart:(waveStart+WAVELENGTH));
        acceptorSlices(:,j) = smoothAccept(waveStart:(waveStart+WAVELENGTH));
        % update wave start time
        waveStart = waveStart + WAVELENGTH + 1;
    end
    
    % plotting! 

    if segments(i,3) == 1
        
        figure(1)
        title('Dark: Stimulus')
        plot(sineSlices)
        hold on
        
        figure(2)
        title('Dark: Donor Signal')
        plot(donorSlices)
        hold on
        
        figure(3)
        title('Dark: Acceptor Signal')
        plot(acceptorSlices)
        hold on
        
        figure(4)
        title('Dark: Good Donor Events')
        histogram(winInSeg, 200)
        hold on
        
        eventcountOFF = [eventcountOFF; i length(winInSeg)];
        EPSOFF = [EPSOFF; i length(winInSeg) / ((segEnd - segStart) / 1000)];
        VOROFF = [VOROFF; i segments(i, 4)];    
    else 

        figure(7)
        title('Light: Stimulus')
        plot(sineSlices)
        hold on
        
        figure(8)
        title('Light: Donor Signal')
        plot(donorSlices)
        hold on
        
        figure(9)
        title('Light: Acceptor Signal')
        plot(acceptorSlices)
        hold on
        
        figure(10)
        title('Light: Good Donor Events')
        histogram(winInSeg, 200)
        hold on
        
        eventcountON = [eventcountON; i length(winInSeg)];
        EPSON = [EPSON; i length(winInSeg) / ((segEnd - segStart) / 1000)];
        VORON = [VORON; i segments(i, 4)];
    end    
end


figure(5)
title('Event count')
scatter(eventcountOFF(:,1), eventcountOFF(:,2), 'r', '*')
hold on
plot(eventcountOFF(:,1), eventcountOFF(:,2), 'r')
hold on
scatter(eventcountON(:,1), eventcountON(:,2), 'K')
hold on
plot(eventcountON(:,1), eventcountON(:,2), 'K')
xlabel('Segment Number')
ylabel('# of Events')
hold on

figure(6)
title('Events / s')
scatter(EPSOFF(:,1), EPSOFF(:,2), 'r')
hold on
plot(EPSOFF(:,1), EPSOFF(:,2), 'r')
hold on
scatter(EPSON(:,1), EPSON(:,2), 'K')
hold on
plot(EPSON(:,1), EPSON(:,2), 'K')
xlabel('Segment Number')
ylabel('Events per second')
hold on

figure(11)
title('VOR')
scatter(VOROFF(:,1), VOROFF(:,2), 'r')
hold on
plot(VOROFF(:,1), VOROFF(:,2), 'r')
hold on
scatter(VORON(:,1), VORON(:,2), 'K')
hold on
plot(VORON(:,1), VORON(:,2), 'K')
xlabel('Segment Number')
ylabel('eyeHGain')
hold on
