%{
Maxwell Gagnon - September 2019
- This function finds all Maestro files in a directory, opens them, and saves
them as a .mat file. 
- .mat files are easier to work with than the Maestro files. 
- The .mat files are also renamed to be more similiar to their behavior
recording file counterparts. 
%}

%% Set up
clear;clc;

expmtDataFolder = 'D:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
Files = dir([expmtDataFolder '\**\*']);

%% Filters
% Remove directories
Files([Files.isdir]) = [];
% Remove zip files
Files(contains({Files.name}, {'.zip'})) = [];
% Remove non-ephys files - only works for Jenifer's data
Files(~contains({Files.name}, {'du'})) = [];

%% Find, open, rename, and save ephys files
for i = 1:length(Files)
    
   disp(['(', num2str(i), '/', num2str(length(Files)), ')'])
   
   % Open the Maestro file (the ephys file)
   ephysData = openmaestro(fullfile(Files(i).folder, Files(i).name));

   % Plot 
%    figure(1);clf
%    plot(ephysData)
%    title(Files(i).name)
%    xlim([0 50000])

   % Rename
   newName = [strrep(Files(i).name, '.', '_0') 'ephys.mat'];
   newName = strrep(newName, 'du', 'da');

   % Save as a .mat with a single varibale inside of it
   disp(fullfile(Files(i).folder, newName))
   save(fullfile(Files(i).folder, newName), 'ephysData')
   fclose('all');
end
