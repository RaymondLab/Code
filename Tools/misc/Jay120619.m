Files = dir(['G:\My Drive\Hannah''s Server Data\1_Hannah_Payne\magmouse\data', '\**\*']);

freeFiles = contains({Files.name}, {'free'});
freeFiles = Files(freeFiles);

freeFiles = freeFiles(contains({freeFiles.name}, '.smr'));


for i = 1:size(freeFiles, 1)
    disp(freeFiles(i).name)
    name = freeFiles(i).name;
    folder = freeFiles(i).folder;
    
    % Load data from Spike2
    chanlist = readSpikeFile(fullfile(folder,name),[]);
    chanindsAll = [chanlist.number];
    chanlabels = {'hhpos','htpos','hepos1','hepos2','hepos','vepos','hhvel','htvel','htvel','TTL3','TTL4'};
    chaninds = find(      arrayfun(@(x) any(strcmp(x.title,chanlabels)),chanlist)     );
    data = importSpike(fullfile(folder,name),chanindsAll(chaninds));

    % Save the head data
    
    disp(data(5).chanlabel)
    disp(data(2).chanlabel)
    
    hhvel = data(5).data;
    hhpos = data(2).data;
    
end
