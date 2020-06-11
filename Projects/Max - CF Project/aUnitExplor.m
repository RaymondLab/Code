%% Find Correct files
clear;clc;close all;

currentDirectory = cd;
allFiles = dir([currentDirectory, '\**\**']);

%%
relevantFiles = allFiles(~[allFiles.isdir]);
relevantFiles = relevantFiles(contains({relevantFiles.name}, {'.'}));
%relevantFiles = relevantFiles(contains({relevantFiles.name}, {'cs'}));


%%
for i = 1:length(relevantFiles)
    disp([num2str(i), ':  ', relevantFiles(i).name])
    fileLoc = fullfile(relevantFiles(i).folder, relevantFiles(i).name);
    
    % Is it a full recording? 
    try 
        %chanData = cx2dat(fileLoc, 6);
        %disp(['Full Channel Data: ', relevantFiles(i).name]);
    catch 
    end 

    % Is it a single Vector?
    try
        dataVector = openmaestro(fileLoc);
        disp(['Single Channel Data: ', relevantFiles(i).name]);
    catch
    end
    fclose('all');
end



%% Clean Table
[dataTable] = readtable('G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx');

%%
for i = height(dataTable):-1:1
    

    if sum(contains(dataTable.name, dataTable.name(i))) > 1
        

        if isempty(dataTable.behaviorMat{i})
            disp(dataTable.name{i})
            dataTable(i,:) = [];
        else
            %disp(dataTable.name{i})
        end
    end
end

%%
writetable(dataTable, 'G:\My Drive\Expmt Data\Max\Climbing Fiber Project\ExperimentMetadata_C.xlsx')
