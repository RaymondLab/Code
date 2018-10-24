function VOR_Summary_Amin_Gen(measure, excel_file, norm )
%{
Required
    measure: Data to make into summary graph. Found in the excel file
optional
    excel_file: location of the excel file. Default is current folder.
    norm: '1' normalize data. '0' use raw values. Default is raw values.
%}

%% Prep Variables
if ~exist('excel_file', 'var')
     folder = cd;
     [~, file] = fileparts(folder);
     excel_file = fullfile(folder,[file '.xlsx']);
end

if ~exist('norm', 'var')
    norm = 0;
end

if ~exist('measure', 'var')
    error('Please specify measure')
end

%% Import Data
% Import excel table 
T = readtable(excel_file);

% Remove NaN values from table
goodRows = ~isnan(table2array(T(:,2)));
T = T(goodRows,:);

% Extract Relevant Information
seg_labels = T.Type;
seg_groups = [1;1;1;1;1;1;
              2;2;2;2;2;2;
              3;
              4;4;
              5;
              6;6;6;6;6;6;
              7;7;7;7;7;7];
seg_measure = T{:,strcmpi(T.Properties.VariableNames, measure)};
seg_nGC = T{:,strcmpi(T.Properties.VariableNames, 'nGoodCycles')};

%% norm data if needed
if norm
    t_0_mean = nanmean(seg_measure(seg_groups == 0));
    seg_measure = seg_measure ./ t_0_mean;  
end

%% Plot data and add Cosmetics

% Peach, Green, Light Blue, Dark Blue, Yellow, Teal, Light Green,
all_colors = {
                [251 111 66] ./ 255                
                [12 195 82] ./ 255
                [8 180 238] ./ 255
                [1 17 181] ./ 255
                [251 250 48] ./ 255
                [18 150 155] ./ 255
                [94 250 81] ./ 255
              };
          
uniqueSegs = unique(seg_labels);
seg_colors = cell(size(seg_measure));

% Use Consistant color for each condition
for i = 1:length(uniqueSegs)
    seg_colors(ismember(seg_labels,uniqueSegs(i))) = all_colors(i);
end

sumFig = figure(); 
set(sumFig, 'visible', 'off');
hold on
scatterHandles = NaN(size(seg_groups));

for i = 1:length(seg_measure)
    scatterHandles(i) = scatter(seg_groups(i),seg_measure(i), ...
        'filled', ...
        'MarkerFaceColor', seg_colors{i}, ...
        'MarkerEdgeColor',[0 0 0], ...
        'LineWidth', .5);
end
plot(seg_groups(strcmpi(seg_labels,'VORD')), seg_measure(strcmpi(seg_labels,'VORD')), 'color', [251 111 66] ./ 255)

% Universal Cosmetics
xlim([min(seg_groups)-.5, max(seg_groups)+.5])
groups = {'PreT1'
          'PreT2'
          'Train1'
          'M Test'
          'Train2'
          'PostT1'
          'PostT2'};
xticklabels(groups)
xlabel('Segment')

% Norm Specific Cosmetics
if norm
    ylabel(['Normalized ' measure])
    plot(linspace(0,max(seg_groups)+.5),ones(100,1), '--k')
    title([measure, ' - Norm. to mean (T0a, T0b, T0c)'])
else
    ylabel(['Raw ' measure])
    title([measure, ' - Raw'])
end
%legend(scatterHandles([1 4]), uniqueSegs); % TODO Hack-y
legend(scatterHandles([2, 6, 4, 1, 5, 3]), uniqueSegs, 'Location', 'northwest'); % TODO Hack-y



%% Save Figure
% save as .pdf
print(sumFig,strrep(excel_file, '.xlsx', ['_Summary_' char(string(norm)) '_' measure '.pdf']),'-dpdf', '-r300');
% Save as .fig
savefig(sumFig, strrep(excel_file, '.xlsx', ['_Summary_' char(string(norm)) '_' measure '.fig']))

A = gcf;
for i = 1:length(A.Children(2).Children)
    try
        A.Children(2).Children(i).SizeData = .1;
        pause(.1);
    catch
    end
end


%% Figure B - average the two tests by their good cycle count

%{
PRE
2 == 1, 10
.2 == 2, 7
4 == 3,11
1 == 4, 8
3 == 5,12
.5 == 6,9

POST
.2 == 22,27
.5 == 20,23
1 == 21, 25
2 == 19, 28
3 == 17, 24
4 == 18, 26

Mid == 14,15
%}

% Calculated weighted means
predot2 = (seg_measure(2)*seg_nGC(2) + seg_measure(7)*seg_nGC(7))/sum([seg_nGC(2); seg_nGC(7)]);
predot5 = (seg_measure(6)*seg_nGC(6) + seg_measure(9)*seg_nGC(9))/sum([seg_nGC(6); seg_nGC(9)]);
pre1    = (seg_measure(4)*seg_nGC(4) + seg_measure(8)*seg_nGC(8))/sum([seg_nGC(4); seg_nGC(8)]);
pre2    = (seg_measure(1)*seg_nGC(1) + seg_measure(10)*seg_nGC(10))/sum([seg_nGC(1); seg_nGC(10)]);
pre3    = (seg_measure(5)*seg_nGC(5) + seg_measure(12)*seg_nGC(12))/sum([seg_nGC(5); seg_nGC(12)]);
pre4    = (seg_measure(3)*seg_nGC(3) + seg_measure(11)*seg_nGC(11))/sum([seg_nGC(3); seg_nGC(11)]);

midT = (seg_measure(14)*seg_nGC(14) + seg_measure(15)*seg_nGC(15))/sum([seg_nGC(14); seg_nGC(15)]);

