%% setup 
clear;clc;close all
A = fopen('Z:\1_Maxwell_Gagnon\ProjectData_Sriram\Firing_spike_count\RecordA0.txt');
C = fscanf(A, '%f');

start = 1;
dispLen = length(C) / 300;
addition = dispLen / 100;
i = 1;

%% Get Frames
while start+dispLen+addition < length(C)
    
    plot(C(start:start+dispLen+addition))
    frames(i) = getframe;
    start = start + addition;
    i = i + 1;
    (start / length(C)) * 100
end


%% play movie
figure()
movie(frames, 1, 15)