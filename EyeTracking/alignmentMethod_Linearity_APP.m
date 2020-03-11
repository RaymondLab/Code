function vars = alignmentMethod_Linearity_APP(app, vars)
disp('Calculating Alignment Based on highest Linearity...')

% Mag1
mag1Pos = vars.mag1.data;
mag1Vel = vars.mag1Vel;

% Mag2
mag2Pos = vars.mag2.data;
mag2Vel = vars.mag2Vel;

% Vid
vidPos = vars.vidH_upsample;
vidVel = vars.vidVel;

c = linspace(1,10,length(mag1Pos));

%% Calculate r2 values With Various Alignment Values

try
    [r2(:,1)]= linearityAlign(mag1Pos, vidPos);
    maxVal(1) = max(r2(:,1));
    maxLoc(1) = find(r2(:,1) == max(r2(:,1)),1);
catch
end

try
    [r2(:,2)]= linearityAlign(mag1Vel, vidVel);   
    maxVal(2) = max(r2(:,2));
    maxLoc(2) = find(r2(:,2) == max(r2(:,2)),1);
catch
end

try
    [r2(:,3)]= linearityAlign(mag2Pos, vidPos); 
    maxVal(3) = max(r2(:,3));
    maxLoc(3) = find(r2(:,3) == max(r2(:,3)),1);
catch
end

try
    [r2(:,4)]= linearityAlign(mag2Vel, vidVel);
    maxVal(4) = max(r2(:,4));
    maxLoc(4) = find(r2(:,4) == max(r2(:,4)),1);
catch
end

maxLoc = maxLoc-4000;

%% Choose shift based on channel with highest r2
if maxVal(1) > maxVal(3)
    lag = maxLoc(1);
else
    lag = maxLoc(3);
end

%% Add Lag to All Channels
disp(['Lag Calculated from Linearity Matching: ', num2str(lag)]);

if lag < 0
    vars.mag1_aligned = vars.mag1.data((-lag)+1:end);
    vars.mag1_sac     = vars.sacLoc_mag1((-lag)+1:end);
    
    vars.mag2_aligned = vars.mag2.data((-lag)+1:end);
    vars.mag2_sac     = vars.sacLoc_mag1((-lag)+1:end);

    vars.mag1_vel_aligned = vars.mag1Vel((-lag)+1:end);
    vars.mag2_vel_aligned = vars.mag2Vel((-lag)+1:end);

    vars.time_aligned = vars.tmag((-lag)+1:end);
    
    vars.vid_aligned = vars.vidH_upsample(1:end+lag);
    vars.vidV_aligned = vars.vidVel(1:end+lag);
    vars.vid_sac = vars.sacLoc_vid(1:end+lag);
else
    vars.mag1_aligned = vars.mag1.data(1:end-lag);
    vars.mag1_keep   = ~vars.sacLoc_mag1((-lag)+1:end);
    vars.mag1_sac   = vars.sacLoc_mag1((-lag)+1:end);
    
    vars.mag2_aligned = vars.mag2.data(1:end-lag);
    vars.mag2_sac   = vars.sacLoc_mag2((-lag)+1:end);
    
    vars.mag1_vel_aligned = vars.mag1Vel(1:end-lag);
    vars.mag2_vel_aligned = vars.mag2Vel(1:end-lag);
    
    vars.time_aligned = vars.tmag(1:end-lag);
    
    vars.vid_aligned = vars.vidH_upsample((lag)+1:end);
    vars.vidV_aligned = vars.vidVel((lag)+1:end);
    vars.vid_sac = vars.sacLoc_vid((lag)+1:end);
    
end
vars.lag = lag;
vars.keep = ~vars.mag1_sac & ~vars.mag2_sac & ~vars.vid_sac;
keep = vars.keep;

%% Figure A: r2 over values with various time shift amounts

yVals = 1:length(r2);
yVals = yVals - 4000;

figure();
plot(yVals, r2(:,1), 'r'); hold on
vline(maxLoc(1), 'r')
text(maxLoc(1),max(ylim)*.9, ['MagChan1 Pos ', num2str(maxLoc(1))], 'Color', 'r')

