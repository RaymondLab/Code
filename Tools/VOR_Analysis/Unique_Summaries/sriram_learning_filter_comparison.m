%{
Provides comparison of various filtering on learned component traces.

INSTRUCTIONS: 
1. Set "Current Folder" to the one containing the excel file. 
2. Ensure data is in the first sheet, with "time" as the last column. 
3. Modify the five variables below as needed. 
4. Run script.

Generates figures displaying raw and filtered traces from the Excel file.
It produces a figure (or set of figures) for each type of filter. It 
supports up to "maxCols" columns per figure. Additionally, it creates a 
new Excel for each filter, and on each file, a new sheet per filter
parameter.

Version 3.0 (02/01/2024)
Code written by Brian Angeles (bangeles@stanford.edu) for Raymond lab
%}

%% Set to the Excel file name
excelFilename = 'For_smoothing_OKR_sample_data.xlsx';

%% Set to cell containing the first header value
headerRow = 'A1';

%% Set to cell containing the first data value
dataRowStarts = 'A2';

%% Set the maximum number of columns per figure per filter type
maxCols = 5;

%% For moving average, set the window lengths to compare
% Note for SG filter, window lengths must be odd
windowLengths = [5, 11, 21, 31];

%% For SG, set the window lengths to compare
% Note for SG filter, window lengths must be odd
sgWindowLengths = [5, 11, 21, 31];

%% For Butterworth, set the cutoff frequencies to compare
cutoffFrequencies = [5, 7.5, 10, 15];




% ============================================================
% ========== Do not change anything below this line ==========
% ============================================================

% Load excel data
filePath = fullfile(cd,excelFilename);
opts = detectImportOptions(filePath);
opts.VariableNamesRange = headerRow;
opts.DataRange = dataRowStarts;
opts.VariableNamingRule = 'preserve';
T = readtable(filePath,opts);

% Get data properties
headers = T.Properties.VariableNames;
nColumns = size(T,2) - 1;
nPlots = ceil(nColumns/maxCols);

% Scale data by half
T{:,1:nColumns} = T{:,1:nColumns}./2;

% Generate stimulus template
stimulus = sin(T{:,end}.*(2*pi/1000)).*10;

