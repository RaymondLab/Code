function vars = alignmentMethod_Saccade_APP(app, vars)
disp('Calculating Alignment Based on Saccade Overlap...')

%% Prep
badSpots_vid = vars.sacLoc_vid;

alignmentWindow = [-3 3];
alignmentSlots = alignmentWindow(1)*vars.samplerate_Magnet:alignmentWindow(2)*vars.samplerate_Magnet;
rr = 1;
for i = alignmentSlots
    if i < 0
        q(rr) = sum(vars.sacLoc_mag1(1:end+i) & badSpots_vid(i*-1:end-1));
        w(rr) = sum(vars.sacLoc_mag2(1:end+i) & badSpots_vid(i*-1:end-1));
    elseif i == 0
        q(rr) = sum(vars.sacLoc_mag1 & badSpots_vid);
        w(rr) = sum(vars.sacLoc_mag2 & badSpots_vid);
    elseif i > 0
        q(rr) = sum(vars.sacLoc_mag1(i:end-1) & badSpots_vid(1:end-i));
        w(rr) = sum(vars.sacLoc_mag2(i:end-1) & badSpots_vid(1:end-i));
    end
    
    rr = rr + 1;
end


%% Choose Lag Value to Use
maxw = max(w);
maxq = max(q);


lag_sac_q = alignmentSlots(q == maxq);
lag_sac_w = alignmentSlots(w == maxw);

if length(lag_sac_q) > 1
    lag_sac_q = lag_sac_q(1);
end

if length(lag_sac_w) > 1
    lag_sac_w = lag_sac_w(1);
end


lag_q = lag_sac_q*-1;
lag_w = lag_sac_w*-1;
if maxq > maxw
    lag = lag_q;
else
    lag = lag_w;
end


%% Updates Data
disp(['Lag Calculated from Saccade Matching, Magnet Chan1: ', num2str(lag_q)]);
disp(['Lag Calculated from Saccade Matching, Magnet Chan2: ', num2str(lag_w)]);

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
    vars.vid_keep = ~vars.sacLoc_vid(1:end+lag);
    vars.vid_sac = vars.sacLoc_vid(1:end+lag);
else
    vars.mag1_aligned = vars.mag1.data(1:end-lag);
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
percent_deleted = 100*(1-sum(int64(vars.keep))/length(vars.keep))


%% Figure A: Sac Overlap With Various Alignment Values 
figure('Visible', 'on')
plot(alignmentSlots, q, 'r'); hold on
plot(alignmentSlots, w);
vline(lag_sac_q, 'r')
vline(lag_sac_w, 'k')
text(lag_sac_q,maxq, ['Magnet Chan1: Sac Overlap ', num2str(lag_sac_q)], 'Color', 'r')
text(lag_sac_w,maxw*.9, ['Magnet Chan2: Sac Overlap ', num2str(lag_sac_w)], 'Color', 'k')

xlabel('Video Shift Amount (ms)')
ylabel('Number of overlapping samples with saccades')

print(gcf, fullfile(cd, 'SaccadeOverlap.pdf'),'-dpdf');
savefig('SaccadeOverlap.fig');


end