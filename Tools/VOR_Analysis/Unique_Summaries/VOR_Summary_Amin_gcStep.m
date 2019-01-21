function VOR_Summary_Amin_gcStep(params)

%% Extract important Information from Excel file and result .mat file
figg = figure(234);
ka = tight_subplot(3,3,[.025 .025],[.025 .025],[.025 .025]);
figg2 = figure(235);
ta = tight_subplot(2,2,[.025 .025],[.025 .025],[.025 .025]);
slotVec = [1, 4, 5, 6, 8, 10, 12, 15, 16];
locVec = [1, 1, 1, 2, 2, 2, 3, 3, 3];
q = 1;
%excelTable = readtable(fullfile(params.folder, [params.file, '.xlsx']));
load(fullfile(params.folder, 'result.mat'));


titles = {'Stim Pre Test 1', ...
          'Stim Pre Test 2', ...
          'Stim Pre Test 3', ...
          'Stim Block Test 1', ...
          'Stim Block Test 2', ...
          'Stim Block Test 3', ...
          'Stim Post Test 1', ...
          'Stim Post Test 2', ...
          'Stim Post Test 3'};
     
%% sp1: Stim Pre-1
for i = 1:9
    
    axes(ka(i))
    r = slotVec(i);
    plot(result.cycleTime{r}, result.eyeVel_des_cycleMean{r}); hold on
    patch(result.xcycle{r}, result.ycycle{r}*3, 'k', 'FaceAlpha',.05, 'LineStyle', 'none');
    %maxLoc = find(result.eyeVel_des_cycleMean{r} == max(result.eyeVel_des_cycleMean{r}))/result.samplerate{r};
    %line([maxLoc maxLoc], [0 max(result.eyeVel_des_cycleMean{r})], 'color', 'r', 'LineWidth', .3);
    
    % Cosmetics
    hline(0, ':k')
    ylim([-150, 150]); yticks([-150 0 150])
    xticklabels([]); xticks([])
    title(titles{i})
    box off
    
    % save min/max
    vec = result.eyeVel_des_cycleMean{r};
    start_stops = result.xcycle{r};
    
    axes(ta(1))
    min_1(i) = min(vec(start_stops(1,1)*1000:start_stops(2,1)*1000));
    plot(locVec(q), min_1(i), '*b'); hold on
    
    
    xlim([.75 3.25])
    xticks([1 2 3])
    
    axes(ta(2))
    max_1(i) = max(vec(start_stops(1,1)*1000:start_stops(2,1)*1000));
    plot(locVec(q), max_1(i), '*b'); hold on
    
    xlim([.75 3.25])
    xticks([1 2 3])
    
    axes(ta(3))
    min_2(i) = min(vec(start_stops(1,2)*1000:start_stops(2,2)*1000));
    plot(locVec(q), min_2(i), '*b'); hold on
    
    xlim([.75 3.25])
    xticks([1 2 3])
    
    axes(ta(4))
    max_2(i) = max(vec(start_stops(1,2)*1000:start_stops(2,2)*1000));
    plot(locVec(q), max_2(i), '*b'); hold on
    
    xlim([.75 3.25])
    xticks([1 2 3])
    
    q = q+ 1;

end

axes(ta(1))
plot(1, mean(min_1(1:3)), 'dk', 'MarkerFaceColor','k')
plot(2, mean(min_1(4:6)), 'dk', 'MarkerFaceColor','k')
plot(3, mean(min_1(7:9)), 'dk', 'MarkerFaceColor','k')
plot([1 2 3], [mean(min_1(1:3)), mean(min_1(4:6)), mean(min_1(7:9))], '--k','LineWidth', .1)
xticklabels([])
hline(0, ':k')
title('Min 1')
ylim([-120 150])
box off

axes(ta(2))
plot(1, mean(max_1(1:3)), 'dk', 'MarkerFaceColor','k')
plot(2, mean(max_1(4:6)), 'dk', 'MarkerFaceColor','k')
plot(3, mean(max_1(7:9)), 'dk', 'MarkerFaceColor','k')
plot([1 2 3], [mean(max_1(1:3)), mean(max_1(4:6)), mean(max_1(7:9))], '--k','LineWidth', .1)
xticklabels([])
hline(0, ':k')
title('Max 1')
ylim([-120 150])
box off

axes(ta(3))
plot(1, mean(min_2(1:3)), 'dk', 'MarkerFaceColor','k')
plot(2, mean(min_2(4:6)), 'dk', 'MarkerFaceColor','k')
plot(3, mean(min_2(7:9)), 'dk', 'MarkerFaceColor','k')
plot([1 2 3], [mean(min_2(1:3)), mean(min_2(4:6)), mean(min_2(7:9))], '--k','LineWidth', .1)
xticklabels({'Pre Test', 'Block Test', 'Post Test'})
hline(0, ':k')
title('Min 2')
ylim([-120 150])
box off

axes(ta(4))
plot(1, mean(max_2(1:3)), 'dk', 'MarkerFaceColor','k')
plot(2, mean(max_2(4:6)), 'dk', 'MarkerFaceColor','k')
plot(3, mean(max_2(7:9)), 'dk', 'MarkerFaceColor','k')
plot([1 2 3], [mean(max_2(1:3)), mean(max_2(4:6)), mean(max_2(7:9))], '--k','LineWidth', .1)
xticklabels({'Pre Test', 'Block Test', 'Post Test'})
hline(0, ':k')
title('Max 2')
ylim([-120 150])
box off


%% Save first figure
%tic; saveas(figg, fullfile(params.folder, [params.file '_SummarySubplot1.fig'])); toc


%% OKR and VOR
figg3 = figure(236);
fa = tight_subplot(2,1,[.025 .025],[.025 .025],[.025 .025]);

% OKR
axes(fa(1))
plot(result.cycleTime{2}, result.eyeVel_des_cycleMean{2}, 'b'); hold on
plot(result.cycleTime{2}, result.headVel_cycleMean{2}, 'k');

plot(result.cycleTime{13}, result.eyeVel_des_cycleMean{13}, 'r')
plot(result.cycleTime{13}, result.headVel_cycleMean{13}, 'k');



% VORD
axes(fa(2))
plot(result.cycleTime{3}, result.eyeVel_des_cycleMean{3}, 'b'); hold on
plot(result.cycleTime{3}, result.drumVel_cycleMean{3}, 'k');

plot(result.cycleTime{14}, result.eyeVel_des_cycleMean{14}, 'r');
plot(result.cycleTime{14}, result.drumVel_cycleMean{14}, 'k');