plot(yVals, r2(:,2), 'k');
vline(maxLoc(2), '--k')
text(maxLoc(2),max(ylim)*.8, ['MagChan1 Vel ', num2str(maxLoc(2))], 'Color', 'k')

plot(yVals, r2(:,3), 'b');
vline(maxLoc(3), 'b')
text(maxLoc(3),max(ylim)*.7, ['MagChan2 Pos ', num2str(maxLoc(3))], 'Color', 'b')

plot(yVals, r2(:,4), 'c');
vline(maxLoc(4), '--c')
text(maxLoc(4),max(ylim)*.6, ['MagChan2 Vel ', num2str(maxLoc(4))], 'Color', 'c')
grid on

drawnow
title('Linearity with Various Alignment Values, ALL DATA')
ylabel('r^2 Values')
xlabel('Alignment Amounts (ms)')

print(gcf, fullfile(cd, 'Linearity_allShifts.pdf'),'-dpdf');
savefig('Linearity_allShifts.fig');

%% Figure B: Linearity of Best Alignmnet, ALL DATA
figure();
plotb = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 
allData = logical(ones(length(keep), 1));

axes(plotb(1)); hold on
Rsq = linearityScatterPlot(vars.mag1_aligned, vars.vid_aligned, allData, c);
title(['ALL DATA: r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan1 Position')

axes(plotb(2));
Rsq = linearityScatterPlot(vars.mag1_vel_aligned, vars.vidV_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan1 Velocity')


axes(plotb(3));
Rsq = linearityScatterPlot(vars.mag2_aligned, vars.vid_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')


axes(plotb(4));
Rsq = linearityScatterPlot(vars.mag2_vel_aligned, vars.vidV_aligned, allData, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')

print(gcf, fullfile(cd, 'Linearity_Best_AllData.pdf'),'-dpdf');
savefig('Linearity_Best_AllData.fig');

%% Figure C: Linearity of Best Alignmnet, DESACCADED
figure();
plotc = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 

axes(plotc(1)); hold on
Rsq = linearityScatterPlot(vars.mag1_aligned, vars.vid_aligned, keep, c);
title(['DESACCADED: r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan1 Position')


axes(plotc(2));
Rsq = linearityScatterPlot(vars.mag1_vel_aligned, vars.vidV_aligned, keep, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan1 Velocity')

axes(plotc(3));
Rsq = linearityScatterPlot(vars.mag2_aligned, vars.vid_aligned, keep, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Position')
ylabel('Mag Chan2 Position')

axes(plotc(4));
Rsq = linearityScatterPlot(vars.mag2_vel_aligned, vars.vidV_aligned, keep, c);
title(['r^2: ', num2str(Rsq)])
xlabel('Video Velocity')
ylabel('Mag Chan2 Velocity')


print(gcf, fullfile(cd, 'Linearity_Best_Desacced.pdf'),'-dpdf');
savefig('Linearity_Best_Desacced.fig');

%% Figure D: Plot Cycle Averages of Video, Mag1, and Mag2 Velocity
figure(); hold on
% Get MAtricies
[~, mag1VelMean] = VOR_breakTrace(1000, 250, vars.mag1_vel_aligned*vars.scaleCh1);
[~, mag2VelMean] = VOR_breakTrace(1000, 250, vars.mag2_vel_aligned*vars.scaleCh2);
[~, vidVelMean] = VOR_breakTrace(1000, 250, vars.vidV_aligned);
plot(mag1VelMean, 'b');
plot(mag2VelMean, 'c');
plot(vidVelMean, 'r');
hline(0,':k');
vline(500,':k');
ylim([-15 15]);
xlabel('ms')
title('Velocty Cycle Averages (Scaled and Aligned)')
legend({'Mag1', 'Mag2', 'Video'});

print(gcf, fullfile(cd, 'Velocity Cycle Averages.pdf'),'-dpdf');
savefig('Velocity Cycle Averages.fig');

disp('apple')








