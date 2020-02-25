function [chunkAs, chunkBs, chunkDiffs] = t2t_ExtractChunks(csInfo, segment_ssfr, z, windoww)

chunkAs = [];
chunkBs = [];
chunkDiffs = [];

for i = 1:size(csInfo, 1)
    
    if ~csInfo(i,1)
        continue
    end
    
    % convert all values from seconds to sample ephys sample counts
    csStartTimeInSrE = round(csInfo(i,2) * z.sr_e);
    windowInSrE = windoww * z.sr_e;
    cycleLenInSrE = round(z.cycleLen_seconds * z.sr_e);
    
    start_chunkA = csStartTimeInSrE - (windowInSrE/2);
    end_chunkA   = csStartTimeInSrE + (windowInSrE/2);
    
    start_chunkB = start_chunkA + cycleLenInSrE;
    end_chunkB   = end_chunkA + cycleLenInSrE;
    
    % double check everything went okay
    if start_chunkA < 0
        warning('Problem with chunk extraction: CS is on trial 1 and is too close to the begining')
        continue
    end       
    if (end_chunkA - start_chunkA) ~= windowInSrE
        disp(num2str(end_chunkA - start_chunkA))
        warning('Problem with chunk extraction: Rounding Error')
        continue
    end
    
    if (end_chunkB - start_chunkB) ~= windowInSrE
        disp(num2str(end_chunkB - start_chunkB))
        warning('Problem with chunk extraction: Rounding Error')
        continue
    end

    % extract segments of the ssfr and subtract
    chunkA = segment_ssfr(start_chunkA:end_chunkA);
    chunkB = segment_ssfr(start_chunkB:end_chunkB);
    chunkAs = [chunkAs chunkA];
    chunkBs = [chunkBs chunkB];
    
    chunkDiffs = [chunkDiffs chunkB - chunkA];

    
    

end

end
