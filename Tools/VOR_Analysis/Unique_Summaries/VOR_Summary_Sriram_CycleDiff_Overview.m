%% Sriram Summary OKR BETWEEN ANIMALS

%% Load File
clear;clc;

try 
    load('diffData.mat')
    T = readtable('diffData.xlsx');
catch
    warning('No diffData File Found!')
    return
end

color = T.color;
conditions = unique(T.condition);

%% For Each Condition
for i = 1:length(conditions)
    
    A = figure(i);clf
    
    % For Each Mouse
    for j = 1:length(diffData)
        
        % only plot the ones user wants
        if diffData(j).keep && contains(diffData(j).condition, conditions{i})
            
            % replace the color
            diffData(j).color = color(j);
            
            %% Plot raw signal
            subplot(2,1,1)
            plot(diffData(j).ttCycle, diffData(j).diffRaw, color{j}); hold on
            
            % Find and save Maximum data 
            [maxVal, maxLoc] = max(diffData(j).diffRaw);
            maxLoc = maxLoc/length(diffData(j).diffRaw);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
            diffData(j).rawMaxVal = maxVal;
            diffData(j).rawMaxLoc = maxLoc;
            
            %% Plot Fit Signal
            subplot(2,1,2)
            plot(diffData(j).ttCycle, diffData(j).diffFit, color{j}); hold on
            
            % Find and Save maximum data
            [maxVal, maxLoc] = max(diffData(j).diffFit);
            maxLoc = maxLoc/length(diffData(j).diffFit);
            line([maxLoc maxLoc], [0 maxVal], 'color', color{j}, 'lineStyle', '--');
            scatter(maxLoc, maxVal, color{j}, 'filled')
            
            diffData(j).fitMaxVal = maxVal;
            diffData(j).fitMaxLoc = maxLoc;
            
        end
    end
    
    %% Final plot touch ups
    subplot(2,1,1)
    hline(0, ':k')
    ylim([-30, 30])
    title([diffData(1).condition, ' Raw'])

    subplot(2,1,2)
    hline(0, ':k')
    ylim([-30, 30])
    title([diffData(1).condition, ' Fit'])
    xlabel('Seconds')

    %% Save as Fig and Pdf
    print(A,fullfile(cd, [conditions{i} 'Sriram_OKR_Overview']),'-fillpage', '-dpdf', '-r300');
    savefig(A,fullfile(cd, [conditions{i} 'Sriram_OKR_Overview.fig']));
  
end

%% Write information to Excel File

% Everything except data vectors go in first sheet
excelVec = diffData;
for k = 1:length(excelVec)
    excelVec(k).diffRaw = [];
    excelVec(k).diffFit = [];
    excelVec(k).ttCycle = [];
end
writetable(struct2table(excelVec), 'diffData.xlsx', 'Sheet', 1);

% Extract data vectors
fitDat = [{diffData.mouse}; ...
          {diffData.condition}];

rawDat = [{diffData.mouse}; ...
          {diffData.condition}];
         
for i = 1:length(diffData)
    rawMatrix(i,:) = diffData(i).diffRaw;
    fitMatrix(i,:) = diffData(i).diffFit;
end

rawMatrix = rawMatrix';
fitMatrix = fitMatrix';

% Raw Data goes into second sheet
xlswrite('diffData.xlsx', rawDat, 2);
xlswrite('diffData.xlsx', rawMatrix, 2, 'A3')

% Fit data goes into third sheet
xlswrite('diffData.xlsx', fitDat, 3);
xlswrite('diffData.xlsx', fitMatrix, 3, 'A3')





