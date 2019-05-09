%% Generate learning experiment with step patterns
% Hannah Payne
% Raymond Lab
% 1/6/2016
%
% Generates files for experiment
% Stores .mat (for later anaylys) and .txt file (for Spike2)
% (for running the experiment in Spike2 via arbitrary stimulus)
% Columns of text file: 
% For Drum Chair Light 
%
% Two files: test and train


% function generate_stepLearnExpmt_20160106
clear; clc

dt = 0.001;                 % (s) Time Step
stepLength =  0.600;         % (s) length of step
rampLength = 0.04;           % (s) tau of exp filter of acc/dec ramp  (set to a really small number i.e. 1e-6 for no ramp)
waitLength = 0.250;          % (s) time between adjacent steps  
lightDuration = 0.250;         % (s) Light stim duration
lightDelay = 0.05;            % (s) Delay from start of step to start of light
lightFlashPause = 10;       % (s) pause for light flash 
trainLength = 300;          % (s) 
testLength = 40;            % (s)
fs = 1/dt;

% To use precise step filter, choose here
% F = load('stepFilter.mat');

filename_test = sprintf('stepTest_C%i_W%i.txt', stepLength*1000, waitLength*1000);
filename_train =  sprintf('stepTrain_C%i_W%i_L%i_D%i.txt', stepLength*1000, waitLength*1000, lightDuration*1000, lightDelay*1000);

%% Generate  test 
totalTime = testLength + lightFlashPause;
nt = totalTime/dt;
dataDrum  = zeros(nt,1);
dataChair = zeros(nt,1);
dataLight = zeros(nt,1);

currt = 0;

% FLASH light
dataChair(currt*fs+1:end) = 0;
dataDrum(currt*fs+1:end) = 0;
dataLight(currt*fs+1:end) = 0;

dataLight((currt*fs+1):(currt+.2)*fs) = true; % actual light pulse is .2s
currt = currt + 10;

% Run test
nSteps = floor(testLength/(waitLength+stepLength));
currSign = repmat([1 -1], 1,ceil(nSteps/2));
for k = 1:nSteps
    % Chair
    currInds = round((currt*fs+1):(currt*fs+stepLength*fs));
    dataChair(currInds) = currSign(k);
    currt = currt + waitLength + stepLength;
end
    
% Filter with data-driven impulse function
if exist('F','var')
    filter_temp = F.filt;
else
% Filter Chair exponentially to get good step
tfilt =(0:(rampLength*4*fs))/fs;
filter_temp = exp(-tfilt/rampLength);
end
% Filter with a ramp
% tfilt =(0:(rampLength*fs))/fs;
% filter_temp = ones(size(tfilt));

dataChair = filter(filter_temp,sum(filter_temp), dataChair);
dataDrum = filter(filter_temp,sum(filter_temp), dataDrum);

% Save data in txt file
writeTxt4Spike2(filename_test, fs, [dataDrum*10, dataChair*10, dataLight])

% Plot experiment
figure(1); clf
subplot(121)
plot((1:nt)*dt,dataDrum,'b'); hold on
plot((1:nt)*dt,dataChair+2.2,'r')
plot((1:nt)*dt,dataLight+4.2,'k');
title('test')
legend('Drum','Chair','Light')

        
 %% Run training
 totalTime = trainLength;
nt = totalTime/dt;
dataDrum  = zeros(nt,1);
dataChair = zeros(nt,1);
dataLight = zeros(nt,1);

currt = 0;

% Run test
nSteps = floor(trainLength/(waitLength+stepLength));
currSign = repmat([1 -1], 1,ceil(nSteps/2));
for k = 1:nSteps
    % Chair
    currInds = round((currt*fs+1):(currt*fs+stepLength*fs));
    dataChair(currInds) = currSign(k);
    
    % Drum
    dataDrum(currInds) = currSign(k);
    
    % Light pulse
    lightStart = round(currt*fs + 1 + lightDelay*fs);
    lightStop = round(lightStart + lightDuration*fs);
    currInds_light = lightStart:lightStop;
    dataLight(currInds_light) = true;
    
    currt = currt + waitLength + stepLength;
end
    
% Filter

dataChair = filter(filter_temp,sum(filter_temp), dataChair);
dataDrum = filter(filter_temp,sum(filter_temp), dataDrum);

% Save data in txt file
writeTxt4Spike2(filename_train, fs, [dataDrum*10, dataChair*10, dataLight])

% Plot experiment
subplot(122)
plot((1:nt)*dt,dataDrum,'b'); hold on
plot((1:nt)*dt,dataChair+2.2,'r')
plot((1:nt)*dt,dataLight+4.2,'k');
title('Train')
legend('Drum','Chair','Light')


% end