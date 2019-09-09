%% Prompt User for Variables
clear;clc;close all
warning off
prompt = {'Path: ', 'R^2 Threshold: ', 'Bad Segment Count: ', 'Removed Data Percentage: ', 'Gain Type (1 = norm, 2 = raw}', 'Training Block Size (5 or 10 minute, 1 for OKR)'};
dlgTitle = "Input: ";
dims = [1 40];
definput = {'F:\1 Jaydev Bhateja\Cohort 4\Data\Pretraining', ...
            '.35', ...
            '2', ...
            '40', ...
            '1', ...
            '10'};

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

if isempty(DRexcels) && isempty(GDGUexcels) && isempty(VESTexcels)
    a = 4;
else
    a = 1;
end

GUexcels = excels;


for i = a:4
    
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
            if answer{6} == '1'
                mList = GUexcels;
                Label = 'OKR';
            else
                mList = GUexcels;
                Label = 'Gain Up';
            end
            disp([Label, '...'])
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(1,1,[.03 .03],[.05 .03],[.03 .03]);
    v = 1;
    sumStruct = [];
    LegCell = {};
    
    for j = 1:length(mList)
        
        dataTable = readtable(fullfile(mList(j).folder, mList(j).name));
        disp(['     ', mList(j).name])
        
        % Update name for plotting ease
        newName = mList(j).name(18:19);
        if contains(mList(j).name, 'Redo')
            newName = [newName, 'r'];
        else
            newName = [newName, ' '];
        end
        mList(j).name = newName;
        sumStruct(j).name = newName;
        
        % Gather relevant data depending on block size
        
        if answer{6} == '10'
            bls = 1:3;
            mids = 9:11;
            ends = 17:19;
            plotSegs = ~logical(sum(dataTable.TimePoint == [5, 15, 25, 35, 45, 55], 2));
        elseif answer{6} == '5'
            bls = 1:3;
            mids = 15:17;
            ends = 30:32;
            plotSegs = ~logical(sum(dataTable.TimePoint == [2.5, 5, 7.5, 12.5, 15, 17.5, 22.5, 25, 27.5, 32.5, 35, 37.5, 42.5, 45, 47.5, 52.5, 55, 57.5], 2));
            plotSegs(18) = 0;
            if length(plotSegs) > 33
                plotSegs(33:end) = [];
            end
            if i == 4
                plotSegs(19:end) = [];
            end
        elseif answer{6} == '1'
            bls = 2:4;
            ends = 59:61;
            plotSegs = 1:62;
        end
        
        sacFrac = dataTable.saccadeFrac;
        GoodSegs = double(sacFrac < str2double(answer{4})/100); 
        Rsquare = dataTable.rsquare;
        GoodSegs(bls) = double(Rsquare(bls) > str2double(answer{2})) .* double(sacFrac(bls) < str2double(answer{4})/100);
        if i == 4
            if answer{6} == '1'
                GoodSegs(ends) = double(Rsquare(ends) > str2double(answer{2})) .* double(sacFrac(ends) < str2double(answer{4})/100);
            else
                GoodSegs(mids) = double(Rsquare(mids) > str2double(answer{2})) .* double(sacFrac(mids) < str2double(answer{4})/100);
            end
        else
            GoodSegs(ends) = double(Rsquare(ends) > str2double(answer{2})) .* double(sacFrac(ends) < str2double(answer{4})/100);
        end
        Gains = dataTable.eyeHgain .* GoodSegs; % Eliminate bad segments from mean calculation (will be eliminated from plot too)
        TimePoints = dataTable.TimePoint;
        
        % Baseline Averages
        meanGain_Baseline = sum(Gains(bls) .* (1-sacFrac(bls)) .* GoodSegs(bls)) / sum((1-sacFrac(bls)) .* GoodSegs(bls));
        meanRsquare_Baseline = sum(Rsquare(bls) .* (1-sacFrac(bls))) / sum((1-sacFrac(bls)));
        
        % Middle Averages
        if str2num(answer{6}) ~= 1
            meanGain_Mid = sum(Gains(mids) .* (1-sacFrac(mids)) .* GoodSegs(mids)) / sum((1-sacFrac(mids)) .* GoodSegs(mids));
            meanRsquare_Mid = sum(Rsquare(mids) .* (1-sacFrac(mids))) / sum((1-sacFrac(bls)));
        end
        
        % End Averages
        if answer{6} == '10'
            if length(Gains) > 18
                meanGain_End = sum(Gains(ends) .* (1-sacFrac(ends)) .* GoodSegs(ends)) / sum((1-sacFrac(ends)) .* GoodSegs(ends));
                meanRsquare_End = sum(Rsquare(ends) .* (1-sacFrac(ends)) .* GoodSegs(ends)) / sum((1-sacFrac(ends)) .* GoodSegs(ends));

                % Combine (for long expmt)
                Gains   = [Gains(1:3);   meanGain_Baseline;    Gains(4:11);   meanGain_Mid;    Gains(12:end);   meanGain_End];
                Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:11); meanRsquare_Mid; Rsquare(12:end); meanRsquare_End];
                plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:11); 1; plotSegs(12:end); 1]);
            else
                % Combine (for short expmt)
                Gains =   [Gains(1:3);   meanGain_Baseline;    Gains(4:11);   meanGain_Mid];
                Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:11); meanRsquare_Mid];
                plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:11); 1]);
            end
        elseif answer{6} == '5'
            if ~(isnan(Gains(30)))
                meanGain_End = sum(Gains(ends) .* (1-sacFrac(ends)) .* GoodSegs(ends)) / sum((1-sacFrac(ends)) .* GoodSegs(ends));
                meanRsquare_End = sum(Rsquare(ends) .* (1-sacFrac(ends))) / sum((1-sacFrac(ends)));

                % Combine (for long expmt)
                Gains   = [Gains(1:3);   meanGain_Baseline;    Gains(4:17);   meanGain_Mid;    Gains(19:32);   meanGain_End];
                Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:17); meanRsquare_Mid; Rsquare(19:32); meanRsquare_End];
                plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:17); 1; plotSegs(19:end); 1]);
            else
                % Combine (for short expmt)
                Gains =   [Gains(1:3);   meanGain_Baseline;    Gains(4:17);   meanGain_Mid];
                Rsquare = [Rsquare(1:3); meanRsquare_Baseline; Rsquare(4:17); meanRsquare_Mid];
                plotSegsAll = logical([plotSegs(1:3); 1; plotSegs(4:17); 1]);
            end
        elseif answer{6} == '1'
            meanGain_End = sum(Gains(ends) .* (1-sacFrac(ends)) .* GoodSegs(ends)) / sum((1-sacFrac(ends)) .* GoodSegs(ends));
            meanRsquare_End = sum(Rsquare(ends) .* (1-sacFrac(ends))) / sum((1-sacFrac(ends)));
            Gains = [Gains(1:4); meanGain_Baseline; Gains(5:61); meanGain_End; Gains(62)];
            Rsquare = [Rsquare(1:4); meanRsquare_Baseline; Rsquare(5:61); meanRsquare_End; Rsquare(62)];
            plotSegsAll = plotSegs;
        end
        
        % Save gains from all experiments
        sumStruct(j).blGains = meanGain_Baseline;
        sumStruct(j).blrSquare = meanRsquare_Baseline;
        sumStruct(j).endrSquare = meanRsquare_End;
        
       %% Save things for excel
       
        name{b} = sumStruct(j).name;
        expmtType{b}  = Label;
        
        if answer{6} == '10'
            
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
                t35_rawGain(b) = NaN;
                t40_rawGain(b) = NaN;
                t45_rawGain(b) = NaN;
                t50_rawGain(b) = NaN;
                t55_rawGain(b) = NaN;
                t60a_rawGain(b) = NaN;
                t60b_rawGain(b) = NaN;
                t60c_rawGain(b) = NaN;
                tend_rawGain(b) = NaN;
            end

            t0a_nrmGain(b) = Gains(1) ./ meanGain_Baseline;
            t0b_nrmGain(b) = Gains(2) ./ meanGain_Baseline;
            t0c_nrmGain(b) = Gains(3) ./ meanGain_Baseline;
            tbl_nrmGain(b) = Gains(4) ./ meanGain_Baseline;
            t5_nrmGain(b) = Gains(5) ./ meanGain_Baseline;
            t10_nrmGain(b) = Gains(6) ./ meanGain_Baseline;
            t15_nrmGain(b) = Gains(7) ./ meanGain_Baseline;
            t20_nrmGain(b) = Gains(8) ./ meanGain_Baseline;
            t25_nrmGain(b) = Gains(9) ./ meanGain_Baseline;
            t30a_nrmGain(b) = Gains(10) ./ meanGain_Baseline;
            t30b_nrmGain(b) = Gains(11) ./ meanGain_Baseline;
            t30c_nrmGain(b) = Gains(12) ./ meanGain_Baseline;
            tmid_nrmGain(b) = Gains(13) ./ meanGain_Baseline;
            try
                t35_nrmGain(b) = Gains(14) ./ meanGain_Baseline;
                t40_nrmGain(b) = Gains(15) ./ meanGain_Baseline;
                t45_nrmGain(b) = Gains(16) ./ meanGain_Baseline;
                t50_nrmGain(b) = Gains(17) ./ meanGain_Baseline;
                t55_nrmGain(b) = Gains(18) ./ meanGain_Baseline;
                t60a_nrmGain(b) = Gains(19) ./ meanGain_Baseline;
                t60b_nrmGain(b) = Gains(20) ./ meanGain_Baseline;
                t60c_nrmGain(b) = Gains(21) ./ meanGain_Baseline;
                tend_nrmGain(b) = Gains(22) ./ meanGain_Baseline;
            catch
                t35_nrmGain(b) = NaN;
                t40_nrmGain(b) = NaN;
                t45_nrmGain(b) = NaN;
                t50_nrmGain(b) = NaN;
                t55_nrmGain(b) = NaN;
                t60a_nrmGain(b) = NaN;
                t60b_nrmGain(b) = NaN;
                t60c_nrmGain(b) = NaN;
                tend_nrmGain(b) = NaN;
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
                t35_rSquare(b) = NaN;
                t40_rSquare(b) = NaN;
                t45_rSquare(b) = NaN;
                t50_rSquare(b) = NaN;
                t55_rSquare(b) = NaN;
                t60a_rSquare(b) = NaN;
                t60b_rSquare(b) = NaN;
                t60c_rSquare(b) = NaN;
                tend_rSquare(b) = NaN;
            end

            t0a_goodsegm(b) = GoodSegs(1);
            t0b_goodsegm(b) = GoodSegs(2);
            t0c_goodsegm(b) = GoodSegs(3);
            t5_goodsegm(b) = GoodSegs(4);
            t10_goodsegm(b) = GoodSegs(5);
            t15_goodsegm(b) = GoodSegs(6);
            t20_goodsegm(b) = GoodSegs(7);
            t25_goodsegm(b) = GoodSegs(8);
            t30a_goodsegm(b) = GoodSegs(9);
            t30b_goodsegm(b) = GoodSegs(10);
            t30c_goodsegm(b) = GoodSegs(11);
            try
                t35_goodsegm(b) = GoodSegs(12);
                t40_goodsegm(b) = GoodSegs(13);
                t45_goodsegm(b) = GoodSegs(14);
                t50_goodsegm(b) = GoodSegs(15);
                t55_goodsegm(b) = GoodSegs(16);
                t60a_goodsegm(b) = GoodSegs(17);
                t60b_goodsegm(b) = GoodSegs(18);
                t60c_goodsegm(b) = GoodSegs(19);

            catch
                t35_goodsegm(b) = 0;
                t40_goodsegm(b) = 0;
                t45_goodsegm(b) = 0;
                t50_goodsegm(b) = 0;
                t55_goodsegm(b) = 0;
                t60a_goodsegm(b) = 0;
                t60b_goodsegm(b) = 0;
                t60c_goodsegm(b) = 0;
            end
            
        elseif answer{6} == '5'
            
            t0a_rawGain(b) = Gains(1);
            t0b_rawGain(b) = Gains(2);
            t0c_rawGain(b) = Gains(3);
            tbl_rawGain(b) = Gains(4);
            t5_rawGain(b)  = (Gains(5) + Gains(7))/2;
            t10_rawGain(b) = Gains(8);
            t15_rawGain(b) = (Gains(9) + Gains(11))/2;
            t20_rawGain(b) = Gains(12);
            t25_rawGain(b) = (Gains(13) + Gains(15))/2;
            t30a_rawGain(b) = Gains(16);
            t30b_rawGain(b) = Gains(17);
            t30c_rawGain(b) = Gains(18);
            tmid_rawGain(b) = Gains(19);
            try
                t35_rawGain(b) = (Gains(20) + Gains(22))/2;
                t40_rawGain(b) = Gains(23);
                t45_rawGain(b) = (Gains(24) + Gains(26))/2;
                t50_rawGain(b) = Gains(27);
                t55_rawGain(b) = (Gains(28) + Gains(30))/2;
                t60a_rawGain(b) = Gains(31);
                t60b_rawGain(b) = Gains(32);
                t60c_rawGain(b) = Gains(33);
                tend_rawGain(b) = Gains(34);
            catch
                t35_rawGain(b) = NaN;
                t40_rawGain(b) = NaN;
                t45_rawGain(b) = NaN;
                t50_rawGain(b) = NaN;
                t55_rawGain(b) = NaN;
                t60a_rawGain(b) = NaN;
                t60b_rawGain(b) = NaN;
                t60c_rawGain(b) = NaN;
                tend_rawGain(b) = NaN;
            end

            t0a_nrmGain(b) = Gains(1) ./ meanGain_Baseline;
            t0b_nrmGain(b) = Gains(2) ./ meanGain_Baseline;
            t0c_nrmGain(b) = Gains(3) ./ meanGain_Baseline;
            tbl_nrmGain(b) = Gains(4) ./ meanGain_Baseline;
            t5_nrmGain(b) = (Gains(5) + Gains(7))/2 ./ meanGain_Baseline;
            t10_nrmGain(b) = Gains(8) ./ meanGain_Baseline;
            t15_nrmGain(b) = (Gains(9) + Gains(11))/2 ./ meanGain_Baseline;
            t20_nrmGain(b) = Gains(12) ./ meanGain_Baseline;
            t25_nrmGain(b) = (Gains(13) + Gains(15)) ./ meanGain_Baseline;
            t30a_nrmGain(b) = Gains(16) ./ meanGain_Baseline;
            t30b_nrmGain(b) = Gains(17) ./ meanGain_Baseline;
            t30c_nrmGain(b) = Gains(18) ./ meanGain_Baseline;
            tmid_nrmGain(b) = Gains(19) ./ meanGain_Baseline;
            try
                t35_nrmGain(b) = (Gains(20) + Gains(22))/2 ./ meanGain_Baseline;
                t40_nrmGain(b) = Gains(23) ./ meanGain_Baseline;
                t45_nrmGain(b) = (Gains(24) + Gains(26))/2 ./ meanGain_Baseline;
                t50_nrmGain(b) = Gains(27) ./ meanGain_Baseline;
                t55_nrmGain(b) = (Gains(28) + Gains(30))/2 ./ meanGain_Baseline;
                t60a_nrmGain(b) = Gains(31) ./ meanGain_Baseline;
                t60b_nrmGain(b) = Gains(32) ./ meanGain_Baseline;
                t60c_nrmGain(b) = Gains(33) ./ meanGain_Baseline;
                tend_nrmGain(b) = Gains(34) ./ meanGain_Baseline;
            catch
                t35_nrmGain(b) = NaN;
                t40_nrmGain(b) = NaN;
                t45_nrmGain(b) = NaN;
                t50_nrmGain(b) = NaN;
                t55_nrmGain(b) = NaN;
                t60a_nrmGain(b) = NaN;
                t60b_nrmGain(b) = NaN;
                t60c_nrmGain(b) = NaN;
                tend_nrmGain(b) = NaN;
            end

            t0a_rSquare(b) = Rsquare(1);
            t0b_rSquare(b) = Rsquare(2);
            t0c_rSquare(b) = Rsquare(3);
            tbl_rSquare(b) = Rsquare(4);
            t5_rSquare(b) = (Rsquare(5) + Rsquare(7))/2;
            t10_rSquare(b) = Rsquare(8);
            t15_rSquare(b) = (Rsquare(9) + Rsquare(11))/2;
            t20_rSquare(b) = Rsquare(12);
            t25_rSquare(b) = (Rsquare(13) + Rsquare(15))/2;
            t30a_rSquare(b) = Rsquare(16);
            t30b_rSquare(b) = Rsquare(17);
            t30c_rSquare(b) = Rsquare(18);
            tmid_rSquare(b) = Rsquare(19);
            try
                t35_rSquare(b) = (Rsquare(20) + Rsquare(22))/2;
                t40_rSquare(b) = Rsquare(23);
                t45_rSquare(b) = (Rsquare(24) + Rsquare(26))/2;
                t50_rSquare(b) = Rsquare(27);
                t55_rSquare(b) = (Rsquare(28) + Rsquare(30))/2;
                t60a_rSquare(b) = Rsquare(31);
                t60b_rSquare(b) = Rsquare(32);
                t60c_rSquare(b) = Rsquare(33);
                tend_rSquare(b) = Rsquare(34);
            catch
                t35_rSquare(b) = NaN;
                t40_rSquare(b) = NaN;
                t45_rSquare(b) = NaN;
                t50_rSquare(b) = NaN;
                t55_rSquare(b) = NaN;
                t60a_rSquare(b) = NaN;
                t60b_rSquare(b) = NaN;
                t60c_rSquare(b) = NaN;
                tend_rSquare(b) = NaN;
            end

            t0a_goodsegm(b) = GoodSegs(1);
            t0b_goodsegm(b) = GoodSegs(2);
            t0c_goodsegm(b) = GoodSegs(3);
            t5_goodsegm(b) = (sacFrac((5)) + sacFrac((7)))/2  > str2double(answer{4})/100;
            t10_goodsegm(b) = GoodSegs(8);
            t15_goodsegm(b) = (sacFrac((9)) + sacFrac((11)))/2 > str2double(answer{4})/100;
            t20_goodsegm(b) = GoodSegs(12);
            t25_goodsegm(b) = (sacFrac((13)) + sacFrac((15)))/2 > str2double(answer{4})/100;
            t30a_goodsegm(b) = GoodSegs(16);
            t30b_goodsegm(b) = GoodSegs(17);
            t30c_goodsegm(b) = GoodSegs(18);
            try
                t35_goodsegm(b) = (sacFrac((20)) + sacFrac((22)))/2 > str2double(answer{4})/100;
                t40_goodsegm(b) = GoodSegs(23);
                t45_goodsegm(b) = (sacFrac((24)) + sacFrac((26)))/2 > str2double(answer{4})/100;
                t50_goodsegm(b) = GoodSegs(27);
                t55_goodsegm(b) = (sacFrac((28)) + sacFrac((30)))/2 > str2double(answer{4})/100;
                t60a_goodsegm(b) = GoodSegs(31);
                t60b_goodsegm(b) = GoodSegs(32);
                t60c_goodsegm(b) = GoodSegs(33);

            catch
                t35_goodsegm(b) = 0;
                t40_goodsegm(b) = 0;
                t45_goodsegm(b) = 0;
                t50_goodsegm(b) = 0;
                t55_goodsegm(b) = 0;
                t60a_goodsegm(b) = 0;
                t60b_goodsegm(b) = 0;
                t60c_goodsegm(b) = 0;
            end
        
        elseif answer{6} == '1'
            
            t0_rawGainVOR(b) = Gains(1);
            t1_rawGainOKR(b) = Gains(2);
            t2_rawGainOKR(b) = Gains(3);
            t3_rawGainOKR(b) = Gains(4);
            tbl_rawGainOKR(b) = Gains(5);
            t4_rawGainOKR(b) = Gains(6);
            t5_rawGainOKR(b) = Gains(7);
            t6_rawGainOKR(b) = Gains(8);
            t7_rawGainOKR(b) = Gains(9);
            t8_rawGainOKR(b) = Gains(10);
            t9_rawGainOKR(b) = Gains(11);
            t10_rawGainOKR(b) = Gains(12);
            t11_rawGainOKR(b) = Gains(13);
            t12_rawGainOKR(b) = Gains(14);
            t13_rawGainOKR(b) = Gains(15);
            t14_rawGainOKR(b) = Gains(16);
            t15_rawGainOKR(b) = Gains(17);
            t16_rawGainOKR(b) = Gains(18);
            t17_rawGainOKR(b) = Gains(19);
            t18_rawGainOKR(b) = Gains(20);
            t19_rawGainOKR(b) = Gains(21);
            t20_rawGainOKR(b) = Gains(22);
            t21_rawGainOKR(b) = Gains(23);
            t22_rawGainOKR(b) = Gains(24);
            t23_rawGainOKR(b) = Gains(25);
            t24_rawGainOKR(b) = Gains(26);
            t25_rawGainOKR(b) = Gains(27);
            t26_rawGainOKR(b) = Gains(28);
            t27_rawGainOKR(b) = Gains(29);
            t28_rawGainOKR(b) = Gains(30);
            t29_rawGainOKR(b) = Gains(31);
            t30_rawGainOKR(b) = Gains(32);
            t31_rawGainOKR(b) = Gains(33);
            t32_rawGainOKR(b) = Gains(34);
            t33_rawGainOKR(b) = Gains(35);
            t34_rawGainOKR(b) = Gains(36);
            t35_rawGainOKR(b) = Gains(37);
            t36_rawGainOKR(b) = Gains(38);
            t37_rawGainOKR(b) = Gains(39);
            t38_rawGainOKR(b) = Gains(40);
            t39_rawGainOKR(b) = Gains(41);
            t40_rawGainOKR(b) = Gains(42);
            t41_rawGainOKR(b) = Gains(43);
            t42_rawGainOKR(b) = Gains(44);
            t43_rawGainOKR(b) = Gains(45);
            t44_rawGainOKR(b) = Gains(46);
            t45_rawGainOKR(b) = Gains(47);
            t46_rawGainOKR(b) = Gains(48);
            t47_rawGainOKR(b) = Gains(49);
            t48_rawGainOKR(b) = Gains(50);
            t49_rawGainOKR(b) = Gains(51);
            t50_rawGainOKR(b) = Gains(52);
            t51_rawGainOKR(b) = Gains(53);
            t52_rawGainOKR(b) = Gains(54);
            t53_rawGainOKR(b) = Gains(55);
            t54_rawGainOKR(b) = Gains(56);
            t55_rawGainOKR(b) = Gains(57);
            t56_rawGainOKR(b) = Gains(58);
            t57_rawGainOKR(b) = Gains(59);
            t58_rawGainOKR(b) = Gains(60);
            t59_rawGainOKR(b) = Gains(61);
            t60_rawGainOKR(b) = Gains(62);
            tend_rawGainOKR(b) = Gains(63);
            t60_rawGainVOR(b) = Gains(64);
            
            t0_nrmGainVOR(b) = Gains(1) ./ meanGain_Baseline;
            t1_nrmGainOKR(b) = Gains(2) ./ meanGain_Baseline;
            t2_nrmGainOKR(b) = Gains(3) ./ meanGain_Baseline;
            t3_nrmGainOKR(b) = Gains(4) ./ meanGain_Baseline;
            tbl_nrmGainOKR(b) = Gains(5) ./ meanGain_Baseline;
            t4_nrmGainOKR(b) = Gains(6) ./ meanGain_Baseline;
            t5_nrmGainOKR(b) = Gains(7) ./ meanGain_Baseline;
            t6_nrmGainOKR(b) = Gains(8) ./ meanGain_Baseline;
            t7_nrmGainOKR(b) = Gains(9) ./ meanGain_Baseline;
            t8_nrmGainOKR(b) = Gains(10) ./ meanGain_Baseline;
            t9_nrmGainOKR(b) = Gains(11) ./ meanGain_Baseline;
            t10_nrmGainOKR(b) = Gains(12) ./ meanGain_Baseline;
            t11_nrmGainOKR(b) = Gains(13) ./ meanGain_Baseline;
            t12_nrmGainOKR(b) = Gains(14) ./ meanGain_Baseline;
            t13_nrmGainOKR(b) = Gains(15) ./ meanGain_Baseline;
            t14_nrmGainOKR(b) = Gains(16) ./ meanGain_Baseline;
            t15_nrmGainOKR(b) = Gains(17) ./ meanGain_Baseline;
            t16_nrmGainOKR(b) = Gains(18) ./ meanGain_Baseline;
            t17_nrmGainOKR(b) = Gains(19) ./ meanGain_Baseline;
            t18_nrmGainOKR(b) = Gains(20) ./ meanGain_Baseline;
            t19_nrmGainOKR(b) = Gains(21) ./ meanGain_Baseline;
            t20_nrmGainOKR(b) = Gains(22) ./ meanGain_Baseline;
            t21_nrmGainOKR(b) = Gains(23) ./ meanGain_Baseline;
            t22_nrmGainOKR(b) = Gains(24) ./ meanGain_Baseline;
            t23_nrmGainOKR(b) = Gains(25) ./ meanGain_Baseline;
            t24_nrmGainOKR(b) = Gains(26) ./ meanGain_Baseline;
            t25_nrmGainOKR(b) = Gains(27) ./ meanGain_Baseline;
            t26_nrmGainOKR(b) = Gains(28) ./ meanGain_Baseline;
            t27_nrmGainOKR(b) = Gains(29) ./ meanGain_Baseline;
            t28_nrmGainOKR(b) = Gains(30) ./ meanGain_Baseline;
            t29_nrmGainOKR(b) = Gains(31) ./ meanGain_Baseline;
            t30_nrmGainOKR(b) = Gains(32) ./ meanGain_Baseline;
            t31_nrmGainOKR(b) = Gains(33) ./ meanGain_Baseline;
            t32_nrmGainOKR(b) = Gains(34) ./ meanGain_Baseline;
            t33_nrmGainOKR(b) = Gains(35) ./ meanGain_Baseline;
            t34_nrmGainOKR(b) = Gains(36) ./ meanGain_Baseline;
            t35_nrmGainOKR(b) = Gains(37) ./ meanGain_Baseline;
            t36_nrmGainOKR(b) = Gains(38) ./ meanGain_Baseline;
            t37_nrmGainOKR(b) = Gains(39) ./ meanGain_Baseline;
            t38_nrmGainOKR(b) = Gains(40) ./ meanGain_Baseline;
            t39_nrmGainOKR(b) = Gains(41) ./ meanGain_Baseline;
            t40_nrmGainOKR(b) = Gains(42) ./ meanGain_Baseline;
            t41_nrmGainOKR(b) = Gains(43) ./ meanGain_Baseline;
            t42_nrmGainOKR(b) = Gains(44) ./ meanGain_Baseline;
            t43_nrmGainOKR(b) = Gains(45) ./ meanGain_Baseline;
            t44_nrmGainOKR(b) = Gains(46) ./ meanGain_Baseline;
            t45_nrmGainOKR(b) = Gains(47) ./ meanGain_Baseline;
            t46_nrmGainOKR(b) = Gains(48) ./ meanGain_Baseline;
            t47_nrmGainOKR(b) = Gains(49) ./ meanGain_Baseline;
            t48_nrmGainOKR(b) = Gains(50) ./ meanGain_Baseline;
            t49_nrmGainOKR(b) = Gains(51) ./ meanGain_Baseline;
            t50_nrmGainOKR(b) = Gains(52) ./ meanGain_Baseline;
            t51_nrmGainOKR(b) = Gains(53) ./ meanGain_Baseline;
            t52_nrmGainOKR(b) = Gains(54) ./ meanGain_Baseline;
            t53_nrmGainOKR(b) = Gains(55) ./ meanGain_Baseline;
            t54_nrmGainOKR(b) = Gains(56) ./ meanGain_Baseline;
            t55_nrmGainOKR(b) = Gains(57) ./ meanGain_Baseline;
            t56_nrmGainOKR(b) = Gains(58) ./ meanGain_Baseline;
            t57_nrmGainOKR(b) = Gains(59) ./ meanGain_Baseline;
            t58_nrmGainOKR(b) = Gains(60) ./ meanGain_Baseline;
            t59_nrmGainOKR(b) = Gains(61) ./ meanGain_Baseline;
            t60_nrmGainOKR(b) = Gains(62) ./ meanGain_Baseline;
            tend_nrmGainOKR(b) = Gains(63) ./ meanGain_Baseline;
            t60_nrmGainVOR(b) = Gains(64) ./ meanGain_Baseline;
            
            t0_RsquareVOR(b) = Rsquare(1);
            t1_RsquareOKR(b) = Rsquare(2);
            t2_RsquareOKR(b) = Rsquare(3);
            t3_RsquareOKR(b) = Rsquare(4);
            tbl_RsquareOKR(b) = Rsquare(5);
            t4_RsquareOKR(b) = Rsquare(6);
            t5_RsquareOKR(b) = Rsquare(7);
            t6_RsquareOKR(b) = Rsquare(8);
            t7_RsquareOKR(b) = Rsquare(9);
            t8_RsquareOKR(b) = Rsquare(10);
            t9_RsquareOKR(b) = Rsquare(11);
            t10_RsquareOKR(b) = Rsquare(12);
            t11_RsquareOKR(b) = Rsquare(13);
            t12_RsquareOKR(b) = Rsquare(14);
            t13_RsquareOKR(b) = Rsquare(15);
            t14_RsquareOKR(b) = Rsquare(16);
            t15_RsquareOKR(b) = Rsquare(17);
            t16_RsquareOKR(b) = Rsquare(18);
            t17_RsquareOKR(b) = Rsquare(19);
            t18_RsquareOKR(b) = Rsquare(20);
            t19_RsquareOKR(b) = Rsquare(21);
            t20_RsquareOKR(b) = Rsquare(22);
            t21_RsquareOKR(b) = Rsquare(23);
            t22_RsquareOKR(b) = Rsquare(24);
            t23_RsquareOKR(b) = Rsquare(25);
            t24_RsquareOKR(b) = Rsquare(26);
            t25_RsquareOKR(b) = Rsquare(27);
            t26_RsquareOKR(b) = Rsquare(28);
            t27_RsquareOKR(b) = Rsquare(29);
            t28_RsquareOKR(b) = Rsquare(30);
            t29_RsquareOKR(b) = Rsquare(31);
            t30_RsquareOKR(b) = Rsquare(32);
            t31_RsquareOKR(b) = Rsquare(33);
            t32_RsquareOKR(b) = Rsquare(34);
            t33_RsquareOKR(b) = Rsquare(35);
            t34_RsquareOKR(b) = Rsquare(36);
            t35_RsquareOKR(b) = Rsquare(37);
            t36_RsquareOKR(b) = Rsquare(38);
            t37_RsquareOKR(b) = Rsquare(39);
            t38_RsquareOKR(b) = Rsquare(40);
            t39_RsquareOKR(b) = Rsquare(41);
            t40_RsquareOKR(b) = Rsquare(42);
            t41_RsquareOKR(b) = Rsquare(43);
            t42_RsquareOKR(b) = Rsquare(44);
            t43_RsquareOKR(b) = Rsquare(45);
            t44_RsquareOKR(b) = Rsquare(46);
            t45_RsquareOKR(b) = Rsquare(47);
            t46_RsquareOKR(b) = Rsquare(48);
            t47_RsquareOKR(b) = Rsquare(49);
            t48_RsquareOKR(b) = Rsquare(50);
            t49_RsquareOKR(b) = Rsquare(51);
            t50_RsquareOKR(b) = Rsquare(52);
            t51_RsquareOKR(b) = Rsquare(53);
            t52_RsquareOKR(b) = Rsquare(54);
            t53_RsquareOKR(b) = Rsquare(55);
            t54_RsquareOKR(b) = Rsquare(56);
            t55_RsquareOKR(b) = Rsquare(57);
            t56_RsquareOKR(b) = Rsquare(58);
            t57_RsquareOKR(b) = Rsquare(59);
            t58_RsquareOKR(b) = Rsquare(60);
            t59_RsquareOKR(b) = Rsquare(61);
            t60_RsquareOKR(b) = Rsquare(62);
            tend_RsquareOKR(b) = Rsquare(63);
            t60_RsquareVOR(b) = Rsquare(64);
            
            t0_goodsegmVOR(b) = GoodSegs(1);
            t1_goodsegmOKR(b) = GoodSegs(2);
            t2_goodsegmOKR(b) = GoodSegs(3);
            t3_goodsegmOKR(b) = GoodSegs(4);
            t4_goodsegmOKR(b) = GoodSegs(5);
            t5_goodsegmOKR(b) = GoodSegs(6);
            t6_goodsegmOKR(b) = GoodSegs(7);
            t7_goodsegmOKR(b) = GoodSegs(8);
            t8_goodsegmOKR(b) = GoodSegs(9);
            t9_goodsegmOKR(b) = GoodSegs(10);
            t10_goodsegmOKR(b) = GoodSegs(11);
            t11_goodsegmOKR(b) = GoodSegs(12);
            t12_goodsegmOKR(b) = GoodSegs(13);
            t13_goodsegmOKR(b) = GoodSegs(14);
            t14_goodsegmOKR(b) = GoodSegs(15);
            t15_goodsegmOKR(b) = GoodSegs(16);
            t16_goodsegmOKR(b) = GoodSegs(17);
            t17_goodsegmOKR(b) = GoodSegs(18);
            t18_goodsegmOKR(b) = GoodSegs(19);
            t19_goodsegmOKR(b) = GoodSegs(20);
            t20_goodsegmOKR(b) = GoodSegs(21);
            t21_goodsegmOKR(b) = GoodSegs(22);
            t22_goodsegmOKR(b) = GoodSegs(23);
            t23_goodsegmOKR(b) = GoodSegs(24);
            t24_goodsegmOKR(b) = GoodSegs(25);
            t25_goodsegmOKR(b) = GoodSegs(26);
            t26_goodsegmOKR(b) = GoodSegs(27);
            t27_goodsegmOKR(b) = GoodSegs(28);
            t28_goodsegmOKR(b) = GoodSegs(29);
            t29_goodsegmOKR(b) = GoodSegs(30);
            t30_goodsegmOKR(b) = GoodSegs(31);
            t31_goodsegmOKR(b) = GoodSegs(32);
            t32_goodsegmOKR(b) = GoodSegs(33);
            t33_goodsegmOKR(b) = GoodSegs(34);
            t34_goodsegmOKR(b) = GoodSegs(35);
            t35_goodsegmOKR(b) = GoodSegs(36);
            t36_goodsegmOKR(b) = GoodSegs(37);
            t37_goodsegmOKR(b) = GoodSegs(38);
            t38_goodsegmOKR(b) = GoodSegs(39);
            t39_goodsegmOKR(b) = GoodSegs(40);
            t40_goodsegmOKR(b) = GoodSegs(41);
            t41_goodsegmOKR(b) = GoodSegs(42);
            t42_goodsegmOKR(b) = GoodSegs(43);
            t43_goodsegmOKR(b) = GoodSegs(44);
            t44_goodsegmOKR(b) = GoodSegs(45);
            t45_goodsegmOKR(b) = GoodSegs(46);
            t46_goodsegmOKR(b) = GoodSegs(47);
            t47_goodsegmOKR(b) = GoodSegs(48);
            t48_goodsegmOKR(b) = GoodSegs(49);
            t49_goodsegmOKR(b) = GoodSegs(50);
            t50_goodsegmOKR(b) = GoodSegs(51);
            t51_goodsegmOKR(b) = GoodSegs(52);
            t52_goodsegmOKR(b) = GoodSegs(53);
            t53_goodsegmOKR(b) = GoodSegs(54);
            t54_goodsegmOKR(b) = GoodSegs(55);
            t55_goodsegmOKR(b) = GoodSegs(56);
            t56_goodsegmOKR(b) = GoodSegs(57);
            t57_goodsegmOKR(b) = GoodSegs(58);
            t58_goodsegmOKR(b) = GoodSegs(59);
            t59_goodsegmOKR(b) = GoodSegs(60);
            t60_goodsegmOKR(b) = GoodSegs(61);
            t60_goodsegmVOR(b) = GoodSegs(62);
            
        end
        
        b = b+1;
        
        %% Rel Gain or Raw Gain
        if answer{5} == '1'
            Gains = Gains ./ meanGain_Baseline;
        end
        
        %% Filters
        % r squared Filter Beginning
        if ((meanRsquare_Baseline < str2double(answer{2})) || (meanRsquare_End < str2double(answer{2})))
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
        
        if isnan(sumStruct(j).blGains)
            sumStruct(j).removed = 1;
        end
        
        for q = 1:length(Gains)
            if Gains(q) == 0
                Gains(q) = NaN;
            end
        end
        
        %% Plot 
        segAmt = length(Gains(plotSegsAll));
        
        if isnan(Gains(4))
            goodExpmt(b) = 0;
            sumStruct(j).removed = 1;
            plot(1:segAmt, Gains(plotSegsAll)); hold on
        else
            goodExpmt(b) = 1;
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
        if answer{6} == '1'
            ylim([0.4, 4.0])
        else
            ylim([0.4, 2.5])
        end
    else
        ylabel('Raw Gain')
        if answer{6} == '1'
            ylim([0, 2.5])
        else
            ylim([0.0, 1.5])
        end
    end
    
    %xlabel('tmpts')
    box off
    xticks(1:segAmt)
    if length(xticks) > 60
        xticklabels({'VOR', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', ... 
            '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', ... 
            '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', ... 
            '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', 'VOR'})
    else
        xticklabels({'0', '0', '0', 'Beg', '10', '20', '30', '30', '30', 'Mid', '40', '50', '60', '60', '60', 'End'})
    end
    xlim([.8 segAmt+.2])
    
    
    
    %% Text Marking
    % Orientation Parameters
    textGap = .06;
    if answer{6} == '1'
        yAlign = 9;
    else
        yAlign = 2.5;
    end
    
    xAlignTop = max(ylim)-.04;
    FontSize = 9;
    
    % Make Text Notes - Keep spacing in mind!! Not handled by matlab, so I
    % do it manually.
    
    %text(yAlign, xAlignTop-(k*textGap), '    nm     gain   r^2  BS', 'FontSize', FontSize)
    %k = k + 1;
    
    for z = 1:length(sumStruct)
        if ~sumStruct(z).removed
            Gstrnum = num2str(sumStruct(z).blGains);
            if (isnan(sumStruct(z).blGains))
                Gstrnum = ['0'];
            end
            if (length(Gstrnum) == 1)
                Gstrnum = [Gstrnum, '.00'];
            end
            RstrnumBL = num2str(sumStruct(z).blrSquare);
            if (isnan(sumStruct(z).blrSquare))
                RstrnumBL = ['0'];
            end
            if (length(RstrnumBL) == 1)
                RstrnumBL = [RstrnumBL, '.00'];
            end
            RstrnumEnd = num2str(sumStruct(z).endrSquare);
            if (isnan(sumStruct(z).endrSquare))
                RstrnumEnd = ['0'];
            end
            if (length(RstrnumEnd) == 1)
                RstrnumEnd = [RstrnumEnd, '.00'];
            end
            BCstrnum = num2str(sumStruct(z).BadSegCnt);
            %text(yAlign, xAlignTop-(k*textGap), [sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum], 'FontSize', FontSize)
            LegCell(z) = {[sumStruct(z).name, '   ', Gstrnum(1:4), '   ', RstrnumBL(1:4), '   ', RstrnumEnd(1:4), '   ', BCstrnum]};
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
    text(yAlign, xAlignTop-(k*textGap), 'nm   gain    r^2 Beg    r^2 End    BadSegs', 'FontSize', FontSize)
    k = k + 1;
    
    for z = 1:length(sumStruct)
        if sumStruct(z).removed
            Gstrnum = num2str(sumStruct(z).blGains);
            if (isnan(sumStruct(z).blGains))
                Gstrnum = ['0'];
            end
            if (length(Gstrnum) == 1)
                Gstrnum = [Gstrnum, '.00'];
            end
            RstrnumBL = num2str(sumStruct(z).blrSquare);
            if (isnan(sumStruct(z).blrSquare))
                RstrnumBL = ['0'];
            end
            if (length(RstrnumBL) == 1)
                RstrnumBL = [RstrnumBL, '.00'];
            end
            RstrnumEnd = num2str(sumStruct(z).endrSquare);
            if (isnan(sumStruct(z).endrSquare))
                RstrnumEnd = ['0'];
            end
            if (length(RstrnumEnd) == 1)
                RstrnumEnd = [RstrnumEnd, '.00'];
            end
            BCstrnum = num2str(sumStruct(z).BadSegCnt);
            text(yAlign, xAlignTop-(k*textGap), [sumStruct(z).name, '   ', Gstrnum(1:4), '    ', RstrnumBL(1:4), '        ', RstrnumEnd(1:4), '        ', BCstrnum], 'FontSize', FontSize)
            %LegCell(z) = {[sumStruct(z).name, '   ', Gstrnum(1:4), '   ', Rstrnum(1:4), '   ', BCstrnum]};
            k = k + 1;
        end
    end

    k = 0;
    text(yAlign+yAlign, xAlignTop-(k*textGap), 'Parameters', 'FontSize', FontSize+2)
    k = k + 1;
    text(yAlign+yAlign, xAlignTop-(k*textGap), ['r^2 Cutoff: ' answer{2}], 'FontSize', FontSize)
    k = k + 1;
    text(yAlign+yAlign, xAlignTop-(k*textGap), ['Seg cnt Cutoff: ', answer{3}], 'FontSize', FontSize)
    k = k + 1;
    text(yAlign+yAlign, xAlignTop-(k*textGap), ['Seg % Cutoff: ', answer{4}], 'FontSize', FontSize)
    
    savefig([Label, '.fig'])
