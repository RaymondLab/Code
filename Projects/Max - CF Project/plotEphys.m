% plot ephys

Files = dir(cd);
Files(~contains({Files.name}, {'.mat'})) = [];

for i = 1:length(Files)
    figure()
    load(fullfile(Files(i).folder, Files(i).name))
    timeVec = 0:(1/50000):(length(ephysData)-1)/50000;
    plot(timeVec, ephysData);
    title(Files(i).name);
    disp(Files(i).name);
end
