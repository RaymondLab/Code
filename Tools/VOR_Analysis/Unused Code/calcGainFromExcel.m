%% import data
clear;clc;close all
[A, B, C] = xlsread('Z:\1_Maxwell_Gagnon\ProjectData_Amin\Exp-Delta07-1 hz GU\Exp-Delta07-Ch01-18_03012018\Exp-Delta07-Ch01-18_03012018.xlsx');
rawEyeGains = A(:,9);
freq = A(:,2);
goodPercent = round((1 - A(:,17)) * 100);
meanWeightedGains = [];

%% calc mean weighted gains
% .2 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([2 7]) .* goodPercent([2 7])) ./ sum(goodPercent([2 7]))];
% .5 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([6 9]) .* goodPercent([6 9])) ./ sum(goodPercent([6 9]))];
% 1 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([4 8]) .* goodPercent([4 8])) ./ sum(goodPercent([4 8]))];
% 2 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([1 10]) .* goodPercent([1 10])) ./ sum(goodPercent([1 10]))];
% 3 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([5 12]) .* goodPercent([5 12])) ./ sum(goodPercent([5 12]))];
% 4 Hz before
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([3 11]) .* goodPercent([3 11])) ./ sum(goodPercent([3 11]))];

% 1Hz Training part 1
meanWeightedGains = [meanWeightedGains; rawEyeGains(13)];

% 1Hz middle of testing
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([14 15]) .* goodPercent([14 15])) ./ sum(goodPercent([14 15]))];

% 1Hz training part 2
meanWeightedGains = [meanWeightedGains; rawEyeGains(16)];

% .2 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([22 27]) .* goodPercent([22 27])) ./ sum(goodPercent([22 27]))];
% .5 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([20 23]) .* goodPercent([20 23])) ./ sum(goodPercent([20 23]))];
% 1 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([21 25]) .* goodPercent([21 25])) ./ sum(goodPercent([21 25]))];
% 2 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([19 28]) .* goodPercent([19 28])) ./ sum(goodPercent([19 28]))];
% 3 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([17 24]) .* goodPercent([17 24])) ./ sum(goodPercent([17 24]))];
% 4 Hz after
meanWeightedGains = [meanWeightedGains; sum(rawEyeGains([18 26]) .* goodPercent([18 26])) ./ sum(goodPercent([18 26]))];
placements = [1 1 1 1 1 1 2 3 4 5 5 5 5 5 5];
scatter(placements, meanWeightedGains)

figure(2)
hold on
plot[1 5], meanWeightedGains([1 10]), '-o')
plot[1 5], meanWeightedGains([2 11]), '-o')
plot[1 5], meanWeightedGains([3 12]), '-o')
plot[1 5], meanWeightedGains([4 13]), '-o')
plot[1 5], meanWeightedGains([5 14]), '-o')
plot[1 5], meanWeightedGains([6 15]), '-o')

plot(meanWeightedGains(2), meanWeightedGains(7), '-o')
plot(meanWeightedGains(3), meanWeightedGains(8), '-o')
plot(meanWeightedGains(4), meanWeightedGains(9), '-o')



