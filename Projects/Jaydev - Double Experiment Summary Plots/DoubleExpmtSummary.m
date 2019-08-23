%% Prompt User for Variables
clear;clc;close all
warning off
prompt = {'Path: ', 'R^2 Threshold: ', 'Block Number: ', 'Removed Data Percentage: ', 'Gain Type (1 = norm, 2 = raw}'};
dlgTitle = "Input: ";
dims = [1 35];
definput = {'D:\My Drive\Expmt Data\2019_08_19 - Jaydev Double Experiments', ...
            '.5', ...
            '5', ...
            '30', ...
            '2'};

answer = inputdlg(prompt, dlgTitle, dims, definput);
b = 1;

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

        Gains = dataTable.eyeHgain;
        Rsquare = dataTable.rsquare;
        sacFrac = dataTable.saccadeFrac;
        TimePoints = dataTable.TimePoint;

        
        bls = 1:3;
        mids = 9:11;
        ends = 17:19;
        
        % Baseline Averages
        meanGain_Baseline = sum(Gains(bls) .* (1-sacFrac(bls))) / sum(1-sacFrac(bls));
        meanRsquare_Baseline = sum(Rsquare(bls) .* (1-sacFrac(bls))) / sum(1-sacFrac(bls));
        
        % Middle Averages
        meanGain_Mid = sum(Gains(mids) .* (1-sacFrac(mids))) / sum(1-sacFrac(mids));
        meanRsquare_Mid = sum(Rsquare(mids) .* (1-sacFrac(mids))) / sum(1-sacFrac(mids));
        
        % End Averages
        if length(Gains) > 18
            meanGain_End = sum(Gains(ends) .* (1-sacFrac(ends))) / sum(1-sacFrac(ends));
            meanRsquare_End = sum(Rsquare(ends) .* (1-sacFrac(ends))) / sum(1-sacFrac(ends));
            
            % Combine (for long expmt)
            Gains = [Gains(1:3); meanGain_Baseline; Gains(4:11); meanGain_Mid; Gains(12:end); meanGain_End];
            Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:11); meanRsquare_Mid; Rsquare(12:end); meanRsquare_End];
            plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:11); 1; plotSegs(12:end); 1]);
        else
            % Combine (for short expmt)
            Gains = [Gains(1:3); meanGain_Baseline; Gains(4:11); meanGain_Mid];
            Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:11); meanRsquare_Mid];
            plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:11); 1]);
        end
        
        % Save gains from all experiments
        sumStruct(j).blGains = Gains(4);
        sumStruct(j).blrSquare = Rsquare(4);
        
       %% Save things for excel
       
        name{b} = sumStruct(j).name;
        expmtType{b}  = Label;

        t0a_rawGain(b) = Gains(1);
        t0b_rawGain(b) = Gains(2);
        t0c_rawGain(b) = Gains(3);
        tbl_rawGain(b) = Gains(4);
        t5_rawGain(b)  = Gains(5);
        t10_rawGain(b) = Gains(6);
        t15_rawGain(b) = Gains(7);
        t20_rawGain(b) = Gains(8);
        t25_rawGain(b) = Gains(9);
        t30a_rawGain(b) = Gains(10);
        t30b_rawGain(b) = Gains(11);
        t30c_rawGain(b) = Gains(12);
        tmid_rawGain(b) = Gains(13);
        try
            t35_rawGain(b) = Gains(14);
            t40_rawGain(b) = Gains(15);
            t45_rawGain(b) = Gains(16);
            t50_rawGain(b) = Gains(17);
            t55_rawGain(b) = Gains(18);
            t60a_rawGain(b) = Gains(19);
            t60b_rawGain(b) = Gains(20);
            t60c_rawGain(b) = Gains(21);
            tend_rawGain(b) = Gains(22);
        catch
        end

        t0a_normGain(b) = Gains(1) ./ meanGain_Baseline;
        t0b_normGain(b) = Gains(2) ./ meanGain_Baseline;
        t0c_normGain(b) = Gains(3) ./ meanGain_Baseline;
        tbl_normGain(b) = Gains(4) ./ meanGain_Baseline;
        t5_normGain(b) = Gains(5) ./ meanGain_Baseline;
        t10_normGain(b) = Gains(6) ./ meanGain_Baseline;
        t15_normGain(b) = Gains(7) ./ meanGain_Baseline;
        t20_normGain(b) = Gains(8) ./ meanGain_Baseline;
        t25_normGain(b) = Gains(9) ./ meanGain_Baseline;
        t30a_normGain(b) = Gains(10) ./ meanGain_Baseline;
        t30b_normGain(b) = Gains(11) ./ meanGain_Baseline;
        t30c_normGain(b) = Gains(12) ./ meanGain_Baseline;
        tmid_normGain(b) = Gains(13) ./ meanGain_Baseline;
        try
            t35_normGain(b) = Gains(14) ./ meanGain_Baseline;
            t40_normGain(b) = Gains(15) ./ meanGain_Baseline;
            t45_normGain(b) = Gains(16) ./ meanGain_Baseline;
            t50_normGain(b) = Gains(17) ./ meanGain_Baseline;
            t55_normGain(b) = Gains(18) ./ meanGain_Baseline;
            t60a_normGain(b) = Gains(19) ./ meanGain_Baseline;
            t60b_normGain(b) = Gains(20) ./ meanGain_Baseline;
            t60c_normGain(b) = Gains(21) ./ meanGain_Baseline;
            tend_normGain(b) = Gains(22) ./ meanGain_Baseline;
        catch
        end

        t0a_rSquare(b) = Rsquare(1);
        t0b_rSquare(b) = Rsquare(2);
        t0c_rSquare(b) = Rsquare(3);
        tbl_rSquare(b) = Rsquare(4);
        t5_rSquare(b) = Rsquare(5);
        t10_rSquare(b) = Rsquare(6);
        t15_rSquare(b) = Rsquare(7);
        t20_rSquare(b) = Rsquare(8);
        t25_rSquare(b) = Rsquare(9);
        t30a_rSquare(b) = Rsquare(10);
        t30b_rSquare(b) = Rsquare(11);
        t30c_rSquare(b) = Rsquare(12);
        tmid_rSquare(b) = Rsquare(13);
        try
            t35_rSquare(b) = Rsquare(14);
            t40_rSquare(b) = Rsquare(15);
            t45_rSquare(b) = Rsquare(16);
            t50_rSquare(b) = Rsquare(17);
            t55_rSquare(b) = Rsquare(18);
            t60a_rSquare(b) = Rsquare(19);
            t60b_rSquare(b) = Rsquare(20);
            t60c_rSquare(b) = Rsquare(21);
            tend_rSquare(b) = Rsquare(22);
        catch
        end

        t0a_badseg(b) = sacFrac((1)) > str2double(answer{4})/100;
        t0b_badseg(b) = sacFrac((2)) > str2double(answer{4})/100;
        t0c_badseg(b) = sacFrac((3)) > str2double(answer{4})/100;
        %tbl_badseg(b) = sacFrac((4)) > str2double(answer{4})/100;
        t5_badseg(b) = sacFrac((4))  > str2double(answer{4})/100;
        t10_badseg(b) = sacFrac((5)) > str2double(answer{4})/100;
        t15_badseg(b) = sacFrac((6)) > str2double(answer{4})/100;
        t20_badseg(b) = sacFrac((7)) > str2double(answer{4})/100;
        t25_badseg(b) = sacFrac((8)) > str2double(answer{4})/100;
        t30a_badseg(b) = sacFrac((9)) > str2double(answer{4})/100;
        t30b_badseg(b) = sacFrac((10)) > str2double(answer{4})/100;
        t30c_badseg(b) = sacFrac((11)) > str2double(answer{4})/100;
        %tmid_badseg(b) = sacFrac((13)) > str2double(answer{4})/100;
        try
            t35_badseg(b) = sacFrac((14)) > str2double(answer{4})/100;
            t40_badseg(b) = sacFrac((15)) > str2double(answer{4})/100;
            t45_badseg(b) = sacFrac((16)) > str2double(answer{4})/100;
            t50_badseg(b) = sacFrac((17)) > str2double(answer{4})/100;
            t55_badseg(b) = sacFrac((18)) > str2double(answer{4})/100;
            t60a_badseg(b) = sacFrac((19)) > str2double(answer{4})/100;
            t60b_badseg(b) = sacFrac((20)) > str2double(answer{4})/100;
            t60c_badseg(b) = sacFrac((21)) > str2double(answer{4})/100;
            %tend_badseg(b) = sacFrac((22)) > str2double(answer{4})/100;
        catch
        end
        b = b+1;
