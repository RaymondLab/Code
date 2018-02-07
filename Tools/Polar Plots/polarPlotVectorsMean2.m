%% open up csv file containin the gain and phase

try
    pathname = cd;
    [~, filenameroot] = fileparts(pathname);
    File = [filenameroot '.xlsx'];
    [~, ~, array] = xlsread(File);
catch
    File = uigetfile('*.*');
    [~, ~, array] = xlsread(File);
    fprintf('Excel file not automatically found, please manually select file')
end

rLimits = [0, .3];
aa = figure()
lineW = 3;

% Find eyeHgain column
[gainX gainY] = find(strcmp(array, 'eyeHgain'));

% Find eyeHphase column
[phaseX phaseY] = find(strcmp(array, 'eyeHphase'));

% gather t=0 information
phaseT0Mean = mean(cell2mat(array(2:4, phaseY)));
gainT0Mean = mean(cell2mat(array(2:4, gainY)));

% gather t=30 information
phaseT30Mean = mean(cell2mat(array(16:18, phaseY)));
gainT30Mean = mean(cell2mat(array(16:18, gainY)));

% phase difference (original analysis)
phaseDiffPHASE = cell2mat(array(20, phaseY));
phaseDiffGAIN = cell2mat(array(20, gainY));

% phase subtraction (new analysis)
phaseSubPHASE = cell2mat(array(21, phaseY));
phaseSubGAIN = cell2mat(array(21, gainY));

% convert phase to radians
phaseT0Rad = deg2rad(phaseT0Mean);
phaseT30Rad = deg2rad(phaseT30Mean);
phaseDiffRad = deg2rad(phaseDiffPHASE);
phaseSubRad = deg2rad(phaseSubPHASE);

%% plot

T0 = polarplot([0 phaseT0Rad], [0 gainT0Mean], 'color', 'b', 'lineWidth', lineW);
hold on
T30 = polarplot([0 phaseT30Rad], [0 gainT30Mean], 'color', 'r', 'lineWidth', lineW);
PhaseSubtraction  = polarplot([0 phaseSubRad], [0 phaseSubGAIN], 'color', 'k', 'lineWidth', lineW);
PhaseDifference = polarplot([0 phaseDiffRad], [0 phaseDiffGAIN], 'color', 'g', 'lineWidth', lineW);
rlim(rLimits)

% add legend
legend([T0, T30, PhaseSubtraction, PhaseDifference], 'Time 0 Mean', 'Time 30 Mean', 'Phase Subtraction', 'Phase Difference',  'location', 'northeast')
title('T0, T30, Phase Subtraction, and Phase Difference Phase and Gain')
