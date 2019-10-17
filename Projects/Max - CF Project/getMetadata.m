%% Set up
clear;clc; close all
A = chanData;

A.expmtDataFolder = 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\Jennifer Data\jennifer_arch';

A.bFiles = dir([A.expmtDataFolder '\**\*']);
eFiles = A.bFiles(contains({A.bFiles.name}, {'ephys.mat'}));

A.bFiles([A.bFiles.isdir]) = [];
A.bFiles(~contains({A.bFiles.name}, {'.'})) = [];
A.bFiles(contains({A.bFiles.name}, {'.dat'})) = [];
A.bFiles(contains({A.bFiles.name}, {'.mat'})) = [];
A.bFiles(contains({A.bFiles.name}, {'.ini'})) = [];
A.bFiles(contains({A.bFiles.name}, {'du'})) = [];
A.bFiles(contains({A.bFiles.name}, {'eu'})) = [];
files = A.bFiles;

%% Create Table
name        = cell(length(files),1);
behaviorMat = cell(length(files),1);
ephysMat    = cell(length(files),1);
alignedMat  = cell(length(files),1);
sineStep    = cell(length(files),1);

alignVal    = nan(length(files),1);
freq        = nan(length(files),1);
sineConfidence = nan(length(files),1);

%% Double Check Loop

for j = 1:length(files)
    tic
    disp(j)
    
    
    %% name
    name{j} = files(j).name;
    disp(name{j})
    
    
    %% behaviorMat
    behaviorMatName = [strrep(files(j).name, '.', '_'), 'behavior.mat'];
    behExits = 0;
    if exist(fullfile(files(j).folder, behaviorMatName), 'file')
        behaviorMat{j} = behaviorMatName;
        behExists = 1;
    else
        toc
        continue
    end
    

    %% ephysMat
    ephysMatName = [strrep(files(j).name, '.', '_'), 'ephys.mat'];
    ephysFile = eFiles(contains({eFiles.name}, {ephysMatName}));
    if ~isempty(ephysFile)
        ephysMat{j} = ephysMatName;
    end


    %% alignedMat
    alignedMatName = [strrep(name{j}, '.', '_'), 'aligned.mat'];
    alignValExists = 0;
    if exist(fullfile(files(j).folder, alignedMatName), 'file')
        alignedMat{j} = alignedMatName;
        alignValExists = 1;
    end
    
    
    %% AlignVal
    if alignValExists
        try
            load(fullfile(files(j).folder, alignedMat{j}))
            alignVal(j) = behaviorEphysAligned(1,10).tstart;
        catch
        end
    end


    %% Stim Type & Freq
    if behExists
        try
            load(fullfile(files(j).folder, behaviorMat{j}))

            % just an estimation
            freq(j) = findExpmtFreq(behaviorData);

            % need freq estimation for finding sine/step
            [sineStep{j}, sineConfidence(j)] = findSineStep(behaviorData, freq(j));

            % overwrite freq if not sine
            if ~contains(sineStep{j}, 'sine')
                freq(j) = nan;
            end

        catch
        end
    end
    
    %%
    toc

end


%% Combine, Create and Save the Table
T = table(name, behaviorMat, ephysMat, alignedMat, alignVal, sineStep, sineConfidence, freq);
writetable(T, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata.xlsx')


%% Helpful functions
function peakFreqEstimate = findExpmtFreq(datObj)

    maxFreqLoc = [0,0,0,0,0; 0,0,0,0,0];
    
    for i = 1:7
        if isempty(datObj(i).data)
            continue
        end

        L = length(datObj(i).data);
        Y = fft(datObj(i).data);
        P2 = abs(Y/L);
        P1 = P2(1:floor(L/2+1));
        P1(2:end-1) = 2*P1(2:end-1);
        f = datObj(i).samplerate*(0:(L/2))/L;

        if sum(P1 == max(P1)) == 1
            maxFreqLoc(1, i) = f(P1 == max(P1));
            maxFreqLoc(2, i) = max(P1);
        end
    end
    
    peakFreqEstimate = maxFreqLoc(1,maxFreqLoc(2,:) == max(maxFreqLoc(2,:)));
    peakFreqEstimate = round(peakFreqEstimate * 2)/2;
    
end

function [stimType, maxr2] = findSineStep(datObj,freq)
    warning off
    r2 = nan(2,1);
    
    for i = [4, 5]
        if isempty(datObj(i).data)
            continue
        end
        timeVec = dattime(datObj(i));
        y1 = sin(2*pi*freq*timeVec);
        y2 = cos(2*pi*freq*timeVec);
        const = ones(size(y1));
        vars = [y1 y2 const];
        [~,~,~,~,stat] = regress(datObj(i).data, vars);
        %Amp = sqrt(b(1)^2+b(2)^2);
        r2(i) = stat(1);
    end
    maxr2 = max(r2);
    
    if maxr2 > .1
        stimType = 'sine';
    elseif maxr2 == 0
        stimType = [];
    else
        stimType = 'step';
    end
    
    %disp(maxr2)
    %disp(stimType)
     
    %figure(43); clf
    %plot(datObj(4).data); hold on
    %plot(datObj(5).data)
    
    if maxr2 > .1 && maxr2 < .7
        %disp(max(r2))
    end

end