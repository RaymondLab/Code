function [ipsi,contra] = findipsicontra(hhvel,mincycle, ploton)
% beh is the dat structure with a channel named hhvel
% rejecttime is the time to reject from the beginning or the end
% (more cs for ipsi during gain up, more cs for contra during gain down)
% for ELVIS, + is ipsi and - is contra --> but this should be flipped already
% for DARWIN, + is contra and - is ipsi
% So in all files, + is contra and - is ipsi
 
tt = dattime(hhvel);
dt = tt(2)-tt(1);
data = hhvel.data;

data = data/max(data); % normalize
deriv= [0 diff(data(:))']/dt;
 
accthresh = 40;
velthresh =  .2;%***%1
if ~exist('mincycle','var'); mincycle = .2; end
mincyclelength = round(mincycle/dt);
ipsiind = [];
contraind = [];
i = 2;
 
iWindow = round(.060/dt);
 
while any(data(i:i+iWindow)>velthresh) || any(data(i:i+iWindow)<-velthresh)
    i = i+1;
end
 
while i <= length(deriv)-mincyclelength/2;
    if deriv(i) >= accthresh  && all(data(i+1:i+iWindow)>velthresh) %&& all(deriv(i+1:i+15)>=0) +30
        ipsiind = [ipsiind i];
        i = i + mincyclelength;
    elseif  deriv(i) <= -accthresh && all(data(i+1:i+iWindow)<-velthresh) % && all(deriv(i+1:i+15) <=0)
        contraind = [contraind i];
        i = i + mincyclelength;
    else
        i = i+1;
    end
end
 
% Fix offset
ipsi = tt(ipsiind) - 0.003;
contra = tt(contraind)- 0.0030;
 
fprintf('IPSI n=%i, min %g s, max %g s\n',length(ipsi),min(diff(ipsi)),max(diff(ipsi)));
fprintf('CONTRA n=%i, min %g s, max %g s\n',length(contra),min(diff(contra)),max(diff(contra)));
  
%% Testing
if exist('ploton','var') && ploton
figure; clf
h=plot(tt, data); set(h,'Color','k');
hold on
h(1)=plot(contra,data(contraind),'+r','LineWidth',2);
h(2)=plot(ipsi,data(ipsiind),'+c','LineWidth',2);
legend(h, {'contra','ipsi'})
end