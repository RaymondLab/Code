D = importSpike('test2.smr');
D = datchan(D, {'HHVEL','hepos3'}); % actually vel


%% 1. Get the average step response

% Parameters
t_smooth = .025; % seconds to smooth desired step (3 times moving average)
t_f = .150;

minCycle = .4;
stepDur = .2;
tbefore = 0;
ipsi  = findipsicontra(D(1),minCycle,0);
temp = datsegmeans(D, ipsi - tbefore, stepDur);
dt = 1/D(1).samplerate;
temp(2) = datlowpass(temp(2), 200);
x1 = temp(1).data; % input
y1 = double(temp(2).data)*100; % output
nt = length(y1);
tt1 = (1:nt)*dt;


% 2. Get impulse response
f = diff(y1)/dt;
f = smooth(f,1);
f = f(find(f==max(f)):end); % Not sure why this is needed but it is!
f = f/sum(f);
tt1f = (1:length(f))*dt;

% f = exp(-tt1f/.020);

% 3. Now find x_hat, the optimal input given the filter f to produce
% desired output x

% Make a desired step
y_goal = zeros(3000,1); 
stepStart = 500;
y_goal(stepStart:1000) = 1;
i_smooth = round(t_smooth/dt);
y_goal = smooth(y_goal,i_smooth);
y_goal = smooth(y_goal,i_smooth);
% y_goal = smooth(y_goal,i_smooth);

% Deconvolve it with the impulse response
x2 = deconv(y_goal, f);
tt2 = (1:length(x2))*dt;

% Generate new filter to use for inputs to steps
f2 = diff(x2);
f2 = f2(stepStart:(stepStart+ round(t_f/dt)));
f2 = f2/sum(f2);
tt2f = (1:length(f2))*dt;

% Save filter
filt = f2;
tt = tt2f;
save('stepFilter.mat','tt','filt')

% Plot results
figure
subplot(2,2,1)
plot(tt1,x1,tt1,y1)
title('Original step response')
legend('x1','y1')
hold on

subplot(2,2,2)
plot(tt1f, f,'r'); hold on
plot([tt1f(1) tt1f(end)],[0 0 ],'k--')
title('f (impulse response actual motor)')

subplot(2,2,3); 
plot(tt2, x2); hold on
plot(tt2, filter(f,1, x2))
legend('x2','y2')
title('New input and predicted output')

subplot(2,2,4); 
plot(tt2f, f2,'r'); hold on
plot([tt2f(1) tt2f(end)],[0 0],'k--')
title('Impulse response to filter inputs with for steps')
xlabel('Time (s)')
maximize
fixticks

%% Alternate fft method
addpath(genpath('C:\Dropbox\Matlab\chronux_2_11'))


Yin = datsegdata(D(2), ipsi-.1, 1.6);
Xin = datsegdata(datsmooth(D(1),5), ipsi-.1,  1.6);
Xin = Xin/std(Xin(:));
Yin = Yin/std(Yin(:));

params.tapers = [2 3];
params.tapers = [4 7];
params.pad = 0;
params.Fs = 1000;
params.fpass = [];%0 50
params.trialave = 1;
    
[Y, f] = mtspectrumc(Yin, params);
X = mtspectrumc(Xin, params);
figure; 
subplot(3,2,1);
plot(mean(Xin,2)); hold on
plot(mean(Yin,2))
title('Raw signals ')
legend('x','y')

subplot(3,2,2)
loglog(f, X,f,Y); hold on
title('Input spectra')
legend('X','Y')
xlim([0 100])

% Filter in frequency domain
H = Y./X;
H_smooth = smooth(H,1);
% H_smooth(f>f_max) = 0;
subplot(3,2,3);
loglog(f, H,'k')
hold on
loglog(f,H_smooth,'r')
loglog(f, ones(size(f)),'k--')
title('H')
legend('Raw','Smoothed')
xlim([0 100])


% Now caculate inverse"
Hinv = 1./H_smooth;
Hinv(Hinv==Inf) = 0;
Hinv_smooth = smooth(Hinv);
mask = ones(size(f(:)));

f_max = 10; % Hz
mask(f>f_max) = 10.^(-(f(f>f_max)-f_max)/50);
Hinv_smooth = Hinv_smooth.*mask;

subplot(3,2,4);
loglog(f,Hinv,'k'); hold on
loglog(f,Hinv_smooth,'r')
loglog(f, ones(size(f)),'k--')
xlabel('freq (Hz)')
title('Hinv');
legend('Raw','Low pass')

% Calculate inverse in time domain
h = real(ifft(Hinv_smooth));
h = h(1:100);
h = h/sum(h);
xlim([0 100])

subplot(3,2,5)
tt = (1:length(h))*dt;
plot(tt, h)
hold on
title('h(t)')
plot([tt(1) tt(end)], [0 0],'--k')

subplot(3,2,6)
plot(tt, [0; cumsum(h(1:end-1))]);
title('Step response of h(t)')


maximize;
fixticks

% Save filter
filt = h;
save('stepFilter.mat','tt','filt')


% Predict overall response



%% Example of decvolution

x=0:.01:20;y=zeros(size(x));
y(900:1100)=1;                % Create a rectangular function y, 
                              % 200 points wide
y=y+.01.*randn(size(y));      % Noise added before the convolution
c=exp(-(1:length(y))./30);    % exponential trailing convolution 
                              % function, c
yc=conv(y,c,'full')./sum(c);  % Create exponential trailing rectangular
                              % function, yc
% yc=yc+.01.*randn(size(yc)); % Noise added after the convolution
ydc=deconv(yc,c).*sum(c);     % Attempt to recover y by 
                              % deconvoluting c from yc
% Plot all the steps
figure
subplot(2,2,1); plot(x,y); title('original y');subplot(2,2,2); plot(x,c);title('c'); subplot(2,2,3); plot(x,yc(1:2001)); title('yc'); subplot(2,2,4); plot(x,ydc);title('recovered y')


