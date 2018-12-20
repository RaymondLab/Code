function VOR_Summary(measure, excel_file, norm )
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
seg_groups = T.TimePoint;
seg_measure = T{:,strcmpi(T.Properties.VariableNames, measure)};

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
%plot(seg_groups(~strcmpi(seg_labels,'VORD')), seg_measure(~strcmpi(seg_labels,'VORD')), 'color', [12 195 82] ./ 255)

% Universal Cosmetics
xlim([min(seg_groups)-.5, max(seg_groups)+.5])
%xticks(unique(seg_groups))
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
legend(scatterHandles([1 4]), uniqueSegs); % TODO Hack-y

%% Save Figure
% save as .pdf
print(sumFig,strrep(excel_file, '.xlsx', ['_Summary_' char(string(norm)) '_' measure '.pdf']),'-dpdf', '-r300');
% Save as .fig
savefig(sumFig, strrep(excel_file, '.xlsx', ['_Summary_' char(string(norm)) '_' measure '.fig']))

A = gcf;
for i = 1:length(A.Children(2).Children)
    try
        A.Children(2).Children(i).SizeData = .1;
    catch
    end
end

end