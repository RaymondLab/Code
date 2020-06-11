function plot_allChanOverview(recData, segInfo, z)

figure('Position', [1 41 1920 1083]);
ephysPlot = tight_subplot(length(recData),1,[.03 .03],[.03 .03],[.03 .03]);
for j = 1:length(recData)
    
    try
        z.cycleLen_e = (recData(j).samplerate) * 1/expmtFreq;
        z.startpt_e = 1;
        [cycleMat, cycleMean] = VOR_breakTrace(z.cycleLen_e, z.startpt_e, recData(j).data);
    catch
    end
    
    axes(ephysPlot(j))
    
    try
        z.segTime_ssfr = dattime(recData(1,j));
        plot(z.segTime_ssfr, recData(j).data)
        title(recData(j).chanlabel)
    catch
    end
    
    if j == 1
        title([segInfo.name recData(j).chanlabel])
    end
end

end