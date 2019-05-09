
%% put data into matlab format
savename = TDT_MATformatBDH(1); %channel 1 or 2
%savename = FormatForFPpipe(sig,ref);  %if data already converted, feed to FP pipe
                                % preload in sig and ref .mat
savename=strcat(savename,'.mat');
load(savename)

%% debleach, calc df/f, subtract 405 from 472
debleach_flag=1; 
numExp = 2;  %0 = cubic poly fit, 1=single exp fit,  2=dbl exp fit
startfit = 100; % start exp fit at this min (*100hz & 60sec)
endfit =length(sig_472_RS); %50*6000; %length(sig_472_RS);  % end fit
baseline_method=2   % 1=main peak of histogram for dataset 
                    % 2=median val
                    % 3=manually assigned baseline (set manualbase)
manualbase=152;
dfof=debleachBDH(timeFP_RS,sig_472_RS,'472',savename,debleach_flag,numExp,startfit,endfit,baseline_method,manualbase);
dfof_control=debleachBDH(timeFP_RS,sig_405_RS,'405',savename,debleach_flag,numExp,startfit,endfit,baseline_method,manualbase);

% subtract reference signal
subtract_method='Subtract';
dfofCorr=subtract_refBDH(timeFP_RS,dfof,dfof_control,savename,subtract_method);
    % subtract_method='MinResid'  use bestfit model
    % subtract_method='Subtract' just subtract them
    % subtract_method='None' no correction with 405
    % subtract_method= number, manually add this value

    %% alternate 405 correction, scale 405 to match 472
        raw472=sig_472_RS;
        scaled_405=controlFit(sig_472_RS,sig_405_RS);
        %scaled_405=scaled_405';
        dfofCorrScale=(sig_472_RS-scaled_405)/mean(scaled_405);
        subtract_method=.0;
        dfofCorrScale=subtract_refBDH(timeFP_RS,dfofCorrScale',scaled_405,savename,subtract_method);

        %dfofCorr=dfofCorrScale; % depending correction looks better
figure;hold on; plot(dfofCorrScale); plot(dfofCorr); plot(dfof)
    
%% smooth, z-score
dfofCorr=filtfilt(ones(1,100)/100,1,dfofCorr);
%z score
ZdfofCorr = (dfofCorr - mean(dfofCorr(1000:length(dfofCorr))))  / std(dfofCorr(1000:length(dfofCorr)));

savename2=strcat(savename,'_dFFcorr');

save(savename2,'dfofCorr','ZdfofCorr','camtime','timeFP_RS');

        %% for video acquired in a separate program from FP
        % trim FP to match video length
        delayVid=10.2; %in seconds
        timeFP_RS=timeFP_RS-delayVid;
        camtime=camtime-delayVid;
        TrimFPtimeInd = timeFP_RS>=0; 
        TrimCamtimeInd=camtime>=0;
        camtime = camtime(TrimCamtimeInd);
        timeFP_RS = timeFP_RS(TrimFPtimeInd); 
        dfofCorr=dfofCorr(TrimFPtimeInd);
        ZdfofCorr=ZdfofCorr(TrimFPtimeInd);

        savename3=strcat(savename,'_dFFcorrTrim');
        save(savename3,'dfofCorr','ZdfofCorr','camtime','timeFP_RS');


%text(5.2416,0.2,'LORR \downarrow','HorizontalAlignment','right')

%% manual demodulate: check contoperator
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% warp time basis to fit cam frame times 
% prepare for close viewing the FP trace
% _RSretime warps time basis, _frames matches _RSretime, replacing frame #
% with time
[timeFP_RSretime, timeFP_frames] = reTimeFP4cam(camtime,timeFP_RS);
figure;plot(timeFP_frames, dfofCorr)
set(gca,'Xtick',0:50:length(timeFP_frames))

savename4 = strcat(savename,'_updatedTimes');
save(savename4, 'timeFP_RSretime', 'timeFP_frames');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% new PSTH
%evTime is vector holding frames of interest
%Assume 100Hz resampling
%use dfofCorr or ZdfofCorr in FPpsth arguments
%timeFP_frames=timeFP_RS; %if using video not encoded by Synapse
    Pre=300;
    Post=400;
    BaseStart=290;%Pre*.9;
    BaseEnd=100;%Pre*.1;
    Skip=400;
    Norm =1; %=0 no normalization to baseline,   =1 normalize to baseline
[PSTHarrNew,markFP,markFPfr]=FPpsth(camtime,timeFP_RS,timeFP_frames,dfofCorr,evTime,Pre,Post,BaseStart,BaseEnd,Skip,Norm); %camtime,FP time, proc FP, events, pre, post, start baseline @ -, end baseline @ -

ylim([-0.14 .55]);

%plot FP vs time with events marked
%figure;plot(timeFP_RS,dfofCorr);hold on; plot(timeFP_RS,markFP);

%plot FP vs frame number with events marked
figure;plot(timeFP_frames,dfofCorr);hold on; plot(timeFP_frames,markFPfr);


%% heatmap, esp for 3CT
% create variable trace(x,y)
% animal tracking can start at arbitrary pt, must continue to end of expt
%MUST FIX discrepancy between frame count in CleverSys and matlab

lowRes = 10; %factor to reduce map density. native trace should be in mm
startFr=21600;
endFr=length();
[mapDec,thismanyhitsDec] = heatmap3ct(trace,ZdfofCorr,camtime,timeFP_frames,startFr,endFr,lowRes);


%% needs a [R,2] matrix of beginning and end frames for each bout
[boutArray,boutInteg,CumBoutInteg] = boutDFF(bouts,dfofCorr);
%%


% plot mean of a subset of PSTHarrNew
bb=1
hold on; plot(mean(PSTHarrNew(:,bb:bb+9),2));



% spectrogram
%figure;
%spectrogram(dfofCorr,kaiser(30000,10),24000,100000,100,'yaxis');ylim([0 1]);caxis([-40 0])
% 5 min window, overlaps by 4min (should be 1div/min), 100K pt freq
% resolution to get lower registers, 100Hz sampling
