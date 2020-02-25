function plot_individualExampleCheck(chunkAs, chunkBs, chunkDiffs, segData, csInfo, z, windowSize)

csInfo(~csInfo(:,1),:) = [];


for i = 1:size(chunkAs,2)
    
    csTime_beh = round(csInfo(i,2) * z.sr_b);
    
    start_chunkA_beh = csTime_beh - ((windowSize/2)*z.sr_b);
    end_chunkA_beh = csTime_beh + ((windowSize/2)*z.sr_b);
    
    start_chunkB_beh = start_chunkA_beh + z.cycleLen_b;
    end_chunkB_beh = end_chunkA_beh + z.cycleLen_b;
    
    figure()
    Summary = tight_subplot(3,2,[.03 .03],[.03 .03],[.03 .03]);

    axes(Summary(1))
    title('ChunkA: Stim')

    axes(Summary(3))
    title('ChunkA: Ephys')
    plot(chunkAs(:,i))


    axes(Summary(2))
    title('ChunkB: Stim')

    axes(Summary(4))
    title('ChunkB: Ehpys')
    plot(chunkBs(:,i))


    axes(Summary(5))
    title('Difference')

end

end
