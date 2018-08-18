function [eyeVelOut, omitCenters] = VOR_desaccadeAlt(eyeVelIn, params)
%% Filter Data


%% Band pass filter to remove 1)high freq noise 2)Our experimental signal freq
N = 3;      % Filter order
fc = [10 40];   % Cutoff frequency
[bb,aa] = butter(N, fc/params.samplerate, 'bandpass');
eyeVelFilt = filter(bb,aa,eyeVelIn)';

%% Take Derivitive
eyeVelFilt = diff(eyeVelFilt);

downThresh = params.saccadeThresh*-1;
upThresh = params.saccadeThresh;

%% Remove data beyond thresholds
omitCenters = ~(eyeVelFilt > downThresh & eyeVelFilt < upThresh);

% remove points around omit centers as defined by pre- & postsaccade time
sacmask = ones(1,params.saccadePre+params.saccadePost);

% filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(omitCenters),sacmask);
rejecttemp2 = rejecttemp1(params.saccadePre:params.saccadePre+length(eyeVelFilt)-1);

% eyevel with desaccade segments removed
eyevelOut = eyeVelFilt;
eyevelOut(logical(rejecttemp2))= NaN;


omitH = isnan(eyevelOut);
eyeVelOut = eyeVelIn;
eyeVelOut(omitH) = NaN;