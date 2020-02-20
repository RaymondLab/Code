%% SETUP
clear;clc;%close all
try
    [dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
catch
    [dataTable] = readtable('D:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');
    expmtDataFolder = 'D:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\Jennifer Data Reorganized';
end

% Only keep 'Aligned Files'
allFiles = dir([expmtDataFolder, '\**\**']);
allFiles(~contains({allFiles.name}, {'aligned'})) = [];
dataTable(~contains(dataTable.alignedMat, {'aligned'}),:) = [];
all_means = [];

%% Loop through, plot each SS firing rate
for i = 1:height(dataTable)
    %% skip certain files
    if contains(dataTable.sineStep{i}, {'step'})
        continue
    end
    if ~contains(dataTable.learningType{i}, {'x2'})
        continue
    end
    try
        %% Open the File
        renamedFile = strrep(dataTable.name{i}, '.', '_');
        expmtRow = allFiles( contains({allFiles.name}, renamedFile ));
        load(fullfile(expmtRow(1).folder, expmtRow(1).name));
        recData = behaviorEphysAligned;
        
        %% Get Useful values
        freq = dataTable.freq(i);
        learningType = dataTable.learningType{i};
        
        z.sr_e = recData(10).samplerate;
        z.cycleLen_e = z.sr_e * (1/freq);
        z.cycleTime_e = 0:1/z.sr_e:(z.cycleLen_e-1)/z.sr_e;
        z.segTime_e = dattime(recData(10));
        z.startpt_e = findstartpt(recData, 10, learningType, freq);
        
        z.sr_b = recData(7).samplerate;
        z.cycleLen_b = z.sr_b * (1/freq);
        z.cycleTime_b = 0:1/500:(z.cycleLen_b-1)/500;
        z.startpt_b = findstartpt(recData, 7, learningType, freq);
        
        %% Calc RI for simple spikes
        firingRate = calc_recipInterval(recData(8).data, length(recData(10).data), z.sr_e);
        [cycleMat_ss, cycleMean_ss] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, firingRate);
        
        %% Fit sine to average
        freq = dataTable.freq(i);
        
        y1 = sin(2*pi*freq*z.cycleTime_e(:));
        y2 = cos(2*pi*freq*z.cycleTime_e(:));
        constant = ones(z.cycleLen_e,1);
        vars = [y1 y2 constant];
        
        b = regress(cycleMean_ss', vars);
        amp(i) = sqrt(b(1)^2+b(2)^2);
        angle(i) = rad2deg(atan2(b(2), b(1)));
        
        all_means = [all_means; cycleMean_ss];

    catch
        disp('error')
    end
    %% Save name, phase, and amp.
end

%% plot
figure()
polarplot(deg2rad(angle), amp, '.k')
title('Pursuit')

%% Plot all means
figure()
plot(all_means')
title('x2')
 