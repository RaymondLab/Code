% Hannah Payne
% raster.m
% Makes a raster plot
% 11/22/11

%{
raster(t) Plots vector of spike times t at a default height of 1.

raster(t,y) Plots spike times t at height y. If y is a scalar, all spikes are plotted at same height. If y is a vector (must be same length as t) spikes are plotted at corresponding height.

raster(t,y,height) Height specifies the length of the spike lines

rater(t,y,height,color) Color specifies the color of the lines

h = raster(t,y...) returns handle vector to the raster lines
%}

function h = raster(t, y, height, color)
    if nargin == 1
        y = 1;
    end
    if length(y) == 1
        y = y*ones(size(t));
    end
    if nargin < 3
        height = .8;
    end
    if nargin < 4
        color = 'k';
    end

    hold on;
    h=[];
    for i = 1:length(t)
        h(i) = line([t(i) t(i)], [y(i) - height/2 y(i)+height/2],'Color', color);
    end
   set(h, 'LineWidth', 1)
end

