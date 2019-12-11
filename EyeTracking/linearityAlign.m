function [lag maxVal] = linearityAlign(x, y)

for i = -2000:2000              
    if i < 0
        x2 = x((-i)+1:end);
        y2 = y(1:end+i);
    elseif i == 0
        x2 = x;
        y2 = y;
    else
        x2 = x(1:end-i);
        y2 = y((i)+1:end);
    end

    %fit = polyfit(x2,y2,1);
    %range = linspace(min(x2),max(x2),100);
    %yfit2 = fit(1)*range + fit(2);
    R2 = corrcoef(x2,y2);
    Rsq2(i+2001) = R2(1,2).^2;
end

plot(Rsq2);
maxVal = max(Rsq2);
MaxLoc = find(Rsq2 == max(Rsq2),1);
vline(MaxLoc)

lag = MaxLoc-2000;
title(num2str(lag));
drawnow