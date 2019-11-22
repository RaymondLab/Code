%{
Maxwell Gagnon - September 2019
- This function finds all BEHAVIOR Maestro files in a directory, opens them, and saves
them as a .mat file.
- .mat files are easier to work with than the BEHAVIOR Maestro files.
%}

%% Set up
clear;clc; close all; fclose('all');

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch\Jennifer_Arch';
Files = dir([expmtDataFolder '\**\*']);

samplerate = 500;
chanAmt = 6;

%% Filters
% Remove directories
Files([Files.isdir]) = [];
% Remove zip files
Files(contains({Files.name}, {'.zip'})) = [];
% Remove mat files
Files(contains({Files.name}, {'.mat'})) = [];
% Remove non-behavior files - only works for Jenifer's data
Files(~contains({Files.name}, {'el'})) = [];
% Remove files that typically don't work
%Files(~contains({Files.name}, {'.0'})) = [];
Files(contains({Files.name}, {'VORC'})) = [];
Files(contains({Files.name}, {'sines'})) = [];
Files(contains({Files.folder}, {'backup'})) = [];

%% name length check
tic
for j = length(Files):-1:1
    if strlength(Files(j).name) ~= 11
        Files(j) = [];
    end
end
toc

%% Find, open, rename, and save behavior files
for i = 1:length(Files)
    
    disp(['(', num2str(i), '/', num2str(length(Files)), ')'])
    disp(['     ', Files(i).name]);
    try
        % Open the BEHAVIOR Maestro file (the ephys file)
        filename = fullfile(Files(i).folder, Files(i).name);
        
        behaviorData = cx2dat(filename, chanAmt);
        if isempty(behaviorData)
            continue
        end
        
        if ~isempty(behaviorData(1,9).data)
            disp('Contains Sorted CS')
        end
        % Rename
        newName = [strrep(Files(i).name, '.', '_') 'behavior.mat'];

        % Save as a .mat with a single varibale inside of it
        disp(['     ', fullfile(Files(i).folder, newName)])
        save(fullfile(Files(i).folder, newName), 'behaviorData')
    catch
        disp(filename)
        disp('Oops!')
    end
    fclose('all');
end
