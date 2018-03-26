function IBW_List = IBWconnect(location)

%% set up
fprintf('Creating Concatenated Data File...\n\n')
cd(location);
fileList = dir;
IBW_List = zeros(length(fileList),10000);
len = length(fileList);

%% Cycle through each ibw file and make a matrix of thier data
for i = 1:floor(length(fileList))
    entry = fileList(i);
    if contains(entry.name, '.ibw')
        IBW_data = IBWread(strcat(entry.folder, '\', entry.name));
        IBW_List(i,:) = IBW_data.y;
        fclose('all');
        (i / len) * 100
    end
end

%% reformat data into  one long vectors
IBW_List = IBW_List';
IBW_List = IBW_List(:);
IBW_List(IBW_List== 0) = [];
