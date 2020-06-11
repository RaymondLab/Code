function [cycleMat, cycleMean] = VOR_breakTrace(cycleLength, startpt, vector)

[cycleMat, ~] = vec2mat(vector(startpt:end), cycleLength, NaN);

% Remove first 5 cycles (to account for drift)
%cycleMat(1:5,:) = [];

% Remove final (partial) cycle
cycleMat(end,:) = [];

% Calculate Cycles Mean
cycleMean = nanmean(cycleMat, 1);