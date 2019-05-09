function [map,thismanyhits] = heatmap3ct(traceOrig,DFForZ,camtime,timeFP_frames,startFr,endFr,lowRes)

trace=round(traceOrig/lowRes); %reduce tracking resolution

%% correct non-tracked epochs by carrying forward last measurement
% Cleversys assigns -1 to non-tracked frames
j=1;
traceC=trace;
for j=1:length(trace);
    if trace(j)<=0; 
        traceC(j,:)=traceC(j-1,:);
    end
    j=j+1;
end

%% offset tracking to 1,1
offset = min(traceC);
offsetXY = zeros(length(trace),2);
offsetXY(:,1)=offset(1);
offsetXY(:,2)=offset(2);
traceCC=traceC-offsetXY+1;


%% create an array of indices for timeFP_RS that match the tracking frames 
% timeFP_frames has a time course matching timeFP_RS with interpolated frame numbers
timeFP_frames(1)=1; %corrects beginning edge artifact;
A=timeFP_frames==(floor(timeFP_frames)); %preserves index position of whole number frames
B=timeFP_frames.*A; %zeros non-whole number indices
C=find(B>0);% list of indices for whole number frames
frameIndex=C(1:max(timeFP_frames)); %elides artifactual repeats at end of timeFP_frames

% find frame# when tracking starts, offset to create index for dff 
% assumes that tracking starts at nominal time, ends at last frame of video
startTrackFr = length(camtime) - length(traceCC);

%% sum dff or z for the time spent in each tracking frame
% dffBin(1)=sum of dFF for 1st frame of tracking 
dffBin=zeros(length(traceCC),1); 
for r=1:(length(traceCC)-1); %sums dff for each frame through penultimate
    s=startTrackFr+r;
    dffBin(r)=sum(DFForZ(frameIndex(s):(frameIndex(s+1)-1)));
    r=r+1;
end
dffBin(length(traceCC))=DFForZ(max(frameIndex)); % take dff at last point for final bin


%% create the map for a specified frame range
% NB frame range = startFr:endFr, must be offset
startFrC=startFr-startTrackFr+1;
endFrC=endFr;%-startTrackFr+1; %shouldn't need to offset endFr, vid & tracking co-terminate
map=zeros(max(traceCC(:,1)),max(traceCC(:,2))); %2D grid rep tracking area
thismanyhits=map+1; %counter for number of visits to each spot

for k=startFrC:endFrC;
    map(traceCC(k,1),traceCC(k,2))=map(traceCC(k,1),traceCC(k,2)) + dffBin(k);
    thismanyhits(traceCC(k,1),traceCC(k,2)) = thismanyhits(traceCC(k,1),traceCC(k,2)) +1;
    k=k+1;
end

%% make figures & save

spaceHeatDFF = figure; imagesc(map./thismanyhits); colormap jet;
spatialmap = figure;plot(traceCC(startFrC:endFrC,1),traceCC(startFrC:endFrC,2)); %map restricted to heatmap times

tagA=num2str(round(camtime(startFr)/60));
tagB=num2str(round(camtime(endFr+startTrackFr)/60));
svstr=strcat('dFFheat',tagA,'mTo',tagB,'m');
mkdir(svstr);
savename=strcat(svstr,'\',svstr,'.mat');
save(savename,'map','thismanyhits','traceOrig','startFr','endFr','lowRes','DFForZ','camtime','timeFP_frames');

savefigSpaceHeatdffF = strcat(svstr,'\',svstr,'heat_dFF');
savefigSpaceHeatdffP = strcat(svstr,'\',svstr,'heat_dFF','.png');

savefigSpaceMapF = strcat(svstr,'\',svstr,'track');
savefigSpaceMapP = strcat(svstr,'\',svstr,'track','.png');

savefig(spaceHeatDFF,savefigSpaceHeatdffF)
saveas(spaceHeatDFF,savefigSpaceHeatdffP)

savefig(spatialmap,savefigSpaceMapF)
saveas(spatialmap,savefigSpaceMapP)

end