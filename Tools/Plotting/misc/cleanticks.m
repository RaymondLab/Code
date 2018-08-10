function cleanticks(ax, nkeep, ah)
% CLEANTICKS clean up tick labels
%  CLEANTICKS   removes central tick labels from y axis 
%  CLEANTICKS('y')   removes central tick labels from y axis 
%  CLEANTICKS('x') removes central tick labels from x axis 
%  CLEANTICKS('x', nkeep) only keeps every 2nth tick

if ~exist('ax','var') || isempty(ax)
    ax = 'y';
end

if strcmpi(ax,'x')
    TickLabels = 'XTickLabel';
else
    TickLabels = 'YTickLabel';
end

if ~exist('ah','var')
ah = findobj(gcf,'Type','Axes');
end
for i = 1:numel(ah)
    
    origLabel = get(ah(i),TickLabels);    
    if ~iscell(origLabel)
        origLabel = mat2cell(origLabel, ones(size(origLabel,1),1),size(origLabel,2));
    end
    newLabel = origLabel;
    
    if ~exist('nkeep','var') || isempty(nkeep)
        newLabel(2:end-1) = {''};
        newLabel(strcmp(origLabel,'0')) = {'0'};
    else
        newLabel(1:end) = {''};
        newLabel(1:nkeep:end) = origLabel(1:nkeep:end);
    end    
    
    set(ah(i), TickLabels, newLabel)
    
end