function [data,dataSubset,keystrokes] = importDatObject(fullfilename)

chanList = readSpikeFile(fullfilename,[]);
chanIndAll = [chanList.number];
chanInd = find(      arrayfun(@(x) any(strcmp(x.title,{'Keyboard'})),chanList)     );
chVind = find(      arrayfun(@(x) any(strcmp(x.title,{'hhvel'})),chanList)     );
chPind = find(      arrayfun(@(x) any(strcmp(x.title,{'hhpos'})),chanList)     );
drumPind = find(      arrayfun(@(x) any(strcmp(x.title,{'htpos'})),chanList)     );
LEDind = find(      arrayfun(@(x) any(strcmp(x.title,{'TTL1'})),chanList)     );
eyeCh1ind = find(      arrayfun(@(x) any(strcmp(x.title,{'hepos1'})),chanList)     );
eyeCh2ind = find(      arrayfun(@(x) any(strcmp(x.title,{'hepos2'})),chanList)     );
keystrokes = importSpike(fullfilename,chanIndAll(end));
data = importSpike(fullfilename,chanIndAll(:));
dataSubset = [chVind chPind drumPind LEDind eyeCh1ind eyeCh2ind];