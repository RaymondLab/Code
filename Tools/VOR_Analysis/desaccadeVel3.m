function [eyevelOut, omitCenters] = desaccadeVel3(eyevelIn, samplerate, presaccade, postsaccade, thresh)
% LOW PASS ON POSITION
N = 4;
fc = 15;
[bb,aa] = butter(N, fc/samplerate, 'low');
eyevelInFILT = filter(bb,aa,eyevelIn);

% CALC VEL
eye_vel = abs(diff(eyevelInFILT));

%%
% find regions of data outside threshold; 
omitCenters = eye_vel > thresh;

% remove points around omit centers as defined by pre- & postsaccade time
sacmask = ones(1,presaccade+postsaccade);

% filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(omitCenters),sacmask);
rejecttemp2 = rejecttemp1(presaccade:presaccade+length(eyevelIn)-1);

% eyevel with desaccade segments removed
eyevelOut = eyevelIn;
eyevelOut(logical(rejecttemp2))= NaN;