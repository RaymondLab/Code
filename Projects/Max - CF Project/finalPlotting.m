%% Setup
clear;clc;close all
[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_B.xlsx');
expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\*']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];

%% Choose Parameters and filter 
stimType        = 'sine'; % sine, step
expmtFreq       = .5;
learningType    = 'x2'; % VOR, OKR, x0, x2

tempTable = dataTable;

tempTable(~contains(tempTable.sineStep, {stimType}),:) = [];
tempTable(~(tempTable.freq == expmtFreq),:) = [];
tempTable(~contains(tempTable.learningType, {learningType}),:) = [];

disp(['Files Found: ', num2str(height(tempTable))]);

%% Set up figure
 allFiles(~contains({allFiles.name}, {'aligned'})) = [];


%% Prep data
for i = 1:height(tempTable)
    renamedFile = strrep(tempTable.name{i}, '.', '_');
    expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
    fullFileName = fullfile(expmtRow.folder, expmtRow.name);
    load(fullFileName)
end