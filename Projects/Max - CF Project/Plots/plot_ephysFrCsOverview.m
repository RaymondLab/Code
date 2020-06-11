function plot_ephysFrCsOverview(recData, z, segment_ssfr)

figure('Position', [2 557 958 439])
FREphys = tight_subplot(2,1,[.05 .01],[.03 .03],[.01 .01]);
axes(FREphys(1));

plot(z.segTime_ssfr, segment_ssfr)
if ~isempty(recData(9).data)
    vline(recData(9).data);
end

axes(FREphys(2));
plot(z.segTime_e, recData(10).data)
if ~isempty(recData(9).data)
    vline(recData(9).data);
end

linkaxes(FREphys, 'x');

end