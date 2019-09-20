% Vertical Investigation for calibration issues


%% Open Files
file = 'G:\My Drive\Expmt Data\2019_09 - Kiah Calibration\Calibrations Modified';

fileInfo = dir([file '/*/*videoresults.mat']);

for i = 1:length(fileInfo)
    cd(fileInfo(i).folder);
    findmagscaleVel
    
end




%% Plot x and y values of video 