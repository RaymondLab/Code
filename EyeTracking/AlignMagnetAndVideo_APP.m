function vars = AlignMagnetAndVideo_APP(app, vars)

%% Method 1
vars.keep = ~(vars.sacLoc_mag1|vars.sacLoc_mag2|vars.sacLoc_vid);
vars.keep_start = strfind(vars.keep', [0 1]);
vars.keep_end = strfind(vars.keep', [1 0]);

% Correct for artifacts/saccades at begining and end of segment
if isempty(vars.keep_start) && ~isempty(vars.keep_end)
    vars.keep_start = 1;
    
elseif ~isempty(vars.keep_start) && isempty(vars.keep_end)
    vars.keep_end = length(vars.keep);
    
elseif ~isempty(vars.keep_end) && ~isempty(vars.keep_start)
    if vars.keep_end(1) < vars.keep_start(1)
        vars.keep_start = [1 vars.keep_start];
    end
    
    if vars.keep_end(end) < vars.keep_start(end)
        vars.keep_end = [vars.keep_end length(vars.keep)];
    end
end

best_stretch = find(vars.keep_end-vars.keep_start == max(vars.keep_end-vars.keep_start));
best_mag = vars.chosenMag(vars.keep_start(best_stretch):vars.keep_end(best_stretch));
best_vid = vars.vidH_upsample(vars.keep_start(best_stretch):vars.keep_end(best_stretch));

[c,lag_Segment] = crosscorr(best_mag,best_vid,'NumLags',length(best_mag)-1);
lag_Segment = lag_Segment(find(c==max(c)));
lag_Segment = lag_Segment - 1000; % General trend seems to be this slignment method will be one phase off


%% Method 2
[c,lags] = crosscorr(vars.chosenMag,vars.vidH_upsample,'NumLags',length(vars.chosenMag)-1);
lag_Whole = lags(find(c == max(c)));

%% Method 3

badSpots_mag = vars.chosenMagSacLoc;
badSpots_vid = vars.sacLoc_vid;

alignmentWindow = [-3 3];
alignmentSlots = alignmentWindow(1)*vars.samplerate_Magnet:alignmentWindow(2)*vars.samplerate_Magnet;
rr = 1;
for i = alignmentSlots
    if i < 0
        q(rr) = sum(badSpots_mag(1:end+i) & badSpots_vid(i*-1:end-1));
    elseif i == 0
        q(rr) = sum(badSpots_mag & badSpots_vid);
    elseif i > 0
        q(rr) = sum(badSpots_mag(i:end-1) & badSpots_vid(1:end-i));
    end
    
    rr = rr + 1;
end

figure('Visible', 'on')
plot(alignmentSlots, q)
maxq = max(q);
lag_sac = alignmentSlots(q == maxq);
if length(lag_sac) > 1
    lag_sac = lag_sac(1);
end

vline(lag_Segment*-1, 'k')
text(lag_Segment*-1,maxq*.9, ['Good Portion ', num2str(lag_Segment*-1)], 'Color', 'k')

vline(lag_Whole*-1, 'm')
text(lag_Whole*-1,maxq*.8, ['Whole Seg ', num2str(lag_Whole*-1)], 'Color', 'm')

vline(lag_sac, 'r')
text(lag_sac,maxq, ['Sac Overlap ', num2str(lag_sac)], 'Color', 'r')

xlabel('Video Shift Amount (ms)')
ylabel('Number of overlapping samples with saccades')



if contains(app.AlignmentMethodDropDown.Value, 'Largest Good Portion')
    lag = lag_Segment;
elseif contains(app.AlignmentMethodDropDown.Value, 'Whole Trace')
    lag = lag_Whole;
elseif contains(app.AlignmentMethodDropDown.Value, 'Saccade Overlap')
    lag = lag_sac*-1;
end

%% Alternate Alignment Algorithm


if lag < 0
    vars.mag_aligned = vars.chosenMag((-lag)+1:end);
    vars.mag_keep = ~vars.chosenMagSacLoc((-lag)+1:end);
    vars.mag_keep2 = ~vars.notChosenMagScaleLoc((-lag)+1:end);
    vars.time_aligned = vars.tmag((-lag)+1:end);
    
    vars.vid_aligned = vars.vidH_upsample(1:end+lag);
    vars.vidV_aligned = vars.vidV_upsample(1:end+lag);
    vars.vid_keep = ~vars.sacLoc_vid(1:end+lag);
else
    vars.mag_aligned = vars.chosenMag(1:end-lag);
    vars.mag_keep = ~vars.chosenMagSacLoc(1:end-lag);
    vars.mag_keep2 = ~vars.notChosenMagScaleLoc(1:end-lag);
    vars.time_aligned = vars.tmag(1:end-lag);
    
    vars.vid_aligned = vars.vidH_upsample((lag)+1:end);
    vars.vidV_aligned = vars.vidV_upsample((lag)+1:end);
    vars.vid_keep = ~vars.sacLoc_vid((lag)+1:end);
end
vars.lag = lag;
vars.keep = vars.mag_keep & vars.vid_keep & vars.mag_keep2;
percent_deleted = 100*(1-sum(int64(vars.keep))/length(vars.keep))

end