%         
        %% Rel Gain or Raw Gain
        if answer{5} == '1'
            Gains = Gains ./ meanGain_Baseline;
        end
        
        %% Filters
        % r squared Filter
        if meanRsquare_Baseline < str2double(answer{2})
            Gains(:) = NaN;
            sumStruct(j).removed = 1;
        else 
            sumStruct(j).removed = 0;
        end
        
        % Block % Filter
        sumStruct(j).BadSegCnt = sum(sacFrac(plotSegs) > str2double(answer{4})/100);
        if sumStruct(j).BadSegCnt > str2double(answer{3})
            Gains(:) = NaN;
            sumStruct(j).removed = 1;    
        end
        
        %% Plot 
        segAmt = length(Gains(plotSegsAll));
        
        if isnan(Gains(1))
            plot(1:segAmt, Gains(plotSegsAll)); hold on
        else
            A(v) =  plot(1:segAmt, Gains(plotSegsAll)); hold on
            v = v + 1;
        end
        
        scatter(1:segAmt, Gains(plotSegsAll), 5, 'k', 'filled'); hold on
        
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
T = table(name', expmtType', t0a_normGain', t0b_normGain', t0c_normGain', tbl_normGain', t5_normGain', t10_normGain', t15_normGain', t20_normGain', t25_normGain', t30a_normGain', t30b_normGain', t30c_normGain', tmid_normGain', ...
                           t0a_rawGain', t0b_rawGain', t0c_rawGain', tbl_rawGain', t5_rawGain', t10_rawGain', t15_rawGain', t20_rawGain', t25_rawGain', t30a_rawGain', t30b_rawGain', t30c_rawGain', tmid_rawGain', ...
                           t0a_rSquare', t0b_rSquare', t0c_rSquare', tbl_rSquare', t5_rSquare', t10_rSquare', t15_rSquare', t20_rSquare', t25_rSquare', t30a_rSquare', t30b_rSquare', t30c_rSquare', tmid_rSquare', ...
                           t0a_badseg', t0b_badseg', t0c_badseg', t5_badseg', t10_badseg', t15_badseg', t20_badseg', t25_badseg', t30a_badseg', t30b_badseg', t30c_badseg', ...
                           'VariableNames', ...
                           {'name', 'expmtType', 't0a_normGain', 't0b_normGain', 't0c_normGain', 'tbl_normGain', 't5_normGain', 't10_normGain', 't15_normGain', 't20_normGain', 't25_normGain', 't30a_normGain', 't30b_normGain', 't30c_normGain', 'tmid_normGain', ...
                           't0a_rawGain', 't0b_rawGain', 't0c_rawGain', 'tbl_rawGain', 't5_rawGain', 't10_rawGain', 't15_rawGain', 't20_rawGain', 't25_rawGain', 't30a_rawGain', 't30b_rawGain', 't30c_rawGain', 'tmid_rawGain', ...
                           't0a_rSquare', 't0b_rSquare', 't0c_rSquare', 'tbl_rSquare', 't5_rSquare', 't10_rSquare', 't15_rSquare', 't20_rSquare', 't25_rSquare', 't30a_rSquare', 't30b_rSquare', 't30c_rSquare', 'tmid_rSquare', ...
                           't0a_badseg', 't0b_badseg', 't0c_badseg', 't5_badseg', 't10_badseg', 't15_badseg', 't20_badseg', 't25_badseg', 't30a_badseg', 't30b_badseg', 't30c_badseg'});
                       
% for d = 1:25
%     if any(contains(T.name, num2str(d)))
%     end
% end
    
disp('Done!')