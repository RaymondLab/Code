function VOR_Summary_Sriram_DR1(params)

load('t0_t30.mat')

%% weight each mean by it's saccade %

% Desaccaded
t0_eyeVelDes_Wmean = segObj(1).eyeVelDes * segObj(1).SacFrac + ...
                     segObj(2).eyeVelDes * segObj(2).SacFrac + ...
                     segObj(3).eyeVelDes * segObj(3).SacFrac;
                 
t0_eyeVelDes_Wmean = t0_eyeVelDes_Wmean / sum(segObj(1).SacFrac, ...
                                              segObj(2).SacFrac, ...
                                              segObj(3).SacFrac);  
                                          
t30_eyeVelDes_Wmean = segObj(4).eyeVelDes * segObj(4).SacFrac + ...
                     segObj(5).eyeVelDes * segObj(5).SacFrac + ...
                     segObj(6).eyeVelDes * segObj(6).SacFrac;
                 
t30_eyeVelDes_Wmean = t30_eyeVelDes_Wmean / sum(segObj(4).SacFrac, ...
                                              segObj(5).SacFrac, ...
                                              segObj(6).SacFrac); 

% Only Good Cycles
t0_eyeVelGood_Wmean = segObj(1).eyeVelGood * segObj(1).SacFrac + ...
                     segObj(2).eyeVelGood * segObj(2).SacFrac + ...
                     segObj(3).eyeVelGood * segObj(3).SacFrac;
                 
t0_eyeVelGood_Wmean = t0_eyeVelGood_Wmean / sum(segObj(1).SacFrac, ...
                                              segObj(2).SacFrac, ...
                                              segObj(3).SacFrac);  
                                          
t30_eyeVelGood_Wmean = segObj(4).eyeVelGood * segObj(4).SacFrac + ...
                     segObj(5).eyeVelGood * segObj(5).SacFrac + ...
                     segObj(6).eyeVelGood * segObj(6).SacFrac;
                 
t30_eyeVelGood_Wmean = t30_eyeVelGood_Wmean / sum(segObj(4).SacFrac, ...
                                              segObj(5).SacFrac, ...
                                              segObj(6).SacFrac);                                           


% get difference of the means
BlueDiff = endEyeVelCycleMean - startEyeVelCycleMean;
GreenDiff = endEyeVelDesMean - startEyeVelDesMean;

% data of plot
figure(count+1000); clf;
ttCycle = (1:cycleLength)/samplerate;
plot(ttCycle, BlueDiff,'b'); hold on
plot(ttCycle, GreenDiff, 'g');
diffMeanData = data(1);
diffMeanData.data = BlueDiff;
%diffMeanData.chanlabel = 'htvel';
finalLabel = 'VOR 1Hz';

%% This is a modified version of the  VORsineFit function that
% specifically handles the mean waveforms. In order to accomadate
% this new functionality, there would have to be to many changes to
% the original function, so a new one was created. See Max Gagnon
% for more details.
[eyevelH_offset, eyevelH_rel_phase, eyevelH_amp, eyeHgain] = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, BlueDiff', headVelMean', drumVelMean');
plot(ttCycle, eyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'r')
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k');
box off

% Cosmetics of plot
ylim([-30 30]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Delta Hor. Eye Vel: ', datatype(1:8) ' ']);
%text (.1, 13.5, ['Good cycles: ', num2str(goodCount), '/', num2str(nCycles)],'FontSize',10);
text (.01, 27, ['Eye amp: ', num2str(eyevelH_amp,3)],'FontSize',10);
legend({'t_3_0 - t_0 mean: Good Cycles', 't_3_0 - t_0 mean: Good Cycles','Sine fit','Stimulus'},'EdgeColor','w')
drawnow;

%% plot difference of raw traces
figure(1067); clf;
ttCycle = (1:cycleLength)/samplerate;
plot(ttCycle, startEyeVelCycleMean,'m'); hold on
plot(ttCycle, endEyeVelCycleMean, 'r'); hold on
plot(ttCycle, BlueDiff,'b', 'LineWidth', 1);
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k'); hold on

% Cosmetics of plot
ylim([-30 30]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Mean t_0, Mean t_3_0, & Delta Hor. Eye Vel: ', datatype(1:8) ' ']);
legend({'t_0 mean: Good Cycles', 't_3_0 mean: Good Cycles','t_3_0 mean - t_0 mean: Good Cycles','Stimulus','zero'},'EdgeColor','w')
drawnow;

%% calc Sine fit for startEyeVelCycleMean & endEyeVelCycleMean
figure(1068); clf;
[STARTeyevelH_offset, STARTeyevelH_rel_phase, STARTeyevelH_amp, STARTeyeHgain] = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, startEyeVelCycleMean',mean(headVelSegments(1:3,:), 1)', mean(drumVelSegments(1:3,:), 1)');
[ENDeyevelH_offset, ENDeyevelH_rel_phase, ENDeyevelH_amp, ENDeyeHgain]         = VORsineFitMaxMod( sinefreq(1), data(1).samplerate, endEyeVelCycleMean', mean(headVelSegments(4:end,:), 1)', mean(drumVelSegments(4:end,:), 1)');

% plot differences in sine fits
plot(ttCycle, STARTeyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(STARTeyevelH_rel_phase+180))*STARTeyevelH_amp,'m'); hold on
plot(ttCycle, ENDeyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(ENDeyevelH_rel_phase+180))*ENDeyevelH_amp,'r'); hold on
plot(ttCycle, eyevelH_offset+sin(2*pi*freq*ttCycle + deg2rad(eyevelH_rel_phase+180))*eyevelH_amp,'b')
plot(ttCycle, headMean, 'k',ttCycle,zeros(size(ttCycle)),'--k'); hold on

% Cosmetics of plot
figure(1068)
ylim([-30 30]);   xlim([0 max(ttCycle)])
ylabel('deg/s');  xlabel('Time (s)');
title(['Sine Fit Comparison: t_3_0, t_0 mean, & Difference  Hor. Eye Vel:', datatype(1:8) ' ']);
legend({'t_0 mean Sine Fit: Good Cycles', 't_3_0 mean Sine Fit: Good Cycles','t_3_0 mean - t_0 mean Sine Fit: Good Cycles', 'Stimulus','zero'},'EdgeColor','w')
drawnow;

%% add the new delta data to the results structure
vec1 = NaN(length(R.header), 1)';
vec1(4) =  eyeHgain;
vec1(5) =  eyevelH_rel_phase;
vec2 = NaN(length(R.header), 1)';
vec2(4) =  ENDeyeHgain - STARTeyeHgain;
vec2(5) = ENDeyevelH_rel_phase - STARTeyevelH_rel_phase;


R.data(trueSegments+1,:) = vec1;
R.data(trueSegments+2,:) = vec2;
R.data(trueSegments+3,:) = vec3;
R.data(trueSegments+4,:) = vec4;


while length(R.labels) < trueSegments+2
    R.labels = [R.labels; 'Apples'];
end