end
                      
    if answer{6} == '1'
        T = table(name', expmtType', goodExpmt(2:end)', ...
            t0_nrmGainVOR', t1_nrmGainOKR', t2_nrmGainOKR', t3_nrmGainOKR', tbl_nrmGainOKR', t4_nrmGainOKR', t5_nrmGainOKR', t6_nrmGainOKR', ... 
            t7_nrmGainOKR', t8_nrmGainOKR', t9_nrmGainOKR', t10_nrmGainOKR', t11_nrmGainOKR', t12_nrmGainOKR', t13_nrmGainOKR', t14_nrmGainOKR', ... 
            t15_nrmGainOKR', t16_nrmGainOKR', t17_nrmGainOKR', t18_nrmGainOKR', t19_nrmGainOKR', t20_nrmGainOKR', t21_nrmGainOKR', t22_nrmGainOKR', ... 
            t23_nrmGainOKR', t24_nrmGainOKR', t25_nrmGainOKR', t26_nrmGainOKR', t27_nrmGainOKR', t28_nrmGainOKR', t29_nrmGainOKR', t30_nrmGainOKR', ... 
            t31_nrmGainOKR', t32_nrmGainOKR', t33_nrmGainOKR', t34_nrmGainOKR', t35_nrmGainOKR', t36_nrmGainOKR', t37_nrmGainOKR', t38_nrmGainOKR', ... 
            t39_nrmGainOKR', t40_nrmGainOKR', t41_nrmGainOKR', t42_nrmGainOKR', t43_nrmGainOKR', t44_nrmGainOKR', t45_nrmGainOKR', t46_nrmGainOKR', ... 
            t47_nrmGainOKR', t48_nrmGainOKR', t49_nrmGainOKR', t50_nrmGainOKR', t51_nrmGainOKR', t52_nrmGainOKR', t53_nrmGainOKR', t54_nrmGainOKR', ... 
            t55_nrmGainOKR', t56_nrmGainOKR', t57_nrmGainOKR', t58_nrmGainOKR', t59_nrmGainOKR', t60_nrmGainOKR', tend_nrmGainOKR', t60_nrmGainVOR', ... 
            t0_RsquareVOR', t1_RsquareOKR', t2_RsquareOKR', tbl_RsquareOKR', t3_RsquareOKR', t4_RsquareOKR', t5_RsquareOKR', t6_RsquareOKR', ... 
            t0_rawGainVOR', t1_rawGainOKR', t2_rawGainOKR', tbl_rawGainOKR', t3_rawGainOKR', t4_rawGainOKR', t5_rawGainOKR', t6_rawGainOKR', ... 
            t7_rawGainOKR', t8_rawGainOKR', t9_rawGainOKR', t10_rawGainOKR', t11_rawGainOKR', t12_rawGainOKR', t13_rawGainOKR', t14_rawGainOKR', ... 
            t15_rawGainOKR', t16_rawGainOKR', t17_rawGainOKR', t18_rawGainOKR', t19_rawGainOKR', t20_rawGainOKR', t21_rawGainOKR', t22_rawGainOKR', ... 
            t23_rawGainOKR', t24_rawGainOKR', t25_rawGainOKR', t26_rawGainOKR', t27_rawGainOKR', t28_rawGainOKR', t29_rawGainOKR', t30_rawGainOKR', ... 
            t31_rawGainOKR', t32_rawGainOKR', t33_rawGainOKR', t34_rawGainOKR', t35_rawGainOKR', t36_rawGainOKR', t37_rawGainOKR', t38_rawGainOKR', ... 
            t39_rawGainOKR', t40_rawGainOKR', t41_rawGainOKR', t42_rawGainOKR', t43_rawGainOKR', t44_rawGainOKR', t45_rawGainOKR', t46_rawGainOKR', ... 
            t47_rawGainOKR', t48_rawGainOKR', t49_rawGainOKR', t50_rawGainOKR', t51_rawGainOKR', t52_rawGainOKR', t53_rawGainOKR', t54_rawGainOKR', ... 
            t55_rawGainOKR', t56_rawGainOKR', t57_rawGainOKR', t58_rawGainOKR', t59_rawGainOKR', t60_rawGainOKR', tend_rawGainOKR', t60_rawGainVOR', ... 
            t7_RsquareOKR', t8_RsquareOKR', t9_RsquareOKR', t10_RsquareOKR', t11_RsquareOKR', t12_RsquareOKR', t13_RsquareOKR', t14_RsquareOKR', ... 
            t15_RsquareOKR', t16_RsquareOKR', t17_RsquareOKR', t18_RsquareOKR', t19_RsquareOKR', t20_RsquareOKR', t21_RsquareOKR', t22_RsquareOKR', ... 
            t23_RsquareOKR', t24_RsquareOKR', t25_RsquareOKR', t26_RsquareOKR', t27_RsquareOKR', t28_RsquareOKR', t29_RsquareOKR', t30_RsquareOKR', ... 
            t31_RsquareOKR', t32_RsquareOKR', t33_RsquareOKR', t34_RsquareOKR', t35_RsquareOKR', t36_RsquareOKR', t37_RsquareOKR', t38_RsquareOKR', ... 
            t39_RsquareOKR', t40_RsquareOKR', t41_RsquareOKR', t42_RsquareOKR', t43_RsquareOKR', t44_RsquareOKR', t45_RsquareOKR', t46_RsquareOKR', ... 
            t47_RsquareOKR', t48_RsquareOKR', t49_RsquareOKR', t50_RsquareOKR', t51_RsquareOKR', t52_RsquareOKR', t53_RsquareOKR', t54_RsquareOKR', ... 
            t55_RsquareOKR', t56_RsquareOKR', t57_RsquareOKR', t58_RsquareOKR', t59_RsquareOKR', t60_RsquareOKR', tend_RsquareOKR', t60_RsquareVOR', ... 
            t0_goodsegmVOR', t1_goodsegmOKR', t2_goodsegmOKR', t3_goodsegmOKR', t4_goodsegmOKR', t5_goodsegmOKR', t6_goodsegmOKR', t7_goodsegmOKR', ... 
            t8_goodsegmOKR', t9_goodsegmOKR', t10_goodsegmOKR', t11_goodsegmOKR', t12_goodsegmOKR', t13_goodsegmOKR', t14_goodsegmOKR', ... 
            t15_goodsegmOKR', t16_goodsegmOKR', t17_goodsegmOKR', t18_goodsegmOKR', t19_goodsegmOKR', t20_goodsegmOKR', t21_goodsegmOKR', ... 
            t22_goodsegmOKR', t23_goodsegmOKR', t24_goodsegmOKR', t25_goodsegmOKR', t26_goodsegmOKR', t27_goodsegmOKR', t28_goodsegmOKR', ... 
            t29_goodsegmOKR', t30_goodsegmOKR', t31_goodsegmOKR', t32_goodsegmOKR', t33_goodsegmOKR', t34_goodsegmOKR', t35_goodsegmOKR', ... 
            t36_goodsegmOKR', t37_goodsegmOKR', t38_goodsegmOKR', t39_goodsegmOKR', t40_goodsegmOKR', t41_goodsegmOKR', t42_goodsegmOKR', ... 
            t43_goodsegmOKR', t44_goodsegmOKR', t45_goodsegmOKR', t46_goodsegmOKR', t47_goodsegmOKR', t48_goodsegmOKR', t49_goodsegmOKR', ... 
            t50_goodsegmOKR', t51_goodsegmOKR', t52_goodsegmOKR', t53_goodsegmOKR', t54_goodsegmOKR', t55_goodsegmOKR', t56_goodsegmOKR', ... 
            t57_goodsegmOKR', t58_goodsegmOKR', t59_goodsegmOKR', t60_goodsegmOKR', t60_goodsegmVOR', ...         
            'VariableNames', ...
            {'Name', 'expmtType', 'goodExpmt', ...
            't0_nrmGainVOR', 't1_nrmGainOKR', 't2_nrmGainOKR', 't3_nrmGainOKR', 'tbl_nrmGainOKR', 't4_nrmGainOKR', 't5_nrmGainOKR', 't6_nrmGainOKR', ... 
            't7_nrmGainOKR', 't8_nrmGainOKR', 't9_nrmGainOKR', 't10_nrmGainOKR', 't11_nrmGainOKR', 't12_nrmGainOKR', 't13_nrmGainOKR', 't14_nrmGainOKR', ... 
            't15_nrmGainOKR', 't16_nrmGainOKR', 't17_nrmGainOKR', 't18_nrmGainOKR', 't19_nrmGainOKR', 't20_nrmGainOKR', 't21_nrmGainOKR', 't22_nrmGainOKR', ... 
            't23_nrmGainOKR', 't24_nrmGainOKR', 't25_nrmGainOKR', 't26_nrmGainOKR', 't27_nrmGainOKR', 't28_nrmGainOKR', 't29_nrmGainOKR', 't30_nrmGainOKR', ... 
            't31_nrmGainOKR', 't32_nrmGainOKR', 't33_nrmGainOKR', 't34_nrmGainOKR', 't35_nrmGainOKR', 't36_nrmGainOKR', 't37_nrmGainOKR', 't38_nrmGainOKR', ... 
            't39_nrmGainOKR', 't40_nrmGainOKR', 't41_nrmGainOKR', 't42_nrmGainOKR', 't43_nrmGainOKR', 't44_nrmGainOKR', 't45_nrmGainOKR', 't46_nrmGainOKR', ... 
            't47_nrmGainOKR', 't48_nrmGainOKR', 't49_nrmGainOKR', 't50_nrmGainOKR', 't51_nrmGainOKR', 't52_nrmGainOKR', 't53_nrmGainOKR', 't54_nrmGainOKR', ... 
            't55_nrmGainOKR', 't56_nrmGainOKR', 't57_nrmGainOKR', 't58_nrmGainOKR', 't59_nrmGainOKR', 't60_nrmGainOKR', 'tend_nrmGainOKR', 't60_nrmGainVOR', ... 
            't0_rawGainVOR', 't1_rawGainOKR', 't2_rawGainOKR', 'tbl_rawGainOKR', 't3_rawGainOKR', 't4_rawGainOKR', 't5_rawGainOKR', 't6_rawGainOKR', ... 
            't7_rawGainOKR', 't8_rawGainOKR', 't9_rawGainOKR', 't10_rawGainOKR', 't11_rawGainOKR', 't12_rawGainOKR', 't13_rawGainOKR', 't14_rawGainOKR', ... 
            't15_rawGainOKR', 't16_rawGainOKR', 't17_rawGainOKR', 't18_rawGainOKR', 't19_rawGainOKR', 't20_rawGainOKR', 't21_rawGainOKR', 't22_rawGainOKR', ... 
            't23_rawGainOKR', 't24_rawGainOKR', 't25_rawGainOKR', 't26_rawGainOKR', 't27_rawGainOKR', 't28_rawGainOKR', 't29_rawGainOKR', 't30_rawGainOKR', ... 
            't31_rawGainOKR', 't32_rawGainOKR', 't33_rawGainOKR', 't34_rawGainOKR', 't35_rawGainOKR', 't36_rawGainOKR', 't37_rawGainOKR', 't38_rawGainOKR', ... 
            't39_rawGainOKR', 't40_rawGainOKR', 't41_rawGainOKR', 't42_rawGainOKR', 't43_rawGainOKR', 't44_rawGainOKR', 't45_rawGainOKR', 't46_rawGainOKR', ... 
            't47_rawGainOKR', 't48_rawGainOKR', 't49_rawGainOKR', 't50_rawGainOKR', 't51_rawGainOKR', 't52_rawGainOKR', 't53_rawGainOKR', 't54_rawGainOKR', ... 
            't55_rawGainOKR', 't56_rawGainOKR', 't57_rawGainOKR', 't58_rawGainOKR', 't59_rawGainOKR', 't60_rawGainOKR', 'tend_rawGainOKR', 't60_rawGainVOR', ... 
            't0_RsquareVOR', 't1_RsquareOKR', 't2_RsquareOKR', 'tbl_RsquareOKR', 't3_RsquareOKR', 't4_RsquareOKR', 't5_RsquareOKR', 't6_RsquareOKR', ... 
            't7_RsquareOKR', 't8_RsquareOKR', 't9_RsquareOKR', 't10_RsquareOKR', 't11_RsquareOKR', 't12_RsquareOKR', 't13_RsquareOKR', 't14_RsquareOKR', ... 
            't15_RsquareOKR', 't16_RsquareOKR', 't17_RsquareOKR', 't18_RsquareOKR', 't19_RsquareOKR', 't20_RsquareOKR', 't21_RsquareOKR', 't22_RsquareOKR', ... 
            't23_RsquareOKR', 't24_RsquareOKR', 't25_RsquareOKR', 't26_RsquareOKR', 't27_RsquareOKR', 't28_RsquareOKR', 't29_RsquareOKR', 't30_RsquareOKR', ... 
            't31_RsquareOKR', 't32_RsquareOKR', 't33_RsquareOKR', 't34_RsquareOKR', 't35_RsquareOKR', 't36_RsquareOKR', 't37_RsquareOKR', 't38_RsquareOKR', ... 
            't39_RsquareOKR', 't40_RsquareOKR', 't41_RsquareOKR', 't42_RsquareOKR', 't43_RsquareOKR', 't44_RsquareOKR', 't45_RsquareOKR', 't46_RsquareOKR', ... 
            't47_RsquareOKR', 't48_RsquareOKR', 't49_RsquareOKR', 't50_RsquareOKR', 't51_RsquareOKR', 't52_RsquareOKR', 't53_RsquareOKR', 't54_RsquareOKR', ... 
            't55_RsquareOKR', 't56_RsquareOKR', 't57_RsquareOKR', 't58_RsquareOKR', 't59_RsquareOKR', 't60_RsquareOKR', 'tend_RsquareOKR', 't60_RsquareVOR', ... 
            't0_goodsegmVOR', 't1_goodsegmOKR', 't2_goodsegmOKR', 't3_goodsegmOKR', 't4_goodsegmOKR', 't5_goodsegmOKR', 't6_goodsegmOKR', 't7_goodsegmOKR', ... 
            't8_goodsegmOKR', 't9_goodsegmOKR', 't10_goodsegmOKR', 't11_goodsegmOKR', 't12_goodsegmOKR', 't13_goodsegmOKR', 't14_goodsegmOKR', ... 
            't15_goodsegmOKR', 't16_goodsegmOKR', 't17_goodsegmOKR', 't18_goodsegmOKR', 't19_goodsegmOKR', 't20_goodsegmOKR', 't21_goodsegmOKR', ... 
            't22_goodsegmOKR', 't23_goodsegmOKR', 't24_goodsegmOKR', 't25_goodsegmOKR', 't26_goodsegmOKR', 't27_goodsegmOKR', 't28_goodsegmOKR', ... 
            't29_goodsegmOKR', 't30_goodsegmOKR', 't31_goodsegmOKR', 't32_goodsegmOKR', 't33_goodsegmOKR', 't34_goodsegmOKR', 't35_goodsegmOKR', ... 
            't36_goodsegmOKR', 't37_goodsegmOKR', 't38_goodsegmOKR', 't39_goodsegmOKR', 't40_goodsegmOKR', 't41_goodsegmOKR', 't42_goodsegmOKR', ... 
            't43_goodsegmOKR', 't44_goodsegmOKR', 't45_goodsegmOKR', 't46_goodsegmOKR', 't47_goodsegmOKR', 't48_goodsegmOKR', 't49_goodsegmOKR', ... 
            't50_goodsegmOKR', 't51_goodsegmOKR', 't52_goodsegmOKR', 't53_goodsegmOKR', 't54_goodsegmOKR', 't55_goodsegmOKR', 't56_goodsegmOKR', ... 
            't57_goodsegmOKR', 't58_goodsegmOKR', 't59_goodsegmOKR', 't60_goodsegmOKR', 't60_goodsegmVOR'});   
    else
        T = table(name', expmtType', goodExpmt(2:end)', ...
            t0a_nrmGain', t0b_nrmGain', t0c_nrmGain', tbl_nrmGain', t10_nrmGain', t20_nrmGain', t30a_nrmGain', t30b_nrmGain', t30c_nrmGain', tmid_nrmGain', t40_nrmGain', t50_nrmGain', t60a_nrmGain', t60b_nrmGain', t60c_nrmGain', tend_nrmGain', ...
            t0a_rawGain', t0b_rawGain', t0c_rawGain', tbl_rawGain', t10_rawGain', t20_rawGain', t30a_rawGain', t30b_rawGain', t30c_rawGain', tmid_rawGain', t40_rawGain', t50_rawGain', t60a_rawGain', t60b_rawGain', t60c_rawGain', tend_rawGain', ...
            t0a_rSquare', t0b_rSquare', t0c_rSquare', tbl_rSquare', t10_rSquare', t20_rSquare', t30a_rSquare', t30b_rSquare', t30c_rSquare', tmid_rSquare', t40_rSquare', t50_rSquare', t60a_rSquare', t60b_rSquare', t60c_rSquare', tend_rSquare', ...
            t0a_goodsegm', t0b_goodsegm', t0c_goodsegm',            t10_goodsegm', t20_goodsegm', t30a_goodsegm', t30b_goodsegm', t30c_goodsegm',           t40_goodsegm', t50_goodsegm', t60a_goodsegm', t60b_goodsegm', t60c_goodsegm', ...
            t5_nrmGain', t15_nrmGain', t25_nrmGain', t35_nrmGain', t45_nrmGain', t55_nrmGain', ...
            t5_rawGain', t15_rawGain', t25_rawGain', t35_rawGain', t45_rawGain', t55_rawGain', ...
            t5_rSquare', t15_rSquare', t25_rSquare', t35_rSquare', t45_rSquare', t55_rSquare', ...
            t5_goodsegm', t15_goodsegm', t25_goodsegm', t35_goodsegm', t45_goodsegm', t55_goodsegm', ...                           
            'VariableNames', ...
            {'Name', 'expmtType', 'goodExpmt', ...
            'N01', 'N02', 'N03', 'NBeg', 'N10', 'N20', 'N301', 'N302', 'N303', 'NMid', 'N40', 'N50', 'N601', 'N602', 'N603', 'NEnd', ...
            'R01', 'R02', 'R03', 'RBeg', 'R10', 'R20', 'R301', 'R302', 'R303', 'RMid', 'R40', 'R50', 'R601', 'R602', 'R603', 'REnd', ...
            't0a_rSquare', 't0b_rSquare', 't0c_rSquare', 'tbl_rSquare', 't10_rSquare', 't20_rSquare', 't30a_rSquare', 't30b_rSquare', 't30c_rSquare', 'tmid_rSquare', 't40_rSquare', 't50_rSquare', 't60a_rSquare', 't60b_rSquare', 't60c_rSquare', 'tend_rSquare', ...
            't0a_goodsegm', 't0b_goodsegm', 't0c_goodsegm',             't10_goodsegm', 't20_goodsegm', 't30a_goodsegm', 't30b_goodsegm', 't30c_goodseg',             't40_goodsegm', 't50_goodsegm', 't60a_goodsegm', 't60b_goodsegm', 't60c_goodsegm', ...
            'N5', 'N15', 'N25', 'N35', 'N45', 'N55', ...
            'R5', 'R15', 'R25', 'R35', 'R45', 'R55', ...
            't5_rSquare', 't15_rSquare', 't25_rSquare', 't35_rSquare', 't45_rSquare', 't55_rSquare', ...
            't5_goodsegm', 't15_goodsegm', 't25_goodsegm', 't35_goodsegm', 't45_goodsegm', 't55_goodsegm'});   
    end

writetable(T, 'AllMiceBigChart.xlsx')
    
cd(answer{1})

for d = 1:25
    
    if d < 10
        if any(contains(T.Name, ['0', num2str(d)]))
            filename = ['Mouse_', num2str(d), '.xlsx'];
            writetable(T(contains(T.Name, ['0', num2str(d)]), :), filename)
        end
        
    elseif any(contains(T.Name, num2str(d)))
        filename = ['Mouse_', num2str(d), '.xlsx'];
        writetable(T(contains(T.Name, [num2str(d)]), :), filename)
    end

end

if str2num(answer{6}) == 5
    for e = 1:10
        if any(contains(T.Name, [num2str(e), ' ']))
            filename = ['Mouse_', num2str(e), '.xlsx'];
            writetable(T(contains(T.Name, [num2str(e)]), :), filename)
        end
    end
end
    
disp('Done!')