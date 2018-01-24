function [eyevelH_offset, eyevelH_rel_phase, eyevelH_amp, eyeHgain] = VORsineFitMaxMod(freq, sampleRate, eyeVel, headVel, drumVel)

% Segment data to current time segment
%dataseg = datseg(data, [tstart tstop]);

% Read in data
%if ~isempty(strfind([dataseg.chanlabel],'htvel'))
%    drumvel         = datchandata(dataseg,'htvel');
%else
%    drumvel = zeros(size(headVel));
%end

% define vector of time
ndatapoints = length(headVel);   % number of datapoints in segment
time = ((1:ndatapoints)-1)/sampleRate;

%% Set up variables for fitting data using a linear regression of Fourier Series
y1 = sin(2*pi*freq*time(:));
y2 = cos(2*pi*freq*time(:));
constant = ones(ndatapoints,1);
vars = [y1 y2 constant];
warning off

%% ======== FIT SINE FITS BASED ON DESACCADED TRACES =========
% fit data using a linear regression (data specified by 'keep_'index)
% b=coefficients, bint=95% confidence intervals, r=residual, rint=interval
% stats include 1)R-square, 2)F statistics, 3)p value 4)error variance
warning('off','stats:regress:NoConst') % No constant term bc sine centered at 0

% ------------CHAIR VELOCITY------------
[b,~,~,~,~] = regress(headVel, vars);
headH_amp = sqrt(b(1)^2+b(2)^2);
headH_angle = rad2deg(atan2(b(2), b(1)));

% ------------DRUM VELOCITY------------
[b,~,~,~,~] = regress(drumVel, vars);
drumH_amp = sqrt(b(1)^2+b(2)^2);
drumH_angle = rad2deg(atan2(b(2), b(1)));

% calculate eye gain as VOR or OKR based on head signal
if headH_amp > 3         % Chair signal
    refH_angle = headH_angle;
elseif drumH_amp >3      % No chair signal, drum signal
    refH_angle = drumH_angle;
else                    % No stimulus
    refH_angle = 0;
end

% ------------ EYE VELOCITY------------
[b,~,~,~,~] = regress(eyeVel, vars);
eyevelH_amp = sqrt(b(1)^2+b(2)^2);
eyevelH_phase = rad2deg(atan2(b(2), b(1)));
eyevelH_offset = b(3);

% ------------EYE RELATIVE TO CHAIR/DRUM------------
eyevelH_rel_phase = (eyevelH_phase - refH_angle);
eyevelH_rel_phase = mod(eyevelH_rel_phase,360) - 180;
eyeHgain = eyevelH_amp / headH_amp;

