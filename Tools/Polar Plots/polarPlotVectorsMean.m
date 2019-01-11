function polarPlotVectorsMean(File)
% open up csv file containin the gain and phase
[~, ~, array] = xlsread(File);
[row, ~] = size(array);
rLimits = [0, .62];
myfig = figure();

% cycle through each entry and plot them on one
% polar figure
for i = 1:row
    
    % get Title ( optional)
    % theTitle = vals(((i-1) * 4) + 1);
    
    % get Gain
    gain =  array{i, 3};
    
    % get Phase & convert to radians
    phaseDeg = array{i, 4};
    phaseRad = deg2rad(phaseDeg);
    
    % Light condition?
    if contains(array{i, 2}, 'L')
        
        % Light Mean?
        if contains(array{i, 2}, 'mean')
            color = 'b';
            lineW = 3;
            LM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = [ 0.5843 0.8157 0.9882];
            lineW = 1.5;
            L = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
        
    % Dark Condition?
    elseif contains(array{i, 2}, 'D')
        
        % Dark Mean?
        if contains(array{i, 2}, 'mean')
            color =  [201 22 11] ./ 255;
            lineW = 3;
            DM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = [253 207 181] ./ 255;
            lineW = 1.5;
            D = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
    end
    hold on
end

rlim(rLimits)
hold on

% add legend
legend([L, D], 'Normal Reared', 'Dark Reared', 'location', 'northeast')




