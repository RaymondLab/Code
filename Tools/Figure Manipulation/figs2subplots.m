function newfig = figs2subplots( name , tiling , arr )
% FIGS2SUBLPLOTS Combine axes in many figures into subplots in one figure
%
%   The syntax:
%
%       >> newfig = figs2subplots(handles,tiling,arr);
%
%   creates a new figure with handle "newfig", in which the axes specified
%   in vector "handles" are reproduced and aggregated as subplots.
%
%   Vector "handles" is a vector of figure and/or axes handles. If an axes
%   handle is encountered, the corresponding axes is simply reproduced as
%   a subplot in the new figure; if a figure handle is encountered, all its
%   children axes are reproduced as subplots in the figure.
%
%   Vector "tiling" is an optional subplot tiling vector of the form
%   [M N], where M and N specify the number of rows and columns for the
%   subplot tiling. M and N correspond to the first two arguments of the
%   SUBPLOT command. By default, the tiling is such that all subplots are
%   stacked in a column.
%
%   Cell array "arr" is an optional subplot arrangement cell array. For
%   the k-th axes handle encountered, the subplot command issued is
%   actually:
%
%       subplot(tiling(1),tiling(2),arr{k})
%
%   By default, "arr" is a cell array {1,2,...}, which means that each axes
%   found in the figures is reproduced in a neatly tiled grid.
%
%   Example:
%
%       figs2subplots([a1 a2 a3],[2 2],{[1 3],2,4})
%
%   copies the three axes a1, a2 and a3 as subplots in a new figure with a
%   2x2 tiling arangement. Axes a1 will be reproduced as a subplot
%   occupying tiles 1 and 3 (thus covering the left part of the figure),
%   while axes a2 will be reproduced as a subplot occupying tile 2 (upper
%   right corner) and a3 occupying tile 4 (lower right corner).

%   Original version by Fran�ois Bouffard (fbouffard@gmail.com)
%   Legend copy code by Zoran Pasaric (pasaric@rudjer.irb.hr)
%   further modifications made by Max Gagnon (maxwellg@stanford.edu) 12/17
% Parsing handles vector

% modified by Maxwell Gagnon 12/17


handles = findobj('Type', 'figure');

% Do not include any GUI's in the subplot
for ii = 1:length(handles)
    if strcmp(handles(ii).Name, 'VOR_Analysis')
        handles(ii) = [];
        break
    end
end

av = [];
for k = length(handles):-1:1
    if strcmp(get(handles(k),'Type'),'axes')
        av = [av handles(k)];
    elseif strcmp(get(handles(k),'Type'),'figure');
        fc = get(handles(k),'Children');
        for j = length(fc):-1:1
            if strcmp(get(fc(j),'Type'),'axes') && ~strcmp(get(fc(j),'Tag'),'legend')
                av = [av fc(j)];
            elseif strcmp(get(fc(j),'Type'),'polaraxes') && ~strcmp(get(fc(j),'Tag'),'legend')
                av = [av fc(j)];
            end;
        end;
    end;
end;

% % --- find all legends
% legends = findobj('Type','legend');
% 
% % Extract Strings from each legend with thier figure number
% for iii = 1:length(legends)
%     legend_strings{iii} = legends(iii).String;
%     legend_strings_loc(iii) = legends(iii).Parent.Number;
% end


% Setting the subplots arrangement
Na = length(av);
if nargin < 2
    tiling = [Na 1];
    Ns = Na;
else
    Ns = prod(tiling);
end;

if nargin < 3
    arr = mat2cell((1:Ns)',ones(1,Ns));
end;
if ~iscell(arr)
    error('Arrangement must be a cell array');
end;

% Creating new figure
da = zeros(1,Ns);
newfig = figure();
hasLegend = zeros(1,min(Ns,Na));
for k = 1:min(Ns,Na)
    da(k) = subplot(tiling(1),tiling(2),arr{k});
    na = copyobj(av(k),newfig);
    na.FontSize = 7;
    na.TitleFontSizeMultiplier = 1.7;
    na.Box = 'off';
    na.XLabel.Position = [23.3790 -209.1040 -5.0000]
    
    try
        na.Children(1).FontSize = 6;
        na.Children(2).FontSize = 6;
        a.Children.Children(1).SizeData = 10;
    catch
    end
    try
        na.Children(2).SizeData = 1;
        na.Children(3).SizeData = 1;
    catch
    end
    
%     % does it have a legend?
%     original_fig = get(av(k));
%     if isprop(original_fig.Legend, 'String')
%         hasLegend(k) = 1;
%     end

    set(na,'Position',get(da(k),'Position'));

    % Produce legend if it exists in original axes
    try
        [ii jj] = ismember(av(k),hLegParAxes);
        if(jj>0)
            axes(na);
            legend(hLegString{jj});
        end
    catch
    end
    delete(da(k));
end

A = figure(newfig);

% % WIP!!!!!
% % finally, add back in the legends to each fig that originally had one
% a = length(legend_strings);
% hasLegend = fliplr(hasLegend);
% for ggg = length(hasLegend):-1:1
%     if hasLegend(ggg) == 1
%        legend(A.Children(ggg), legend_strings{a})
%        A.Children(ggg).FontSize = 1;
%        %A.Children(ggg).Position
%        Pos1 = A.Children(ggg+1).Position(1) + (6 * A.Children(ggg+1).Position(4));
%        Pos2 = A.Children(ggg+1).Position(2) + (.1 * A.Children(ggg+1).Position(3));
%        Pos3 = A.Children(ggg+1).Position(4) / 300;
%        Pos4 = A.Children(ggg+1).Position(3) / 300;
%        
%        A.Children(ggg).Position = [Pos1 Pos2 Pos3 Pos4];
%        %A.Children(ggg).Position
%        
%        a = a - 1;      
%     end
% end


% set up the export nicely
A.PaperSize = [20 50];
A.PaperOrientation = 'portrait';
slots = tiling(1) * tiling(2);
% Save as PDF
print(A, '-fillpage',[name '.pdf'],'-dpdf', '-r300');
% Save as Fig
figName = [name '.fig'];
savefig(A, figName)

% let user know if not all figures were added to the subplot/export
fprintf('\n\nThere are %d figures open, and there are %d in the subplot\n\n', length(handles), slots)

if length(handles) > slots
    fprintf('Not all figures displayed! There is only room for %d figures\n', slots)
end
