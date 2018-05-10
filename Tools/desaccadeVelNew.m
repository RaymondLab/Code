function [eyevelOut, omitCenters, rawThres] = desaccadeVelNew(eyevelIn, presaccade, postsaccade, stdThresh)
% define minimum cutoff
% this is a safeguard for traces that have no saccades
minThresh = 13000;
% Smooth
%eyevelIn = smooth(eyevelIn,30);
%eyevelIn = smoothdata(eyevelIn, 'movmean', 10);

% Center the mean
velMeanTemp = nanmean(eyevelIn);
eyevelIn = eyevelIn - velMeanTemp;
velMean = nanmean(eyevelIn);

% Square all points
eyevelIn = eyevelIn .^ 2;

% Get the upper and lower thresholds
velStd = abs(nanstd(eyevelIn));
upThresh = velMean + max(stdThresh * velStd, minThresh);
downThresh = velMean - max(stdThresh * velStd, minThresh);

if upThresh == minThresh
    warning('Minimum Threshold Detected! Possible Bad De-Saccade')
end

if upThresh < 1000
    warning('Very Low Threshold!')
end


% figure(77777)
% plot(eyevelIn)
% hold on
% hline(upThresh)
% hline(500)
% hline(downThresh)
% hold off
% ylim([0, upThresh * 3])
% figure(88888)
% hist(eyevelIn, 400)
% hold on
% vline(upThresh)
% vline(downThresh)
% xlim([downThresh upThresh]);
% hold off


%% instead of threshold, use standard deviations away from mean
% find regions of data outside threshold; 
omitCenters = ~(eyevelIn > downThresh & eyevelIn < upThresh);

% remove points around omit centers as defined by pre- & postsaccade time
sacmask = ones(1,presaccade+postsaccade);

% filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(omitCenters),sacmask);
rejecttemp2 = rejecttemp1(presaccade:presaccade+length(eyevelIn)-1);

% eyevel with desaccade segments removed
eyevelOut = eyevelIn;
eyevelOut(logical(rejecttemp2))= NaN;

rawThres = [sqrt(upThresh) + velMeanTemp, -1*sqrt(upThresh) + velMeanTemp] ;
