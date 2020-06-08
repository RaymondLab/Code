function PLOT_linearityComparison2(mag_aligned, vid_aligned, sacStarts, sacStops, keep, mag_all, mag_chunks)

numSacs = length(sacStarts);

numOnEach= 2;
colors = {'b', 'r'};
numSubs = 6;
numSubsDim = [2, 3];

figCount = ceil(numSacs / numSubs);
q = 1;


% each figure contians 9 subplots
for i = 1:figCount
    figure();
    plote = tight_subplot(numSubsDim(1),numSubsDim(2),[.005 .005],[.005 .005],[.005 .005]);
    
    for j = 1:numSubs
        % First plot the background for each subplot
        axes(plote(j));
        scatter(vid_aligned(keep), mag_aligned(keep), '.', 'LineWidth', 4, 'MarkerEdgeColor', [.5 .5 .5] ); hold on
        
        x = mag_aligned(keep);
        y = vid_aligned(keep);
        coefficients = polyfit(x, y, 1);
        xFit = linspace(min(xlim), max(xlim), 1000);
        yFit = polyval(coefficients , xFit);
        plot(xFit, yFit, 'Color', [.5 .5 .5], 'LineWidth', 2);
        
        saveXLim = xlim;
        saveYLim = ylim;
        
        % Plot k amount of interSacccadeGroups in each subplot
        for k = 1:numOnEach
            scatter(vid_aligned(sacStarts(q):sacStops(q)), mag_aligned(sacStarts(q):sacStops(q)), colors{k}, '.', 'LineWidth', 3)

            x = mag_aligned(sacStarts(q):sacStops(q));
            y = vid_aligned(sacStarts(q):sacStops(q));
            coefficients = polyfit(x, y, 1);
            xFit = linspace(min(xlim), max(xlim), 1000);
            yFit = polyval(coefficients , xFit);
            plot(yFit, xFit, colors{k}, 'LineWidth', 2);
            
            yticks([])
            xticks([])
            ylim(saveYLim)
            xlim(saveXLim)
            box off
            q = q + 1;
            if q == numSacs
                break
            end
        end
        legend({' ', ['r^2: ', num2str(mag_all.Rsq)], ' ', ['r^2: ', num2str(mag_chunks(q-2).Rsq)], ' ', ['r^2: ', num2str(mag_chunks(q-1).Rsq)]})

        
        if q == numSacs
            break
        end
    end
    
    if q == numSacs
        break
    end
end