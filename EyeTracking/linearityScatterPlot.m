function linearityScatterPlot(vec1, vec2, keep, c)

x = vec1(keep);
y  = vec2(keep);
fit = polyfit(x,y,1);
range = linspace(min(x),max(x),100);
yfit = fit(1)*range + fit(2);
R = corrcoef(x,y);
Rsq = R(1,2).^2;


scatter(vec1(keep), vec2(keep), 4, c(keep), '.'); hold on
plot(range, yfit, 'k', 'lineWidth', 2);
title(['chan1 r^2: ', num2str(Rsq)])
colormap hsv;
text(mean(ylim), min(xlim)*.9, ['r^2: ', num2str(Rsq)])




            