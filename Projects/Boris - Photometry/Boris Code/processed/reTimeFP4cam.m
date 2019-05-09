% this function outputs two alternate time bases (x) to use with FP y data
    % original time base is timeFP_RS, derived from FP x data, nominally 100Hz
    % or whatever the FP data was resampled to
    
    % video time  = camtime

    % timeFP_RSretime warps timeFP_RS to match the variable frame rate expressed in camtime
    % timeFP_frames replaces time in timeFP_RSretime with frame #, so FP y
    % data can be plotted vs video frame #

function [timeFP_RSretime, timeFP_frames] = reTimeFP4cam(camtime,timeFP_RS);

% plot FP trace against frame number (fractional)
% define a new timebase timeFP_retime
% resample timeFP_frames to length of timeFP_RS
c=1;
for b= 1:length(timeFP_RS);
    while c<=length(camtime);
        if abs(timeFP_RS(b)-camtime(c))<0.006; % may generate an error, try .006
            timeFP_RSretime(b) = camtime(c);
            timeFP_frames(b) = c;
            c=c+1;
            %d=1;
        else
            %timeFP_zeros(b)=timeFP_RSretime(b-d) + d*.01;
            %d=d+1;
        end
        b = b + 1;
    end
end
    
timeFP_RSretime=timeFP_RSretime';
timeFP_frames=timeFP_frames';

% generate list of times between frames
timeDelt = camtime(2:end)-camtime(1:end-1);

% generate list of # of time pts to interpolate between frames
tII = [0 find(timeFP_RSretime)'];
timeIncr = tII(2:end)-tII(1:end-1); 

%generate list of time increments for each inter-frame period
addthis = timeDelt./timeIncr(2:end)';
addthisframes = 1./timeIncr';

% do the first chunks before the loop, they are treated differently
timeFP_RSretime(1:tII(2)-1) = timeFP_RSretime(tII(2))-(mean(addthis)*(tII(2)-1)) : mean(addthis) : timeFP_RSretime(tII(2))-mean(addthis);
initialGroup = linspace(timeFP_frames(1), timeFP_frames(tII(2)), tII(2)+1);
initialGroup(1) = [];
timeFP_frames(1:tII(2)) = initialGroup;

% fill in groups 2 through end
for e=2:length(tII)-1

   last = tII(e);
   next = tII(e+1);

   % create filler data and slot it in place
   fillerDat = linspace(timeFP_RSretime(last), timeFP_RSretime(next), next-last+1);
   timeFP_RSretime(last:next) = fillerDat;

   fillinframe = linspace(timeFP_frames(last), timeFP_frames(next), next-last+1);         
   timeFP_frames(last:next) = fillinframe;

end

timeFP_RSretime(length(timeFP_RSretime)+1:length(timeFP_RS))=timeFP_RS(length(timeFP_RS));
timeFP_frames(length(timeFP_frames)+1:length(timeFP_RS))=timeFP_frames(length(timeFP_frames));
end

























