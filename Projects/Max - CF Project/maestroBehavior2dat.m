%{
Maxwell Gagnon - September 2019
- This function finds all BEHAVIOR Maestro files in a directory, opens them, and saves
them as a .mat file.
- .mat files are easier to work with than the BEHAVIOR Maestro files.
%}

%% Set up
clear;clc; close all; fclose('all');

expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Initial Data for testing';
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
Files(~contains({Files.name}, {'da'})) = [];
% Remove files that typically don't work
%Files(~contains({Files.name}, {'.0'})) = [];
Files(contains({Files.name}, {'VORC'})) = [];
Files(contains({Files.name}, {'sines'})) = [];


%% Find, open, rename, and save behavior files
for i = 1:length(Files)
    
    disp(['(', num2str(i), '/', num2str(length(Files)), ')'])
    try
        % Open the BEHAVIOR Maestro file (the ephys file)
        filename = fullfile(Files(i).folder, Files(i).name);
        
        behaviorData = cx2dat(filename, chanAmt);
        if isempty(behaviorData)
            continue
        end
        
        % Rename
        newName = [strrep(Files(i).name, '.', '_') 'behavior.mat'];

        % Save as a .mat with a single varibale inside of it
        disp(fullfile(Files(i).folder, newName))
        save(fullfile(Files(i).folder, newName), 'behaviorData')
    catch
        disp(filename)
        disp('Oops!')
    end
    fclose('all');
end
