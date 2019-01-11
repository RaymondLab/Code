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
    
    % Light before condition?
    if contains(array{i, 2}, 'LB')
        
        % Light Mean?
        if contains(array{i, 2}, 'mean')
            color = 'r';
            lineW = 3;
            LM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = 'b';
            lineW = 1.5;
            L = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
    end
    
          % Light after condition?
    if contains(array{i, 2}, 'LA')
        
        % Light Mean?
        if contains(array{i, 2}, 'mean')
            color = 'r';
            lineW = 3;
            LM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = 'm';
            lineW = 1.5;
            L = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
        
         % Dark before Condition?
    elseif contains(array{i, 2}, 'DB')
        
        % Dark Mean?
        if contains(array{i, 2}, 'mean')
            color =  'r';
            lineW = 3;
            DM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = 'k';
            lineW = 1.5;
            D = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
        
    % Dark after Condition?
    elseif contains(array{i, 2}, 'DA')
        
        % Dark Mean?
        if contains(array{i, 2}, 'mean')
            color =  [201 22 11] ./ 255;
            lineW = 3;
            DM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = 'g';
            lineW = 1.5;
            D = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
    end
    hold on
end

rlim(rLimits)
hold on

% add legend
legend([LB, LA, DB, DA], 'Normal reared - Before', 'Normal reared - After', 'Dark Reared - Before', 'Dark Reared - After', 'location', 'northeast')
end





