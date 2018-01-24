function fixticks(scale)
% FIXTICKS(scale)
% Put tick marks outside figure, sizes them according to full figure

if ~exist('scale','var')
    scale = 1;
end
npoints = 2; 

h =  findall(gcf,'Type','axes');


% Get length of current axes
% pos = get(h(1),'Position');

% Based only on maximum VISIBLE axis, use special function 
for i= 1:length(h)
    tempUnits = get(h(i),'Units');

set(h(i),'Units','points');
pos = plotboxpos(h(i));

set(h(i),'TickLength',scale*npoints/max(pos(3:4))*[1 1]);

set(h(i),'TickDir','out')
set(h(i),'Units',tempUnits);
set(h(i),'Box','off')
end
drawnow;
