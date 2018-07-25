% takes each "bout" of activity from frame [C1] to [C2]
% and calculates a running total of df/f over multiple bouts
% input bouts as RxC w C1 = start C2 = end

% make an array to store the integrated bout df/f
% need to find the longest bout to create the array

function[boutArray,boutInteg,CumBoutInteg] = boutDFF(bouts,dfofCorr)

clear boutlength boutInteg boutfloor boutArray CumBoutInteg
boutlength = (bouts(:,2) - bouts(:,1));
boutArray(1:max(boutlength),1:length(bouts)) = zeros;
boutInteg(1:max(boutlength),1:length(bouts)) = zeros;


r=1;
s=1;

for r=1:length(bouts); %iterate each bout
    boutfloor = min(dfofCorr(bouts(r,1):bouts(r,2))); %correction for each bout so min df/f = 0;
   
    boutArray(1,r) = dfofCorr(bouts(r,1)) - boutfloor; % fill first row of integrated array to start
    boutInteg(1,r) = dfofCorr(bouts(r,1)) - boutfloor; 
        
    for s=2:boutlength(r); %iterate for the length of the each bout
        boutArray(s,r)= dfofCorr(bouts(r,1)+s -1) - boutfloor;                  %fill array with df/f
        boutInteg(s,r) = dfofCorr(bouts(r,1)+s -1) + boutInteg(s-1,r) - boutfloor; %cumulative sum calc

        s=s+1;
    end
   
    boutArray(s:max(boutlength),r)=NaN;  %fill points from end bout with NaN
    boutInteg(s:max(boutlength),r)=NaN; 
    r=r+1;
end

%%
concatbout = reshape(boutArray,[],1);
concatbout(isnan(concatbout))=[];

CumBoutInteg(length(concatbout))=zeros;
p=1;
CumBoutInteg(p)=concatbout(p);
for p=2:length(concatbout);
    CumBoutInteg(p) = CumBoutInteg(p-1) + concatbout(p);
    p=p+1;
end

%%

IndivBouts = figure;plot(boutArray)
IndBoutInteg = figure;plot(boutInteg)
CumBoutConcat = figure;plot(CumBoutInteg)

%%
svstr=strcat('Total', num2str(length(bouts)),'bouts',num2str(length(concatbout)/100),'sec');
mkdir(svstr);
savename=strcat(svstr,'\',svstr,'.mat');
save(savename,'boutArray','boutInteg','CumBoutInteg','bouts');

savefigOvLayF = strcat(svstr,'\',svstr,'OvLay','.fig');
savefigOvLayP = strcat(svstr,'\',svstr,'OvLay','.png');
savefigIndCumF = strcat(svstr,'\',svstr,'IndCum','.fig');
savefigIndCumP = strcat(svstr,'\',svstr,'IndCum','.png');
savefigCumIntegF = strcat(svstr,'\',svstr,'TotCum','.fig');
savefigCumIntegP = strcat(svstr,'\',svstr,'TotCum','.png');


savefig(IndivBouts,savefigOvLayF)
saveas(IndivBouts,savefigOvLayP)

savefig(IndBoutInteg,savefigIndCumF)
saveas(IndBoutInteg,savefigIndCumP)

savefig(CumBoutConcat,savefigCumIntegF)
saveas(CumBoutConcat,savefigCumIntegP)
end
