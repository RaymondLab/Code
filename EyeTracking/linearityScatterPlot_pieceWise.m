function data = linearityScatterPlot_pieceWise(vec1, vec2, starts, stops, c, keep)

[data.all_Rsq, data.all_slope, data.all_range, data.all_yfit] = linearityScatterPlot(vec1, vec2, keep, c);

%% Calculate needed values
for i = 1:length(starts)
    
    data.chunk(i) = starts(i):stops(i);
    
    data.vec1Chunk(i) = vec1(data.chunk);
    data.vec2Chunk(i) = vec2(data.chunk);

    data.fit(i,:) = polyfit(data.vec1Chunk,data.vec2Chunk,1);
    data.range(i,:) = linspace(min(data.vec1Chunk),max(data.vec1Chunk),100);
    data.yfit(i,:) = data.fit(i,1)*data.range(i,:) + data.fit(i,2);
    data.slope(i) = data.fit(i,1);
    data.R = corrcoef(data.vec1Chunk,data.vec2Chunk);
    data.Rsq(i) = data.R(1,2).^2;
    
    % normalize
    data.range_Norm(i,:) = data.range(i,:) - data.range(i,1);
    data.yfit_Norm(i,:) = data.yfit(i,:) - data.yfit(i,1);
end


%% Plot Everything




