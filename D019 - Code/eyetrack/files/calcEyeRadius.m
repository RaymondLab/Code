function rP = calcEyeRadius(results, thetadeg)
% Give theta in degreess pleass

theta = thetadeg;

p1 = results.pupil1(:,1);
p2 = results.pupil2(:,1);
c1 = results.cr1a(:,1);
c2 = results.cr2b(:,1);

%% Calculate distance between pupil and CR
d1 = p1 - c1;
d2 = p2 - c2;

% Calculate pupil radius using approxiamate method of Stahl 2000
rP_bad = abs(d1-d2)/(theta*pi/180);
% fprintf('rP rough method: %g \n',nanmean(rP_bad));
rP_all = abs(d1-d2)/(2*sind(theta/2)); 
% fprintf('rP better method: %g \n',nanmean(rP_all));

rP_out = rP_all; 

% Remove outliers
outliers = abs(rP_out-nanmedian(rP_all)) > 3*nanstd(rP_out);
rP_out(outliers) = NaN;

rP = nanmedian(rP_out);

%% Plotting
% figure; clf; hist(rP_out,min(rP_out):.2:max(rP_out));
% hold on;
% % [n,x] = hist(rP_good);
% % bar(x,n,1,'r')
% 
% plot([rP rP], get(gca,'YLim'),'r--','LineWidth',2)
% xlabel('Pupil radius (pixels)')
% ylabel('Count')
end