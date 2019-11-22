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

expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch\Jennifer_Arch';
Files = dir([expmtDataFolder '\**\*']);

%% Filters
% Remove directories
Files([Files.isdir]) = [];
Files(contains({Files.folder}, {'backup'})) = [];

%Files(strlength(Files.name) ~= 10) = [];
tic
for j = length(Files):-1:1
    if strlength(Files(j).name) ~= 10
        Files(j) = [];
    end
end
toc

% Remove zip files
%Files(contains({Files.name}, {'.zip'})) = [];
% Remove non-ephys files - only works for Jenifer's data
%Files(~contains({Files.name}, {'du'})) = [];

%% Find, open, rename, and save ephys files
for i = 1:length(Files)
    
    disp(['(', num2str(i), '/', num2str(length(Files)), ')'])
    try
        % Open the Maestro file (the ephys file)
        ephysData = openmaestro(fullfile(Files(i).folder, Files(i).name));
        
        % Plot
%            figure(1);clf
%            plot(ephysData)
%            title(Files(i).name)
           %xlim([0 50000])
        
        % Rename
        newName = [strrep(Files(i).name, '.', '_0') 'ephys.mat'];
        if contains(newName, 'du')
            newName = strrep(newName, 'du', 'da');
        elseif contains(newName, 'eu')
            newName = strrep(newName, 'eu', 'el');
        end
        
        
        % Save as a .mat with a single varibale inside of it
        disp(fullfile(Files(i).folder, newName))
        save(fullfile(Files(i).folder, newName), 'ephysData')
    end
    fclose('all');
end
