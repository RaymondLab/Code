function writeTxt4Spike2(filename, fs, dataIn)   

%% Write to file for Spike2 to read
fid = fopen(filename, 'w');
nchans = size(dataIn,2);
nt = size(dataIn,1);

% First line: length, samplerate, nchans
fprintf(fid, '%i %.2f %i\n', nt, fs, nchans);

% Other lines: data points
fprintf(fid, [repmat('%i ',1,nchans) '\n'], round(dataIn)');
fclose(fid);