function polarPlotVectorsGender(File)
% open up csv file containin the gain and phase
[~, ~, array] = xlsread(File);
[row, col] = size(array);
rLimits = [0, .62];
myfig = figure();


% does this file contain gender information?
if col > 4
    gen = true;
else
    gen = false;
end


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
            %color = 'b';
            %lineW = 3;
            %LM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = [ 0.5843 0.8157 0.9882];
            lineW = 1.5;
        end
        
        if gen
            if isnan(array{i, 5})
                gender = '-';
                fprintf('Gender info not found in row %d\n', i)
            elseif contains(array{i, 5}, 'M')
                gender = '--';
            elseif contains(array(i, 5), 'F')
                gender = '-';
            else
                gender = '-';
                fprintf('Gender info not found in row %d\n', i)
            end
            L = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW, 'lineStyle', gender);
        else
            L = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
        
        
    % Dark Condition?
    elseif contains(array{i, 2}, 'D')
        
        % Dark Mean?
        if contains(array{i, 2}, 'mean')
            %color =  [201 22 11] ./ 255;
            %lineW = 3;
            %DM = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        else
            color = [253 207 181] ./ 255;
            lineW = 1.5;
        end
        
        if gen
            if isnan(array{i, 5})
                gender = '-';
                fprintf('Gender info not found in row %d\n', i)
            elseif contains(array{i, 5}, 'M')
                gender = '--';
            elseif contains(array(i, 5), 'F')
                gender = '-';
            else
                gender = '-';
                fprintf('Gender info not found in row %d\n', i)
            end
            D = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW, 'lineStyle', gender);
        else
            D = polarplot([0 phaseRad], [0 gain], 'color', color, 'lineWidth', lineW);
        end
        
    end
    hold on
end

rlim(rLimits)
hold on

% add legend
%legend([L, LM, D, DM], 'Light Reared', 'Light Reared Mean', 'Dark Reared', 'Dark Reared Mean', 'location', 'northeast')
legend([L, D], 'Light Reared', 'Dark Reared', 'location', 'northeast')


% let the user know if there was gender information in the file
if gen
    str = 'Female: Solid    Male: Dashed';
else
    str = 'There is no gender information';
end
dim = [.2 .5 .3 .3];
annotation('textbox',dim,'String',str,'FitBoxToText','on');