postdot2 = (seg_measure(22)*seg_nGC(22) + seg_measure(27)*seg_nGC(27))/sum([seg_nGC(22); seg_nGC(27)]);
postdot5 = (seg_measure(20)*seg_nGC(20) + seg_measure(23)*seg_nGC(23))/sum([seg_nGC(20); seg_nGC(23)]);
post1 = (seg_measure(21)*seg_nGC(21) + seg_measure(25)*seg_nGC(25))/sum([seg_nGC(21); seg_nGC(25)]);
post2 = (seg_measure(19)*seg_nGC(19) + seg_measure(28)*seg_nGC(28))/sum([seg_nGC(19); seg_nGC(28)]);
post3 = (seg_measure(17)*seg_nGC(17) + seg_measure(24)*seg_nGC(24))/sum([seg_nGC(17); seg_nGC(24)]);
post4 = (seg_measure(18)*seg_nGC(18) + seg_measure(26)*seg_nGC(26))/sum([seg_nGC(18); seg_nGC(26)]);

% Plot Pre
figB = figure();
set(figB, 'visible', 'off');
scatter([1 1 1 1 1 1], [predot2, predot5, pre1, pre2, pre3, pre4],  ...
        'filled', ...
        'MarkerFaceColor', seg_colors{i}, ...
        'MarkerEdgeColor',[0 0 0], ...
        'LineWidth', .5); hold on
text(1.05, predot2, '.2')
text(1.05, predot5, '.5') 
text(1.05, pre1, '1') 
text(1.05, pre2, '2') 
text(1.05, pre3, '3') 
text(1.05, pre4, '4')


% Plot Train
scatter(2, midT,  ...
        'filled', ...
        'MarkerFaceColor', seg_colors{i}, ...
        'MarkerEdgeColor',[0 0 0], ...
        'LineWidth', .5);
    
% Plot Post
scatter([3 3 3 3 3 3], [postdot2, postdot5, post1, post2, post3, post4],  ...
        'filled', ...
        'MarkerFaceColor', seg_colors{i}, ...
        'MarkerEdgeColor',[0 0 0], ...
        'LineWidth', .5); 
text(3.05, postdot2, '.2')
text(3.05, postdot5, '.5') 
text(3.05, post1, '1') 
text(3.05, post2, '2') 
text(3.05, post3, '3') 
text(3.05, post4, '4') 

% Connect the lines
plot([1, 3], [predot2, postdot2])
plot([1, 3], [predot5, postdot5])
plot([1, 3], [pre1, post1])
plot([1, 3], [pre2, post2])
plot([1, 3], [pre3, post3])
plot([1, 3], [pre4, post4])

% Cosmetics
title([measure, ' - Weighted Mean: Raw'])
xlim([.5 3.5])
xticks([1, 2, 3])
xticklabels({'Pre-Test', 'Training', 'Post-Test'})
xlabel('Segment')
ylabel(['Raw ' measure])

% More Notes
GCC_text_pre = {['.2: ' num2str(seg_nGC(2)) ', ' num2str(seg_nGC(7))]
            ['.5: ' num2str(seg_nGC(6)) ', ' num2str(seg_nGC(9))]
            ['1: ' num2str(seg_nGC(4)) ', ' num2str(seg_nGC(8))]
            ['2: ' num2str(seg_nGC(1)) ', ' num2str(seg_nGC(10))]
            ['3: ' num2str(seg_nGC(5)) ', ' num2str(seg_nGC(12))]
            ['4: ' num2str(seg_nGC(3)) ', ' num2str(seg_nGC(11))]
            };
        
GCC_text_post = {['.2: ' num2str(seg_nGC(22)) ', ' num2str(seg_nGC(27))]
            ['.5: ' num2str(seg_nGC(20)) ', ' num2str(seg_nGC(23))]
            ['1: ' num2str(seg_nGC(21)) ', ' num2str(seg_nGC(25))]
            ['2: ' num2str(seg_nGC(19)) ', ' num2str(seg_nGC(28))]
            ['3: ' num2str(seg_nGC(17)) ', ' num2str(seg_nGC(24))]
            ['4: ' num2str(seg_nGC(18)) ', ' num2str(seg_nGC(26))]
            };
text(1.5, max(ylim)*.9, GCC_text_pre)
text(2.5, max(ylim)*.9, GCC_text_post)

% Save as .pdf & .fig
print(figB,strrep(excel_file, '.xlsx', ['Weighted_Mean_Summary_Raw_' measure '.pdf']),'-dpdf', '-r300');
savefig(figB, strrep(excel_file, '.xlsx', ['Weighted_Mean_Summary_Raw_' measure '.fig']))


%% Figure C - Normalized Measure

% Calculate the normalized measure
dot2 = postdot2 / predot2;
dot5 = postdot5 / predot5;
one = post1 / pre1;
two = post2 / pre2;
three = post3 / pre3;
four = post4 / pre4;

% Plot Normaized measure
figC = figure();
set(figC, 'visible', 'off');
scatter([1, 2, 3, 4, 5, 6], [dot2, dot5, one, two, three, four],   ...
        'filled', ...
        'MarkerEdgeColor',[0 0 0], ...
        'LineWidth', .5); 
    
% Cosmetics
xlim([.5, 6.5])
hline(1, ':k')
xticklabels({'.2', '.5', '1', '2', '3', '4'})
xlabel('Frequency')
ylabel(['Norm ' measure])
title(['Norm ' measure ' of Post Test'])

% Save as .pdf & .fig
print(figC,strrep(excel_file, '.xlsx', ['Weighted_Mean_Summary_Norm_' measure '.pdf']),'-dpdf', '-r300');
savefig(figC, strrep(excel_file, '.xlsx', ['Weighted_Mean_Summary_Norm_' measure '.fig']))