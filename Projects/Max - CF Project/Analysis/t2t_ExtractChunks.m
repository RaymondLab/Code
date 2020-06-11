function [csInfo] = t2t_ExtractChunks(csInfo, segment_ssfr, z)

chunkAs = [];
chunkBs = [];
chunkDiffs = [];

for i = 1:size(csInfo, 2)
    
    if ~csInfo(i).usable
        continue
    end
    
    window_e = z.comparisonWindowSize * z.sr_e;
    
    start_chunkA = csInfo(i).timeAbs_e - (window_e/2);
    end_chunkA   = csInfo(i).timeAbs_e + (window_e/2);
    
    start_chunkB = start_chunkA + z.cycleLen_e;
    end_chunkB   = end_chunkA + z.cycleLen_e;
    
    % double check everything went okay
    if start_chunkA < 0
        warning('Problem with chunk extraction: CS is on trial 1 and is too close to the begining')
        continue
    end       
    if (end_chunkA - start_chunkA) ~= window_e
        disp(num2str(end_chunkA - start_chunkA))
        warning('Problem with chunkA extraction: Rounding Error')
        continue
    end
    
    if (end_chunkB - start_chunkB) ~= window_e
        disp(num2str(end_chunkB - start_chunkB))
        warning('Problem with chunkB extraction: Rounding Error')
        continue
    end

    % extract segments of the ssfr and subtract
    csInfo(i).chunkA = segment_ssfr(start_chunkA:end_chunkA);
    csInfo(i).chunkB = segment_ssfr(start_chunkB:end_chunkB);
    csInfo(i).chunkDiff = csInfo(i).chunkB - csInfo(i).chunkA;
    
end

end
