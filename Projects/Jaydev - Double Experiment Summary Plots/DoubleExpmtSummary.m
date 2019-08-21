%% Prompt User for Variables
clear;clc;close all
warning off
prompt = {'Path: ', 'R^2 Threshold: ', 'Block Number: ', 'Removed Data Percentage: ', 'Gain Type (1 = norm, 2 = raw}'};
dlgTitle = "Input: ";
dims = [1 35];
definput = {'G:\My Drive\Expmt Data\2019_08_19 - Jaydev Double Experiments', ...
            '1', ...
            '5', ...
            '100', ...
            '1'};

answer = inputdlg(prompt, dlgTitle, dims, definput);

%% Find Correct data
disp(['Data Location:   ', answer{1}])
excels = dir([answer{1} '\**\*.xlsx']);

% Remove Templates
excels(~contains({excels.name}, {'Exp-D'}), :) = [];

DRexcels = excels(contains({excels.name}, {'Dark Resting'}), :);
excels(contains({excels.name}, {'Dark Resting'}), :) = [];

GDGUexcels = excels(contains({excels.name}, {'1 Hz Gain Down'}), :);
excels(contains({excels.name}, {'1 Hz Gain Down'}), :) = [];

VESTexcels = excels(contains({excels.name}, {'Vestibular'}), :);
excels(contains({excels.name}, {'Vestibular'}), :) = [];

GUexcels = excels;

for i = 1:4
    
    switch i
        case 1
            mList = DRexcels;
            Label = 'Dark Resting';
            disp([Label, '...'])
        case 2
            mList = VESTexcels;
            Label = 'Vestibular';
            disp([Label, '...'])
        case 3
            mList = GDGUexcels;
            Label = 'Gain Down & Gain Up ';
            disp([Label, '...'])
        case 4
            mList = GUexcels;
            Label = 'Gain Up';
            disp([Label, '...'])
    end
    
    
    figure()
    
    for j = 1:length(mList)
        
        dataTable = readtable(fullfile(mList(j).folder, mList(j).name));
        
        % Gather relevant data
        plotSegs = ~logical(sum(dataTable.TimePoint == [5, 15, 25, 35, 45, 55], 2));
        
        Gains = dataTable.eyeHgain(plotSegs);
        Rsquare = dataTable.rsquare(plotSegs);
        sacFrac = dataTable.saccadeFrac(plotSegs);
        TimePoints = dataTable.TimePoint(plotSegs);
        
        % Baseline Averages
        meanGain_Baseline = sum(Gains(1:3) .* (1-sacFrac(1:3))) / sum(1-sacFrac(1:3));
        meanRsquare_Baseline = sum(Rsquare(1:3) .* (1-sacFrac(1:3))) / sum(1-sacFrac(1:3));
        
        % Middle Averages
        meanGain_Mid = sum(Gains(6:8) .* (1-sacFrac(6:8))) / sum(1-sacFrac(6:8));
        meanRsquare_Mid = sum(Rsquare(6:8) .* (1-sacFrac(6:8))) / sum(1-sacFrac(6:8));
        
        % End Averages
        if length(Gains) > 11
            meanGain_End = sum(Gains(11:13) .* (1-sacFrac(11:13))) / sum(1-sacFrac(11:13));
            meanRsquare_End = sum(Rsquare(11:13) .* (1-sacFrac(11:13))) / sum(1-sacFrac(11:13));
            
            % Combine (for long expmt)
            Gains = [Gains(1:3); meanGain_Baseline; Gains(4:8); meanGain_Mid; Gains(9:end); meanGain_End];
            Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:8); meanRsquare_Mid; Rsquare(9:end); meanRsquare_End];
        else
            % Combine (for short expmt)
            Gains = [Gains(1:3); meanGain_Baseline; Gains(4:8); meanGain_Mid];
            Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:8); meanRsquare_Mid];
        end
        
        % todo Filter out experiments based on inputs
        if meanRsquare_Baseline < str2double(answer{2})
            Gains(:) = NaN;
        end
        
        % Rel Gain
        if answer{5} == '1'
            Gains = Gains ./ meanGain_Baseline;
        end
        
        % Plot 
        segAmt = length(Gains);
        %c = linspace(1,10,height(dataTable));
        
        plot(1:segAmt, Gains); hold on
        scatter(1:segAmt, Gains, 5, 'k', 'filled'); hold on
        xticks(1:segAmt)
        xticklabels({'0', '0', '0', 'BL', '10', '20', '30', '30', '30', 'Mid', '40', '50', '60', '60', '60', 'End'})
    end
    
    title(Label)
    if answer{5} == '1'
        ylabel('Normalized Gain')
        ylim([.4 2.5])
    else
        ylabel('Raw Gain')
        ylim([0, 1.75])
    end
    xlabel('tmpts')
    box off
end

disp('Done!')