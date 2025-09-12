%{
Provides comparison of various moving averages on learned component traces.

INSTRUCTIONS: 
1. Set "Current Folder" to the one containing the excel file. 
2. Ensure data is in the first sheet, with "time" as the last column. 
3. Modify the five variables below as needed. 
4. Run script.

Generates figures displaying raw and filtered traces from the Excel file. 
It supports up to "maxCols" columns per figure. Additionally, it adds a 
new sheet to the Excel file with moving average data for each specified 
window length in "windowLengths".

Version 2.0 (02/01/2024)
Code written by Brian Angeles (bangeles@stanford.edu)
%}

%% Set to the Excel file name
excelFilename = 'For_smoothing_OKR_sample_data.xlsx';

%% Set to cell containing the first header value
headerRow = 'A1';

%% Set to cell containing the first data value
dataRowStarts = 'A4';

%% Set the maximum number of columns per figure
maxCols = 5;

%% Set to the type of filter to use
% Moving average = 1, Butterworth = 2, Savitzky-Golay = 3
filterType = 3;

%% IF moving average or SG, set the window lengths to compare
% Note for SG filter, window lengths must be odd
windowLengths = [5, 11, 21, 31];

%% If butterworth, set the cutoff frequencies to compare
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
nWindows = size(windowLengths,2);
nColumns = size(T,2) - 1;
nPlots = ceil(nColumns/maxCols);

% Scale data by half
T{:,1:nColumns} = T{:,1:nColumns}./2;

% Generate stimulus template
stimulus = sin(T{:,end}.*(2*pi/1000)).*10;

samplerate = 1000;
for k = 1:nPlots
    kk = round(maxCols*(k-1));
    remaining = nColumns - kk;
    fig = figure('units','normalized','outerposition',[0 0 0.8 0.8]); clf
    t = tiledlayout(fig,nWindows+1,maxCols);
    t.TileSpacing = 'compact';
    for j = 1:maxCols
        nexttile
        if j <= remaining
            plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'black');
            hold on;
            plot(T{:,end}, T{:,kk+j}, 'LineWidth', 2, 'Color', 'blue');
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
    
    for i = 1:nWindows
        % Make temporary copy of the data
        temp = T;
        % Fill temporary copy with the moving average of each column
        for j = 1:maxCols
            nexttile
            if j <= remaining
                if filterType == 1
                    temp{:,kk+j} = movmean(T{:,kk+j}, windowLengths(i));
                elseif filterType == 2
                    [zb,pb,kb] = butter(9,cutoffFrequencies(i)/(samplerate/2),'low');
                    [sos,gb] = zp2sos(zb,pb,kb);
                    temp{:,kk+j} = filtfilt(sos,gb,T{:,kk+j});
                else
                    temp{:,kk+j} = sgolayfilt(T{:,kk+j},4,windowLengths(i));
                end
                plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'black');
                hold on;
                plot(temp{:,end},temp{:,kk+j}, 'LineWidth', 2, 'Color', 'blue');
                hold off;
            else
                plot(T{:,end}, stimulus(:), 'LineWidth', 1, 'Color', 'white');
            end
            ylim([-11,11]);
            if i ~= nWindows
                xticks([]);
            end
            if j ~= 1
                yticks([]);
            else
                ylabel(strcat(num2str(windowLengths(i)),'ms window'));
                set(get(gca,'YLabel'),'Rotation',0)
            end
        end
        % Write data to new sheet in the excel file
        sheetName = strcat(num2str(windowLengths(i)),'ms');
        writetable(temp,filePath,'Sheet',sheetName);
    end
    % title(t,'Title');
    linkaxes(t.Children,'xy');
    saveas(gcf,fullfile([cd,strcat('/learning_moving_averages_fig',num2str(k)),'.png']))
end
