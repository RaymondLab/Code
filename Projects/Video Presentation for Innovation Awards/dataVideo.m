%% setup 
clear;clc;close all;clear sound
%C = IBWconnect('Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Firing_spike_count');
%load('march8th.mat')

sampleRateEYE = 1000;
startEYE = 2022000+ 30000;
additionEYE = 10*4;
dispLenEYE = 1000*7 - additionEYE;

sampleRateSPIKE = 50000;
ORIGINALstartSPIKE = 101100000+ 1500000;
startSPIKE = 101100000 + 1500000;
additionSPIKE = 500*4;
dispLenSPIKE = 50000*7 - additionSPIKE;
i = 1;

activateCEDS64
fhand1 = CEDS64Open('C:\Users\maxga\Downloads\20170817_JC6_ephys_cell1.smr');
[~, eyePOS, ~] = CEDS64ReadWaveF( fhand1, 6, 200000000, 0);
[~, spiking, ~] = CEDS64ReadWaveF( fhand1, 8, 200000000, 0);

%{
10,000 samples per second
For Real Time:
    200 samples Per Frame @ 50 fps
%}

%frames(1:400) = struct('cdata', zeros(1956, 3808, 3, 'uint8'), 'colormap', []);

%% Get Frames
figure()
set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf,'color',[0.6, 0.6, 0.6]);
subplot(2,1,1);

while startSPIKE+dispLenSPIKE+additionSPIKE < ORIGINALstartSPIKE + 1500000
    subplot(2,1,1);
    
    plot(spiking(startSPIKE:startSPIKE+dispLenSPIKE+additionSPIKE), 'color', [0 0.5 0])%, 'LineWidth', 1.5)
    title('Spiking')
    axis off
    ylim([-2 1])
    subplot(2,1,2);
    plot(eyePOS(startEYE:startEYE+dispLenEYE+additionEYE), 'color', [0 0.5 0])%, 'LineWidth', 1.5)
    title('Eye Position')
    ylim([1.1 1.8])
    axis off
    frames(i) = getframe(gcf);
    startSPIKE = startSPIKE + additionSPIKE;
    startEYE = startEYE + additionEYE;
    i = i + 1;
    
    %ORIGINALstartSPIKE + 1500000 - startSPIKE
end
close all
%% tweek the sound

% C_mod = ;
% C_mod = repelem(C_mod,2);
% C_mod = repelem(C_mod,2);


%% play movie
% figure()
% set(gcf,'units','normalized','outerposition',[0 0 1 1])
% axis off
% %soundsc(C_mod, 1000)
% movie(frames, 1, 100)
% close all
% clear sound

%% Export Movie
myVideo = VideoWriter('myfile2.avi');
myVideo.FrameRate = 50;
myVideo.Quality = 50;
% 
open(myVideo);
writeVideo(myVideo, frames);
close(myVideo);
fprintf('DONE')
