function saveSepFigures( fileType, location )
%% Save each open figure as the specified file type in a specified location
%
%
%
% Maxwell Gagnon 11/17/2017

% This returns the list of all open figures
figHandles = findobj('Type', 'figure');


% Loop through each figure and save each
for i = 1:length(figHandles)
    
    % Nam each file after the Title of the figure    
    h = get(gca,'Title');
    figureTitle = get(h,'String');
    if contains(figureTitle,':')
        figureTitle = strrep(figureTitle, ':','')
    end
    
    
    completeFileName = strcat(figureTitle, '_', string(figHandles(i).Number), fileType);
    fprintf('\n%s', completeFileName)
    
    %saveas(figHandles(i), char(completeFileName))
    print('-fillpage',char(completeFileName),'-dpdf', '-r300');
    
    
    
end

fprintf('\n\nFinished!\n')
fprintf('%d %s files saved at: \n%s\n\n', length(figHandles), fileType, location)


