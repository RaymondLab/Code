function vars = calc_linearity_APP (vars)
%% load data
disp('Calculating Alignment Based on highest Linearity...')
loadAnalysisInfo_APP;

%% Calculate r2 values With Various Alignment Values
% Magnet Channel 1 Position
try
    [mag1.pos_linearity_r2, mag1.pos_linearity_maxr2, mag1.pos_linearity_maxr2Loc] = ...
        linearityAlign(mag1.pos_data, vid.pos_data_upsampled);
catch
end

% Magnet Channel 1 Velocity
try
    [mag1.vel_linearity_r2, mag1.vel_linearity_maxr2, mag1.vel_linearity_maxr2Loc] = ...
        linearityAlign(mag1.vel_data, vid.vel_data_upsampled);
catch
end

% Magnet Channel 2 Position
try
    [mag2.pos_linearity_r2, mag2.pos_linearity_maxr2, mag2.pos_linearity_maxr2Loc] = ...
        linearityAlign(mag2.pos_data, vid.pos_data_upsampled); 
catch
end

% Magnet Channel 2 Velocity
try
    [mag2.vel_linearity_r2, mag2.vel_linearity_maxr2, mag2.vel_linearity_maxr2Loc] = ...
        linearityAlign(mag2.vel_data, vid.vel_data_upsampled);
catch
end

%% save data
saveAnalysisInfo_APP;
