%% Combine Motor & Ephys Files into a Spike2 .smr

%% Reset Everything
clear;clc;close all


%% Setup
% Location of Lisberger Data
directory = dir('C:\Users\maxga\Desktop\D1_1995');

% Seperate the folders into motor recordings and ephys recordings
motorFolders = directory(contains({directory(:).name}, 'da'));
ephysFolders = directory(contains({directory(:).name}, 'du'));

%% Match the corresponding ephys folders with thier motor folders
matchMotors = [];
matchEphys = [];

for i = 1:length(motorFolders)
    for j = 1:length(ephysFolders)
        if contains(motorFolders(i).name(~isletter(motorFolders(i).name)), ephysFolders(j).name(~isletter(ephysFolders(j).name)))
            matchMotors = [matchMotors; fullfile(motorFolders(i).folder, motorFolders(i).name)];
            matchEphys = [matchEphys; fullfile(ephysFolders(j).folder, ephysFolders(j).name)];
            %disp('Apple')
        end
    end
end

%% Parameters from Hannah's "opensingle.m"
dt = .002;

%% Plot each file in each folder
for i = 1:length(matchMotors)
    files = dir(matchMotors(i,:));
    Efiles = dir(matchEphys(i,:));
    for j = 1:length(files) 
        fullFileName = fullfile(files(j).folder, files(j).name)
        EfullfileName = fullfile(Efiles(j).folder, Efiles(j).name)
        if ~contains(fullFileName, '\.')
            behavior = readcxdata(fullFileName, 0, 6);
            ephys = openmaestro(EfullfileName);
            
            % Using Parameters from Hannah's "opensingle.m"
            figure(1)
            
            subplot(4,2,1)
            plot(behavior.data(1,:)*12.5 * dt)
            title('hgpos')
            
            subplot(4,2,2)
            plot(behavior.data(2,:)*12.5 * dt)
            title('vepos')
            
            subplot(4,2,3)
            plot(behavior.data(3,:)*0.09189)  
            title('hevel 25Hz')
            
            subplot(4,2,4)
            plot(behavior.data(4,:)*12.5 * dt)
            title('htpos')
            
            subplot(4,2,5)
            plot(behavior.data(5,:)*0.09189 * 1.15)
            title('hhvel')
            
            subplot(4,2,6)
            plot(behavior.data(6,:)*0.09189 * 3.1805)
            title('hevel 100Hz')
            
            subplot(4,2,7)
            plot(ephys)
            title('ephys')
            disp('a')
        end
    end
end

