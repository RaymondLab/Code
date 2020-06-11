function [r2] = linearityAlign(x, y)

for i = -4000:-100              
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
    R2 = corrcoef(x2,y2);
    r2(i+4001) = R2(1,2).^2;
end