%% Misc Calibration code

clear;clc;close all

expmtDataFolder = 'G:\My Drive\Expmt Data\Amin\LTD Project Final Raw Data';
allFiles = dir([expmtDataFolder, '\**\*.mat']);

allFiles(contains({allFiles.name}, {'settings'})) = [];
allFiles(contains({allFiles.name}, {'time'})) = [];
allFiles(contains({allFiles.name}, {'videoresults'})) = [];
allFiles(contains({allFiles.name}, {'result'})) = [];
allFiles(contains({allFiles.name}, {'manual_calib'})) = [];

%% 
for i = 1:size(allFiles,1)
    filePath = fullfile(allFiles(i).folder, allFiles(i).name);
    cd(allFiles(i).folder);
    load(filePath)
    disp('apple')
    save(fullfile(cd, [allFiles(i).name(1:end-4) '_Original.mat']), ...
    'scaleCh1', 'scaleCh2',...
    'vidAmp',...
    'mag1Amp','mag1Phase',...
    'mag2Amp','mag2Phase',...
    'r2mag1','r2mag2','r2vid',...
    'magthresh','vidthresh', ...
    'freq');
end


%% 

copyfile('2019_10_11_1_cali_10deg.mat')
