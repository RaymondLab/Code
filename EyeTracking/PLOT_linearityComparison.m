function PLOT_linearityComparison(mag_all, mag_chunks, vid_aligned, mag_aligned, keep, c, sacStarts, sacStops)

figure();
www = tight_subplot(2,2,[.055 .025],[.04 .025],[.03 .03]);

%%
axes(www(1))
scatter(vid_aligned(keep), mag_aligned(keep), 4, c(keep), '.'); hold on
colormap hsv
plot(mag_all.yfit', mag_all.range', 'r', 'lineWidth', 1);

for i = 1:length(mag_chunks)
    plot(mag_chunks(i).yfit', mag_chunks(i).range', 'k', 'lineWidth', 1); hold on
end


for i = 1:length(mag_chunks)
    yfit_Norm(i) = mag_chunks(i).yfit_Norm(end);
    range_Norm(i) = mag_chunks(i).range_Norm(end);
    lengths(i) = sqrt(yfit_Norm(i)^2 + range_Norm(i)^2);
end

% Make unit vectors
yfit_Norm_uv = yfit_Norm ./ lengths;
range_Norm_uv = range_Norm ./ lengths;
mag_all.yfit_Norm_uv = mag_all.yfit_Norm(end)   / sqrt(mag_all.yfit_Norm(end)^2 + mag_all.range_Norm(end)^2);
mag_all.range_Norm_uv = mag_all.range_Norm(end) / sqrt(mag_all.yfit_Norm(end)^2 + mag_all.range_Norm(end)^2);

% Scale by number of datapoints
yfit_Norm_scaled = yfit_Norm_uv' .* (sacStops - sacStarts);
range_Norm_scaled = range_Norm_uv' .* (sacStops - sacStarts);
mag_all.yfit_Norm_scaled = mag_all.yfit_Norm_uv * sum(keep);
mag_all.range_Norm_scaled = mag_all.range_Norm_uv * sum(keep);

% Mean of scaled datapoints
yfit_Norm_scaled_Mean = mean(yfit_Norm_scaled);
range_Norm_scaled_Mean = mean(range_Norm_scaled);
mag_all.yfit_Norm_scaled_Mean = mean(mag_all.yfit_Norm_scaled);
mag_all.range_Norm_scaled_Mean = mean(mag_all.range_Norm_scaled);

% Norm of mean of scaled datapoints
yfit_Norm_scaled_Mean_uv = yfit_Norm_scaled_Mean(end) ./ sqrt(yfit_Norm_scaled_Mean(end)^2 + range_Norm_scaled_Mean(end)^2);
range_Norm_scaled_Mean_uv = range_Norm_scaled_Mean ./ sqrt(yfit_Norm_scaled_Mean(end)^2 + range_Norm_scaled_Mean(end)^2);
mag_all.yfit_Norm_scaled_Mean_uv = mag_all.yfit_Norm_scaled_Mean(end) ./ sqrt(mag_all.yfit_Norm_scaled_Mean(end)^2 + mag_all.range_Norm_scaled_Mean(end)^2);
mag_all.range_Norm_scaled_Mean_uv = mag_all.range_Norm_scaled_Mean(end) ./ sqrt(mag_all.yfit_Norm_scaled_Mean(end)^2 + mag_all.range_Norm_scaled_Mean(end)^2);

%%
axes(www(2))
ang=0:0.01:2*pi; 

% groups
plotv([yfit_Norm_uv; range_Norm_uv], 'k'); hold on
scatter(yfit_Norm_uv, range_Norm_uv, 'filled', 'k');
plotv([yfit_Norm_uv*-1; range_Norm_uv*-1], 'k');
scatter(yfit_Norm_uv*-1, range_Norm_uv*-1, 'filled', 'k');
% group average
plotv([mean(yfit_Norm_uv); mean(range_Norm_uv)], 'm');
scatter(mean(yfit_Norm_uv), mean(range_Norm_uv), 'filled', 'm');
plotv([mean(yfit_Norm_uv*-1); mean(range_Norm_uv*-1)], 'm');
scatter(mean(yfit_Norm_uv*-1), mean(range_Norm_uv*-1), 'filled', 'm');
% Scaled average
plotv([yfit_Norm_scaled_Mean_uv; range_Norm_scaled_Mean_uv], 'c');
scatter(yfit_Norm_scaled_Mean_uv,range_Norm_scaled_Mean_uv, 'filled', 'c');
plotv([yfit_Norm_scaled_Mean_uv*-1; range_Norm_scaled_Mean_uv*-1], 'c');
scatter(yfit_Norm_scaled_Mean_uv*-1, range_Norm_scaled_Mean_uv*-1, 'filled', 'c');
% all data
plotv([mag_all.yfit_Norm_uv; mag_all.range_Norm_uv], 'r');
plotv([mag_all.yfit_Norm_uv*-1; mag_all.range_Norm_uv*-1], 'r');
scatter(mag_all.yfit_Norm_uv, mag_all.range_Norm_uv, 'filled', 'r');
scatter(mag_all.yfit_Norm_uv*-1, mag_all.range_Norm_uv*-1, 'filled', 'r');
% plot circle for reference 
plot(cos(ang),sin(ang));
vline(0, ':k');
hline(0, ':k');

xlim([max(abs(yfit_Norm_uv))*-1 max(abs(yfit_Norm_uv))]);
ylim([max(abs(range_Norm_uv))*-1 max(abs(range_Norm_uv))]);
title('Inter-Saccade Fit Lines: Slopes')

%% Scaled by magnet range
axes(www(3))

plotv([yfit_Norm; range_Norm], 'k'); hold on
scatter(yfit_Norm , range_Norm, 'filled', 'k');

plotv([mean(yfit_Norm); mean(range_Norm)], 'm');
scatter(mean(yfit_Norm) , mean(range_Norm), 'filled', 'm');

scatter(mag_all.yfit_Norm(end) , mag_all.range_Norm(end), 'filled', 'r');
plotv([mag_all.yfit_Norm; mag_all.range_Norm], 'r');

vline(0, ':k');
xlim([min(yfit_Norm) max(yfit_Norm)]);
ylim([0 max(range_Norm)]);
title('Inter-Saccade Fits: length is scaled by volatge range of magnet data')

%% Scale by Number of Points
axes(www(4))

scatter(yfit_Norm_scaled, range_Norm_scaled, 'filled', 'k'); hold on
plotv([yfit_Norm_scaled'; range_Norm_scaled'], 'k')

plotv([yfit_Norm_scaled_Mean; range_Norm_scaled_Mean], 'c');
scatter(yfit_Norm_scaled_Mean, range_Norm_scaled_Mean, 'filled', 'c')

plotv([mag_all.yfit_Norm_scaled; mag_all.range_Norm_scaled], 'r')
scatter(mag_all.yfit_Norm_scaled , mag_all.range_Norm_scaled, 'filled', 'r');

vline(0, ':k')
xlim([min(yfit_Norm_scaled) max(yfit_Norm_scaled)])
ylim([0 max(range_Norm_scaled)])
title('Inter-Saccade Fits: length is scaled by number of points')

