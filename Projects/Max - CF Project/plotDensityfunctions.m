%% Set up
clear;clc; close all; fclose('all');

expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Initial Data for testing';
Files = dir([expmtDataFolder '\**\*']);


%% Filters
Files(~contains({Files.name}, {'behavior.mat'})) = [];

for i = 1:length(Files)
    
    filename = fullfile(Files(i).folder, Files(i).name);
    
    try
        load(filename, 'behaviorData');
        spikeTimes = behaviorData(8).data;
    
        A = plotSpikeDensityfunction(spikeTimes, .06);
    catch
        disp('failed')
    end
    
end
