%% Sriram Summary OKR BETWEEN ANIMALS

%% Load File
clear;clc;
try 
    load('diffData.mat')
catch
    warning('No Difference Data File Found!')
end

T = readtable('diffData.xlsx');

conditionAmt = unique(T.condition);

%% plot each condition
for i = 1:length(conditionAmt)
    currentCond = contains({diffData.condition}, conditionAmt{i});
    subT = diffData(currentCond);
    color = T(currentCond,:).color;
    A = figure(i);clf
    
    
    for j = 1:length(subT)
        
        % only plot the ones user wants
        if subT(j).keep
            
            subplot(2,1,1)
            % TODO Color choice
            plot(subT(j).ttCycle, subT(j).diffRaw, color{j}); hold on
            
            [maxVal, maxLoc] = max(subT(j).diffRaw);
            maxLoc = maxLoc/length(subT(j).diffRaw);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
            subplot(2,1,2)
            % TODO Color choice
            plot(subT(j).ttCycle, subT(j).diffFit, color{j}); hold on
            
            [maxVal, maxLoc] = max(subT(j).diffFit);
            maxLoc = maxLoc/length(subT(j).diffFit);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
        end
    end
    
     subplot(2,1,1)
     hline(0, ':k')
     ylim([-30, 30])
     title([subT(1).condition, ' Raw'])
                              
     subplot(2,1,2)
     hline(0, ':k')
     ylim([-30, 30])
     title([subT(1).condition, ' Fit'])
     
     xlabel('Seconds')
    
     
end


