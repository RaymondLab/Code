%% Prompt User for Variables
clear;clc;close all
warning off
prompt = {'Path: ', 'R^2 Threshold: ', 'Block Number: ', 'Removed Data Percentage: ', 'Gain Type (1 = norm, 2 = raw}'};
dlgTitle = "Input: ";
dims = [1 35];
definput = {'G:\My Drive\Expmt Data\2019_08_19 - Jaydev Double Experiments', ...
            '.5', ...
            '5', ...
            '30', ...
            '2'};

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
    
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(1,1,[.03 .03],[.05 .03],[.03 .03]);
    v = 1;
    
    for j = 1:length(mList)
        
        dataTable = readtable(fullfile(mList(j).folder, mList(j).name));
        
        % Update name for plotting ease
        newName = mList(j).name(18:19);
        if contains(mList(j).name, 'Redo')
            newName = [newName, 'r'];
        else
            newName = [newName, ' '];
        end
        mList(j).name = newName;
        sumStruct(j).name = newName;
        
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
        
        % Save gains from all experiments
        sumStruct(j).blGains = Gains(4);
        sumStruct(j).blrSquare = Rsquare(4);
        
        %% Filters
        % r squared Filter
        if meanRsquare_Baseline < str2double(answer{2})
            Gains(:) = NaN;
            sumStruct(j).removed = 1;
        else 
            sumStruct(j).removed = 0;
        end
        
        % Block % Filter
        sumStruct(j).BadSegCnt = sum(sacFrac > str2double(answer{4})/100);
        if sumStruct(j).BadSegCnt > str2double(answer{3})
            Gains(:) = NaN;
            sumStruct(j).removed = 1;    
        end
        
        %% Rel Gain or Raw Gain
        if answer{5} == '1'
            Gains = Gains ./ meanGain_Baseline;
        end
        
        %% Plot 
        segAmt = length(Gains);
        
        if isnan(Gains(1))
            plot(1:segAmt, Gains); hold on
        else
            A(v) =  plot(1:segAmt, Gains); hold on
            v = v + 1;
        end
        
        scatter(1:segAmt, Gains, 5, 'k', 'filled'); hold on
        
    end
    
    %% Universal Plot Cosmetics
    title(Label)
    if answer{5} == '1'
        ylabel('Normalized Gain')
        ylim([.4 2.5])
    else
        ylabel('Raw Gain')
        ylim([0, 1.75])
    end
    
    %xlabel('tmpts')
    box off
    xticks(1:segAmt)
    xticklabels({'0', '0', '0', 'BL', '10', '20', '30', '30', '30', 'Mid', '40', '50', '60', '60', '60', 'End'})
    xlim([.8 segAmt+.2])
    
    
    
    %% Text Marking
    % Orientation Parameters
    textGap = .0299;
    yAlign = 2.5;
    xAlignTop = 1.725;
    FontSize = 9;
    
    % Make Text Notes - Keep spacing in mind!! Not handled by matlab, so I
    % do it manually.
    
    %text(yAlign, xAlignTop-(k*textGap), '    nm     gain   r^2  BS', 'FontSize', FontSize)
    %k = k + 1;
    
    for z = 1:length(sumStruct)
        
        if ~sumStruct(z).removed
            Gstrnum = num2str(sumStruct(z).blGains);
            Rstrnum = num2str(sumStruct(z).blrSquare);
            BCstrnum = num2str(sumStruct(z).BadSegCnt);
            %text(yAlign, xAlignTop-(k*textGap), [sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum], 'FontSize', FontSize)
            LegCell(z) = {[sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum]};
            %k = k + 1;
        end
    end
    
    for z = length(LegCell):-1:1
        if isempty(LegCell{z})
            LegCell(z) = [];
        end
    end
    q = legend(A, LegCell, 'Location', 'northwest', 'FontSize', FontSize, 'Box', 'off');
    
    
    k = 0;
    text(yAlign, xAlignTop-(k*textGap), 'Removed', 'FontSize', FontSize+2)
    k = k + 1;
    text(yAlign, xAlignTop-(k*textGap), 'nm   gain   r^2       BadSegs', 'FontSize', FontSize)
    k = k + 1;
    
    for z = 1:length(sumStruct)
        if sumStruct(z).removed
            Gstrnum = num2str(sumStruct(z).blGains);
            Rstrnum = num2str(sumStruct(z).blrSquare);
            BCstrnum = num2str(sumStruct(z).BadSegCnt);
            text(yAlign, xAlignTop-(k*textGap), [sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum], 'FontSize', FontSize)
            %LegCell(z) = {[sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum]};
            k = k + 1;
        end
    end

    k = 0;
    text(yAlign+1.5, xAlignTop-(k*textGap), 'Parameters', 'FontSize', FontSize+2)
    k = k + 1;
    text(yAlign+1.5, xAlignTop-(k*textGap), ['r^2 Cutoff: ' answer{2}], 'FontSize', FontSize)
    k = k + 1;
    text(yAlign+1.5, xAlignTop-(k*textGap), ['Seg cnt Cutoff: ', answer{3}], 'FontSize', FontSize)
    k = k + 1;
    text(yAlign+1.5, xAlignTop-(k*textGap), ['Seg % Cutoff: ', answer{4}], 'FontSize', FontSize)
    
end

disp('Done!')