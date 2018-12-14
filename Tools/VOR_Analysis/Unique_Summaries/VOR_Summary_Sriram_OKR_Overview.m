%% Sriram Summary OKR BETWEEN ANIMALS

%% Load File
clear;clc;
try 
    load('diffData.mat')
catch
    warning('No Difference diffData File Found!')
end

T = readtable('diffData.xlsx');
color = T.color;
conditions = unique(T.condition);

%% Plot Each Condition
for i = 1:length(conditions)
    
    A = figure(i);clf
    
    % For each Mouse
    for j = 1:length(diffData)
        
        % only plot the ones user wants
        if diffData(j).keep && contains(diffData(j).condition, conditions{i})
            
            % replace the color
            diffData(j).color = color(j);
            
            subplot(2,1,1)
            plot(diffData(j).ttCycle, diffData(j).diffRaw, color{j}); hold on
            
            [maxVal, maxLoc] = max(diffData(j).diffRaw);
            maxLoc = maxLoc/length(diffData(j).diffRaw);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
            subplot(2,1,2)
            plot(diffData(j).ttCycle, diffData(j).diffFit, color{j}); hold on
            
            [maxVal, maxLoc] = max(diffData(j).diffFit);
            maxLoc = maxLoc/length(diffData(j).diffFit);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
            
            
            
            
        end
    end
    
     subplot(2,1,1)
     hline(0, ':k')
     ylim([-30, 30])
     title([diffData(1).condition, ' Raw'])
                              
     subplot(2,1,2)
     hline(0, ':k')
     ylim([-30, 30])
     title([diffData(1).condition, ' Fit'])
     
     xlabel('Seconds')
    
     
end


