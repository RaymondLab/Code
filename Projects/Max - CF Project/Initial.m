%% Combine Motor & Ephys Files into a Spike2 .smr

%% Reset Everything
clear;clc;close all


%% Setup
% Location of Lisberger Data
%directory = dir('C:\Users\maxga\Desktop\D1_1995');
directory = dir('C:\Users\maxwellg\Desktop\testing');

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
            
            % Extract recording Data
            beh = opensingleMAXEDIT(fullFileName, 1, EfullfileName);
            
            % Plot Everything
            figure(1); clf
            ha = tight_subplot(8,1,[.03 .03],[.03 .03],[.03 .03]);
            
            for q = 1:8
                
                axes(ha(q))
                
                % Get Samplerate
                fs = beh(q).samplerate;

                % Get Time Vector
                timeVec = beh(q).tstart:(1/fs):beh(q).tend;
 
                % Plot 
                plot(timeVec, beh(q).data)
                title(beh(q).chanlabel)
                               
                % only show Tick labels on 6
                if q ~= 8
                    xlimMax = max(timeVec);
                    xticks([]);
                    xticklabels([]);
                else
                    vline(beh(end-1).data(1:20));
                end
            end
            
            linkaxes(ha, 'x')
            disp(length(beh(8).data) / length(beh(1).data))
            disp('a')      
            
        end
        clc
        
    end
end

%% Testing with Hannah's Script
testFile = 'C:\Users\maxga\Desktop\D1_1995\da0301\da0301.0000';


