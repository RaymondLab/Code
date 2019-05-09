function [controlFit] = controlFit (dat1, dat2)

reg = polyfit(dat2, dat1, 1);  %dat1 is signal, dat2 is control

a = reg(1);
b = reg(2);

controlFit = a.*dat2 + b;