samplerate = 1000;
peakTypes = {'string', 'singlenan', 'uint16', 'singlenan', 'uint16', 'singlenan'};
for filterType = 1:3
    if filterType == 1
        nRows = size(windowLengths, 2);
        peakHeaders = {'Expmt','Window','Peaktime1','Peakvalue1','Peaktime2','Peakvalue2'};
        newPath = fullfile(cd,'Comparison_MA_data.xlsx');
    elseif filterType == 2
        nRows = size(cutoffFrequencies, 2);
        peakHeaders = {'Expmt','Cutoff','Peaktime1','Peakvalue1','Peaktime2','Peakvalue2'};
        newPath = fullfile(cd,'Comparison_BW_data.xlsx');
    else
        nRows = size(sgWindowLengths, 2);
        peakHeaders = {'Expmt','Window','Peaktime1','Peakvalue1','Peaktime2','Peakvalue2'};
        newPath = fullfile(cd,'Comparison_SG_data.xlsx');
    end
    nPeakRows = round(nPlots * maxCols * (nRows+1));
    Tpeaks = table('Size',[nPeakRows 6], 'VariableTypes',peakTypes, 'VariableNames',peakHeaders);
    writetable(T, newPath, 'Sheet','RawData');
    for k = 1:nPlots
        kk = round((k-1)*maxCols);
        kkk = round((nRows+1)*kk);
        remaining = nColumns - kk;
        fig = figure('units','normalized','outerposition',[0 0 0.8 0.8]); clf
        t = tiledlayout(fig,nRows+1,maxCols);
        t.TileSpacing = 'compact';
        for j = 1:maxCols
            nexttile
            if j <= remaining
                plot(T{:,end}, stimulus(:), 'LineWidth',1, 'Color','black');
                hold on;
                plot(T{:,end}, zeros(1,length(T{:,end})), ':k', 'LineWidth',0.25);
                plot(T{:,end}, T{:,kk+j}, 'LineWidth', 2, 'Color', 'blue');
                [val1, loc1] = max(T{1:500,kk+j});
                [val2, loc2] = max(T{500:end,kk+j}.*(-1));
                loc2 = loc2 + 499;
                tpIdx = kkk+j;
                Tpeaks{tpIdx,1} = string(headers{1,kk+j});
                Tpeaks{tpIdx,2} = nan;
                Tpeaks{tpIdx,3} = loc1;
                Tpeaks{tpIdx,4} = val1;
                Tpeaks{tpIdx,5} = loc2;
                Tpeaks{tpIdx,6} = val2;
                plot(T{loc1,end}, T{loc1,kk+j}, 'r+', 'LineWidth',2, 'MarkerSize',8);
                plot(T{loc2,end}, T{loc2,kk+j}, 'r+', 'LineWidth',2, 'MarkerSize',8);
                text(T{loc1,end}, T{loc1,kk+j}-6, ...
                    [num2str(loc1),' ms'], ...
                    'HorizontalAlignment','center');
                text(T{loc2,end}, T{loc2,kk+j}+6, ...
                    [num2str(loc2),' ms'], ...
                    'HorizontalAlignment','center');
                hold off;
                title(headers{kk+j});
            else
                plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'white');
            end
            ylim([-11,11]);
            xticks([]);
            if j ~= 1
                yticks([]);
            else
                ylabel('Raw data');
                set(get(gca,'YLabel'),'Rotation',0)
            end
        end
        
        for i = 1:nRows
            % Make temporary copy of the data
            temp = T;
            % Fill temporary copy with the moving average of each column
            for j = 1:maxCols
                nexttile
                if j <= remaining
                    if filterType == 1
                        filtValue = windowLengths(i);
                        temp{:,kk+j} = movmean(T{:,kk+j}, filtValue);
                    elseif filterType == 2
                        filtValue = cutoffFrequencies(i);
                        [zb,pb,kb] = butter(9,filtValue/(samplerate/2),'low');
                        [sos,gb] = zp2sos(zb,pb,kb);
                        temp{:,kk+j} = filtfilt(sos,gb,T{:,kk+j});
                    else
                        filtValue = sgWindowLengths(i);
                        temp{:,kk+j} = sgolayfilt(T{:,kk+j},4,filtValue);
                    end
                    plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'black');
                    hold on;
                    plot(T{:,end}, zeros(1,length(T{:,end})), ':k', 'LineWidth',0.25);
                    plot(T{:,end}, temp{:,kk+j}, 'LineWidth', 2, 'Color', 'blue');
                    [val1, loc1] = max(temp{1:500,kk+j});
                    [val2, loc2] = max(temp{500:end,kk+j}.*(-1));
                    loc2 = loc2 + 499;
                    tpIdx = kkk + (i*maxCols) + j;
                    Tpeaks{tpIdx,1} = string(headers{1,kk+j});
                    Tpeaks{tpIdx,2} = filtValue;
                    Tpeaks{tpIdx,3} = loc1;
                    Tpeaks{tpIdx,4} = val1;
                    Tpeaks{tpIdx,5} = loc2;
                    Tpeaks{tpIdx,6} = val2;
                    plot(T{loc1,end}, temp{loc1,kk+j}, 'r+', 'LineWidth',2, 'MarkerSize',8);
                    plot(T{loc2,end}, temp{loc2,kk+j}, 'r+', 'LineWidth',2, 'MarkerSize',8);
                    text(T{loc1,end}, temp{loc1,kk+j}-6, ...
                        [num2str(loc1),' ms'], ...
                        'HorizontalAlignment','center');
                    text(T{loc2,end}, temp{loc2,kk+j}+6, ...
                        [num2str(loc2),' ms'], ...
                        'HorizontalAlignment','center');
                    hold off;
                else
                    plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'white');
                end
                ylim([-11,11]);
                if i ~= nRows
                    xticks([]);
                end
                if j ~= 1
                    yticks([]);
                else
                    if filterType == 1
                        ylabel(strcat(num2str(windowLengths(i)),'ms window'));
                    elseif filterType == 2
                        ylabel(strcat(num2str(cutoffFrequencies(i)),'Hz cutoff'));
                    else
                        ylabel(strcat(num2str(sgWindowLengths(i)),'ms window'));
                    end
                    set(get(gca,'YLabel'),'Rotation',0)
                end
            end
            % Write data to new sheet in the excel file
            if filterType == 1
                sheetName = strcat(num2str(windowLengths(i)),'ms');
            elseif filterType == 2
                sheetName = strcat(num2str(cutoffFrequencies(i)),'Hz');
            else
                sheetName = strcat(num2str(sgWindowLengths(i)),'ms');
            end
            writetable(temp,newPath,'Sheet',sheetName);
        end
        linkaxes(t.Children,'xy');
        if filterType == 1
            title(t,'Comparison of Moving Average filter window lengths on learned component traces','FontSize',18);
            saveas(gcf,fullfile([cd,strcat('/Comparison_MA_fig',num2str(k)),'.png']))
            saveas(gcf,fullfile([cd,strcat('/Comparison_MA_fig',num2str(k)),'.fig']))
        elseif filterType == 2
            title(t,'Comparison of Butterworth filter cutoff frequencies on learned component traces','FontSize',18);
            saveas(gcf,fullfile([cd,strcat('/Comparison_BW_fig',num2str(k)),'.png']))
            saveas(gcf,fullfile([cd,strcat('/Comparison_BW_fig',num2str(k)),'.fig']))
        else
            title(t,'Comparison of Savitzky-Golay filter window lengths on learned component traces','FontSize',18);
            saveas(gcf,fullfile([cd,strcat('/Comparison_SG_fig',num2str(k)),'.png']))
            saveas(gcf,fullfile([cd,strcat('/Comparison_SG_fig',num2str(k)),'.fig']))
        end
    end
    Tpeaks = rmmissing(Tpeaks, 'MinNumMissing',4);
    Tpeaks = sortrows(Tpeaks, {'Expmt', peakHeaders{1,2}}, 'MissingPlacement','first');
    writetable(Tpeaks,newPath,'Sheet','PeakSummary');
end
