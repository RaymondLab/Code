function [h, hFill] = fillerror(x,mean,err,c,lineon, lighten,varargin)
% h = fillerror(x,mean,error,c,lineon, lighten,varargin)
%
% INPUTS
% x - x positions to plot
% mean - y positions to plot (usually the mean)
% error - width of error bars ie SEM
% c - optional color ('r' etc). Will be lightened
% lineon - include the mean line
% Include other param value pairs to format the line

% Hannah Payne 2012

% Columnize everything
x = x(:);
mean = mean(:);
if size(err,1)<size(err,2)
    err = err';
end
if size(err,2)==1
    err = [-abs(err) err];
end
if ~exist('lineon','var')  || isempty(lineon);  lineon  = 1; end
if ~exist('c','var');     c = 'k';   end

% To sort in order of x
% [x, temp] = sort(x);
% mean = mean(temp);
% err = err(temp,:);


err(isnan(err)) = 0;
% Lighten the color
color = colorspec(c);

if (exist('lighten','var') && ~isempty(lighten) && lighten) || ~exist('lighten','var') 
color = (1-(1-color)*.5);
end

plotx = [x; flipud(x)];
ploty = [mean+err(:,1); flipud(mean+err(:,2))]; 
ploty(isnan(ploty)) = 0;

% Plot it
if all(abs(err)<eps*10)
    ploty = NaN(size(ploty));
end
h = patch(plotx,ploty,color,'EdgeColor','none',varargin{:});
% h = fill(plotx,ploty,color,'EdgeColor','none');
% set(h,'FaceAlpha',.5) %***

% Plot line
if lineon
    hFill = h;
    h = line(x,mean, 'Color',c,varargin{:});
end

% box off

% return the actual RGB triplet for colorspec string
function RGB = colorspec(C)

if isnumeric(C)
    RGB = C;
elseif iscell(C)
    for i = 1:length(C)
	c = C{i};
	RGB(i,:) = rem(floor((strfind('kbgcrmyw', c) - 1) * [0.25 0.5 1]), 2);
    end
else
    RGB = rem(floor((strfind('kbgcrmyw', C) - 1) * [0.25 0.5 1]), 2);
end
	