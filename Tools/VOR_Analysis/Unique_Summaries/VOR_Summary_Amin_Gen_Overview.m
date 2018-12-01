%% For Amin's Gen Analysis
%% Prep & Pre-allocate
clear;clc;close all
% get files
files = dir([cd '\**\normGainPost.mat']);
Hz_p2 = NaN(length(files),1);
Hz_p5 = Hz_p2;
Hz_1 = Hz_p2;
Hz_2 = Hz_p2;
Hz_3 = Hz_p2;
Hz_4 = Hz_p2;

mouse = cell(length(files), 1);
cohort = mouse;

Hz_p2_goodC = NaN(length(files), 4);
Hz_p5_goodC = NaN(length(files), 4);
Hz_1_goodC = NaN(length(files), 6); % DIFFERENT!!!!!!
Hz_2_goodC = NaN(length(files), 4);
Hz_3_goodC = NaN(length(files), 4);
Hz_4_goodC = NaN(length(files), 4);


%% PER MOUSE
for i = 1:length(files)
    
    % Load .mat file
    load([files(i).folder,'\' files(i).name])
    
    % Mouse ID & Cohort 
    [cohort{i}, mouse{i}] = fileparts(files(i).folder);
    
    [~, cohort{i}] = fileparts(cohort{i});
    
    % Norm Gain Change
    Hz_p2(i) = dot2;
    Hz_p5(i) = dot5;
    Hz_1(i) = one;
    Hz_2(i) = two;
    Hz_3(i) = three;
    Hz_4(i) = four;
    
    % load excel file to get good cycle #
    T = readtable(fullfile(files(i).folder, [mouse{i}, '.xlsx']));

    Hz_p2_goodC(i,:) = 1-table2array(T(strcmp('0.2Hz', T{:,1}), {'saccadeFrac'}));
    Hz_p5_goodC(i,:) = 1-table2array(T(strcmp('0.5Hz', T{:,1}), {'saccadeFrac'}));
    Hz_1_goodC(i,:) = 1-table2array(T(strcmp('1.0Hz', T{:,1}), {'saccadeFrac'}));
    Hz_2_goodC(i,:) = 1-table2array(T(strcmp('2.0Hz', T{:,1}), {'saccadeFrac'}));
    Hz_3_goodC(i,:) = 1-table2array(T(strcmp('3.0Hz', T{:,1}), {'saccadeFrac'}));
    Hz_4_goodC(i,:) = 1-table2array(T(strcmp('4.0Hz', T{:,1}), {'saccadeFrac'}));
    
    
    Hz_p2_eyeHamp(i,:) = table2array(T(strcmp('0.2Hz', T{:,1}), {'eyeHamp'}));
    Hz_p5_eyeHamp(i,:) = table2array(T(strcmp('0.5Hz', T{:,1}), {'eyeHamp'}));
    Hz_1_eyeHamp(i,:) = table2array(T(strcmp('1.0Hz', T{:,1}), {'eyeHamp'}));
    Hz_2_eyeHamp(i,:) = table2array(T(strcmp('2.0Hz', T{:,1}), {'eyeHamp'}));
    Hz_3_eyeHamp(i,:) = table2array(T(strcmp('3.0Hz', T{:,1}), {'eyeHamp'}));
    Hz_4_eyeHamp(i,:) = table2array(T(strcmp('4.0Hz', T{:,1}), {'eyeHamp'}));
    
end


%% COMBINE INTO TABLE & SAVE
tab = table(mouse, cohort, ...
            Hz_p2, Hz_p2_goodC, ...
            Hz_p5, Hz_p5_goodC, ...
            Hz_1,  Hz_1_goodC(:,[1,2,5,6]), ... % REMOVE MIDDLE TWO SECTION
            Hz_2,  Hz_2_goodC, ...
            Hz_3,  Hz_3_goodC, ...
            Hz_4,  Hz_4_goodC, ...
            Hz_p2_eyeHamp, Hz_p5_eyeHamp, Hz_1_eyeHamp, Hz_2_eyeHamp, ...
            Hz_3_eyeHamp, Hz_4_eyeHamp);

save('NormGainSummaryData.mat', 'tab')

%% PLOT 
plot_data('Cohort 1', {'-02_','-04_','-06_','-07_','-10_','-14_','-16_','-22_'}, {'-01_','-08_','-11_','-13_','-15_','-17_','-18_','-19_','-21_','-91_','-92_'}) % WT & Knock In
plot_data('Cohort 2', {'-02_','-23_','-24_','-25_','-26_','-27_','-28_','-21_','-36_'}, {'-29_','-30_','-32_','-33_','-34_','-35_','-37_'}) % WT & Knock In
plot_data('Cohort H', {'-01_','-03_','-04_','-09_'}, {'-02_','-06_','-07_','-08_'}) % Delta-7 & Hug

function plot_data(name, cond1, cond2)
    
    % Load Data
    load('NormGainSummaryData.mat', 'tab')
    Cohort = tab(strcmp(name, tab{:,2}), :);
    
    % Plot Data
    sumFig = figure();
    for i = 1:size(Cohort,1)
        gains = table2array(Cohort(i,{'Hz_p2', 'Hz_p5', 'Hz_1', 'Hz_2', 'Hz_3', 'Hz_4'}));
        xvals = 1:6;
        if any(contains(Cohort.mouse(i), cond1))
            color = 'k';
        elseif any(contains(Cohort.mouse(i), cond2))
            color = 'r';
        else
            warning('Mouse not found!')
            pause
        end
        a = plot(xvals, gains, 'LineWidth', 1.75, 'color', color );
        hold on
        scatter(xvals, gains, 'filled', 'SizeData',20 , 'MarkerFaceColor', a.Color);
    end

    % Cosmetics
    title(name)
    grid
    xticks(1:6)
    xticklabels({'0.2', '0.5', '1.0', '2.0', '3.0', '4.0'})
    xlabel('Frequency')
    ylabel('Normalized Gain Increase')
    hline(1, '--k')
    ylim([.8, 2])

    % Save
    savefig(sumFig, [ name, ' Cleaned_Ratio', '.fig'])
end

























