function decompressed = openmaestro(filename)
% OPENMAESTRO reads in the raw analog electrophysiology file sepcified by
% filename and outputs the decompressed signal
% 
% Hannah Payne
% Raymond lab 3/28/13
%
% Algorithm based on https://sites.google.com/a/srscicomp.com/maestro/data-analysis/data-file-format/data-compression-algorithm
% I exclude some artifacts (byte pattern 1 0 0 0) and start 

fid = fopen(filename);

% Read the raw data
compressed = fread(fid,'uint8=>uint16');

% Init
i = 0;
nBytes = 17*1024; % Number of bytes to skip at the beginning 

% Remove a weird artifact thing that I don't understand - 1-0-0-0 pattern
removepnts = strfind(compressed',uint16([1 0 0 0]));
compressed([removepnts removepnts+1 removepnts+2 removepnts+3])=[];

while nBytes < (length(compressed)-1)
    
    nBytes = nBytes+1;
    i = i+1;
    
    currbyte = compressed(nBytes);

    % Double byte 
    if currbyte>127        
        nBytes = nBytes+1;
        secondbyte = compressed(nBytes);
        firstbyte = bitand(currbyte, 127);
        firstbyte = bitshift(firstbyte,8);
        netbyte(i) = int16(firstbyte + secondbyte)- 4096;
        
    % Single byte
    else 
        netbyte(i) = int16(currbyte) - 64;
    end          
end


%% Error checking
errors = find(netbyte>1000); % Occasionally jumps a lot
for i = 1:length(errors)
    netbyte(errors(i))=0;
end
% Take cumulative sum
decompressed = cumsum(double(netbyte));

% Scale factor - not sure where this came from. Websit
% decompressed = decom pressed * 4.8828125/2^12;
decompressed = decompressed * 20/2^12; % 20 mv P-P input, 12 bits

% Plot
%figure; plot(decompressed)
