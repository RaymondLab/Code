%% plotVOR.m
% plots the results of a runVOR analysis
%
% plotVOR(results)  plots all the results
% plotVOR(results, 'vord') plots only the VORD trials
% plotVOR(results, mode, 1) normalizes the data to a gain of 1
%    Possible modes = 'cal', 'all', 'vord','drum','okr'
%

function h = plotVOR(results, type, norm)

%% find the eye gain data
% gain = results.data(:,strcmpi('eyeHgain',results.header));
eyeamp = results.data(:,strcmpi('eyeHamp',results.header));
headamp = results.data(:,strcmpi('headamp',results.header));
% gain2 = eyeamp./headamp;
t = results.data(:,1);

% Identify VORD trials
VORDmask = ~cellfun(@isempty,regexp(results.labels,'VORD'));

switch norm    
    case 0  % Plot eye amplitude
        gain = eyeamp;
        ylims = [0 max(gain(VORDmask))*1.1];
        ylabels ='Eye amplitude (deg/s)';
    case 1  % Plot eye gain
        gain = eyeamp./headamp;
        ylims = [0 2*max(gain)];
        ylabels = 'VOR gain';
    case 2  % Plot normalized gain
        gain = eyeamp/mean(eyeamp(t(:)==0&VORDmask(:)));
        ylims = [0 2];
        ylabels = 'VOR learning (normalized)';
end

clf
conds = unique(type);
colorsAll = {'k','w','g','m'};
colors = colorsAll(1:length(conds));

plot(t(VORDmask),gain(VORDmask),'-k'); hold on; 

ylims(2) = max(gain)*1.1; if isnan(ylims(2)); ylims = [0 1]; end
hold on;
h = [];
for i = 1:length(conds)
    mask = ~cellfun(@isempty,regexp(results.labels,conds{i}));
    tMask = t(mask);
    gainMask = gain(mask);
    h(i) = scatter(tMask,gainMask,60,colors{i},'fill','MarkerEdgeColor','k');
end
hold on; plot([0 35],[mean(gain(VORDmask & t==0)) mean(gain(VORDmask & t==0))],'-.k')
xlabel('Time (min)')
legend(h,conds,4,'EdgeColor','w')
  
ylabel(ylabels)
ylim(ylims)

box off



