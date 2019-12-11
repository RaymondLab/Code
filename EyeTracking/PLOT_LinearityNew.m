function vars = PLOT_LinearityNew(app, vars)



%% Mag1
mag1Pos = vars.mag1.data;
% low pass filter
%mag1Pos = lowpass(mag1Pos,20,1000);

mag1Vel = vars.mag1Vel;

%% Mag2
mag2Pos = vars.mag2.data;
% low pass filter
%mag2Pos = lowpass(mag2Pos,20,1000);

mag2Vel = vars.mag2Vel;

%% Vid
vidPos = vars.vidH_upsample;
vidVel = vars.vidVel;

%% Misc Vars
keep = vars.keep;
c = linspace(1,10,length(mag1Pos));

%% Figre A: Linearity Over Time
A = figure('units','normalized','outerposition',[0.0005, 0.0342, 0.4990, 0.8950]);
plota = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]);

axes(plota(1));
try
    [shift(1) maxR2(1)]= linearityAlign(mag1Pos, vidPos);
catch
end

try
    axes(plota(2));
    [shift(2) maxR2(2)]= linearityAlign(mag1Vel, vidVel);
catch
end

try
    axes(plota(3));
    [shift(3) maxR2(3)]= linearityAlign(mag2Pos, vidPos);
catch
end

try
    axes(plota(4));
    [shift(4) maxR2(4)]= linearityAlign(mag2Vel, vidVel);
catch
end


%% Choose shift based on channel with highest r2
if maxR2(1) > maxR2(3)
    lag = shift(1);
else
    lag = shift(3);
end

%% Add Lag to All Channels
%lag = shift;
disp(['Lag Calculated from Linearity Matching: ', num2str(lag)]);

if lag < 0
    vars.mag1_aligned = vars.mag1.data((-lag)+1:end);
    vars.mag2_aligned = vars.mag2.data((-lag)+1:end);
    
    vars.mag1_vel_aligned = vars.mag1Vel((-lag)+1:end);
    vars.mag2_vel_aligned = vars.mag2Vel((-lag)+1:end);

    vars.mag_aligned = vars.chosenMag((-lag)+1:end);
    vars.mag_keep = ~vars.chosenMagSacLoc((-lag)+1:end);
    vars.mag_keep2 = ~vars.notChosenMagScaleLoc((-lag)+1:end);
    vars.time_aligned = vars.tmag((-lag)+1:end);
    
    vars.vid_aligned = vars.vidH_upsample(1:end+lag);
    vars.vidV_aligned = vars.vidVel(1:end+lag);
    vars.vid_keep = ~vars.sacLoc_vid(1:end+lag);
else
    vars.mag1_aligned = vars.mag1.data(1:end-lag);
    vars.mag2_aligned = vars.mag2.data(1:end-lag);
    
    vars.mag_aligned = vars.chosenMag(1:end-lag);
    vars.mag_keep = ~vars.chosenMagSacLoc(1:end-lag);
    vars.mag_keep2 = ~vars.notChosenMagScaleLoc(1:end-lag);
    vars.time_aligned = vars.tmag(1:end-lag);
    
    vars.vid_aligned = vars.vidH_upsample((lag)+1:end);
    vars.vidV_aligned = vars.vidVel((lag)+1:end);
    vars.vid_keep = ~vars.sacLoc_vid((lag)+1:end);
end
vars.lag = lag;
vars.keep = vars.mag_keep & vars.vid_keep & vars.mag_keep2;

%% Figure B: Linearity of best alignmnet
B = figure('units','normalized','outerposition',[0.5005, 0.0342, 0.4990, 0.8950]);
plotb = tight_subplot(2,2,[.05 .025],[.05 .025],[.03 .01]); 

axes(plotb(1)); 
linearityScatterPlot(vars.mag1_aligned, vars.vid_aligned, keep, c)
axes(plotb(2)); 
linearityScatterPlot(vars.mag1_vel_aligned, vars.vidV_aligned, keep, c)
axes(plotb(3)); 
linearityScatterPlot(vars.mag2_aligned, vars.vid_aligned, keep, c)
axes(plotb(4)); 
linearityScatterPlot(vars.mag2_vel_aligned, vars.vidV_aligned, keep, c)

% 
% 
axes(plotb(1)); 
linearityScatterPlot(lowpass(vars.mag1_aligned,10,1000), lowpass(vars.vid_aligned,10,1000), keep, c)
axes(plotb(2)); 
linearityScatterPlot(lowpass(vars.mag1_vel_aligned,10,1000), lowpass(vars.vidV_aligned,10,1000), keep, c)
axes(plotb(3)); 
linearityScatterPlot(lowpass(vars.mag2_aligned,10,1000), lowpass(vars.vid_aligned,10,1000), keep, c)
axes(plotb(4)); 
linearityScatterPlot(lowpass(vars.mag2_vel_aligned,10,1000), lowpass(vars.vidV_aligned,10,1000), keep, c)

