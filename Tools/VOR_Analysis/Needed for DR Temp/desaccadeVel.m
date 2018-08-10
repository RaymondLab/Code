function [eyevelOut, omitCenters] = desaccadeVel(eyevelIn, threshold,  presaccade, postsaccade, ploton)

%% Find saccades in eye movement and blank out an interval on either side
%find regions of data outside threshold; 
omitCenters = abs(eyevelIn) > threshold;

%remove points around omit centers as defined by pre- & postsaccade time
sacmask = ones(1,presaccade+postsaccade);

%filter function replaces zeros with ones (equal to remove time) around an omit center
rejecttemp1 = conv(double(omitCenters),sacmask);
rejecttemp2 = rejecttemp1(presaccade:presaccade+length(eyevelIn)-1);

% eyevel with desaccade segments removed
eyevelOut = eyevelIn;
eyevelOut(logical(rejecttemp2))= NaN;


%% DEBUG
if exist('ploton','var') && ploton
    figure(ploton);clf;
    plot(eyevelIn,'k','LineWidth',1); hold on
    plot(eyevelOut,'r','LineWidth',.5);
    try
        plot(find(omitCenters),0,'ob','LineWidth',3)
    catch
    end
    ylim([-50 50])    
end