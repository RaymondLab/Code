%clear PSTHarr tookthese

function [PSTHarrNew,markFP,markFPfr]=FPpsth(camtime,timeFP_RS,timeFP_frames,dfofCorr,evTime,J,K,p,q,S,Norm)

%J=500; %pre
%K=500; %post
%p=299; %start baseline J-p
%q=50;  %end baseline J-q
%S=K;   %skip this many after last event
for i = 1:length(evTime);
    FPx(i) = find(timeFP_RS>camtime(evTime(i)),1);                  % retrieve timeFP_RS corresponding to frame-indexed camtime
    if i==1                                                         % 1st event special case
        PSTHarr(:,i) = dfofCorr(FPx(i)-J:FPx(i)+K);                   % take the J samples before and K after the event time
        PSTHarr(:,i) = PSTHarr(:,i) - mean(PSTHarr((J-p):(J-q),i));   % subtract baseline with pts J-p:J-q
        tookthese(i) = FPx(i);
        tooktheseFr(i) = evTime(i);
    end
    if i>1 && FPx(i)> max(tookthese) + S && (FPx(i)+K)<length(dfofCorr);%   %(FPx(i-1)+500)             % go at least S points ahead of last event
        PSTHarr(:,i) = dfofCorr(FPx(i)-J:FPx(i)+K);
        if Norm==1
            PSTHarr(:,i) = PSTHarr(:,i) - mean(PSTHarr((J-p):(J-q),i));
        end
        tookthese(i) = FPx(i);
        tooktheseFr(i) = evTime(i);
    end
    i=i+1;
end
PSTHarrNew = PSTHarr;
PSTHarrNew(:,all(~PSTHarrNew,1))=[]; %remove col w zeros
tookthese(:,all(~tookthese,1))=[];
tooktheseFr(:,all(~tooktheseFr,1))=[];

% make a vector to mark the complete time course with event flag
markFP(1:length(dfofCorr))=0; markFPfr(1:length(dfofCorr))=0;
mm=1;
for mm=1:length(tookthese);
    markFP(tookthese(mm)) = 1;
    oo=find(timeFP_frames==tooktheseFr(mm),1);
    markFPfr(oo) = 1;
    mm=mm+1;
end

overlayPSTH = figure;plot(PSTHarrNew)
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    labeltext=strcat('pre ', num2str(J),'pts, post ',num2str(K),'pts, skip ',num2str(S),'pts, baseline ea trace fr ',num2str(J-p),' to ',num2str(J-q));
    text(xlim(2)/20,ylim(1)+(ylim(2)-ylim(1))*.05,labeltext);
    label2=strcat(num2str(length(tookthese)),' traces');
    text(xlim(2)/20,ylim(2)*.8,label2);
%%
% make a pretty average SEM
avgPSTH=mean(PSTHarrNew,2);avgPSTH=avgPSTH';
semPSTH = std(PSTHarrNew,0,2)/sqrt(size(PSTHarrNew,2));semPSTH=semPSTH';
timeAxis = -J:K; 
semPSTHplus = avgPSTH + semPSTH; 
semPSTHminus = avgPSTH - semPSTH;

time4fill=[timeAxis,fliplr(timeAxis)];
MEANSEMplusFR=[avgPSTH,fliplr(semPSTHplus)];
MEANSEMminuFR=[avgPSTH,fliplr(semPSTHminus)];
    avgsemPSTH=figure; hold on;
    plot(timeAxis,avgPSTH, timeAxis,semPSTHplus,timeAxis,semPSTHminus);
    h=fill(time4fill,MEANSEMplusFR,'g',time4fill,MEANSEMminuFR,'g');% ,'EdgeColor','none')
    set(h,'facealpha',.2);
    %axis([-J K+1 (min(psthMeanFront)-0.01) (max(psthMeanFront)+.01)]);
    %axis([-J K+1 (min(semPSTHminus)-0.01) (max(semPSTHplus)+.01)]);
    axis([-J K+1 -1 3]);
    ylabel ('df/f or z-score','FontWeight','bold');
%%  graph just the avg trace
avgPSTHnoSEM = figure;plot(mean(PSTHarrNew,2));
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    labeltext=strcat('pre ', num2str(J),'pts, post ',num2str(K),'pts, skip ',num2str(S),'pts, baseline ea trace fr ',num2str(J-p),' to ',num2str(J-q));
    text(xlim(2)/20,ylim(1)+(ylim(2)-ylim(1))*.05,labeltext);

%% graph the array heatmap
    heatmapPSTH = figure;
    imagesc(PSTHarrNew')
%% save everything
svstr=strcat('PSTHpre', num2str(J/100),'post',num2str(K/100),'q',num2str(S/100));
mkdir(svstr);
savename=strcat(svstr,'\',svstr,'.mat');
save(savename,'PSTHarrNew','markFP','markFPfr','evTime','avgPSTH','semPSTH')

savefigOvLayF = strcat(svstr,'\',svstr,'OvLay');
savefigOvLayP = strcat(svstr,'\',svstr,'OvLay','.png');
savefigAvgF = strcat(svstr,'\',svstr,'Avg');
savefigAvgP = strcat(svstr,'\',svstr,'Avg','.png');
savefigAvgSemF = strcat(svstr,'\',svstr,'AvgSem');
savefigAvgSemP = strcat(svstr,'\',svstr,'AvgSem','.png');
savefigHeatMapF = strcat(svstr,'\',svstr,'HeatMap');
savefigHeatMapP = strcat(svstr,'\',svstr,'HeatMap','.png');

savefig(overlayPSTH,savefigOvLayF)
saveas(overlayPSTH,savefigOvLayP)

savefig(avgPSTHnoSEM,savefigAvgF)
saveas(avgPSTHnoSEM,savefigAvgP)

savefig(avgsemPSTH,savefigAvgSemF)
saveas(avgsemPSTH,savefigAvgSemP)

savefig(heatmapPSTH,savefigHeatMapF)
saveas(heatmapPSTH,savefigHeatMapP)
