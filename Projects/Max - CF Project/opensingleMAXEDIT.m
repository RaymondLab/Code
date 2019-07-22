% OPENSINGLE Opens a single file for analysis (Lisberger lab format)
%   beh = opensingle(filename) Opens the file into Hannah's dat format
%   including manual alignment of complex spikes
%   beh = opensingle(filename, loadCS) 
%
%   Hannah Payne 2012
%   https://sites.google.com/a/srscicomp.com/maestro/data-analysis/supported-matlab-tools/readcxdata
% 
%   Edited 9/20/16 
%       1. fix calibration factor for chair: step SS should be 15.0 -
%       15.1, eye should not overshoot target
%       2. Using 100 Hz low pass filtered eye velocity instead of 25 Hz
%       3. Option to load or not load CS
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beh = opensingleMAXEDIT(filename, ephys_exists, full_ephys)

    %% Opens Cntrlx file in Matlab and saves as "behavior"
    behavior = readcxdata(filename, 0, 6); % 6 channels for jennifer, 7 for Akira
    %disp(behavior.sortedSpikes(1))    
    
    %% Flip data for elvis so that contra is up and ipsi is down
    if ~isempty(regexp(filename,'da','once'))
        behavior.data = -behavior.data;
    end
    
    % Assigns structures in "behavior" to specific signals
    dt = .002;
    hgpos = behavior.data(1,:);% *12.5 * dt;
    vepos = behavior.data(2,:);% *12.5 * dt;
    hevel = behavior.data(3,:);% *0.09189;
    htpos = behavior.data(4,:);% *12.5 * dt;
    hhvel = behavior.data(5,:);% *0.09189;
    hdvel = behavior.data(6,:);% *0.09189;

    % create time vectors 
    timebehavior = 0:dt:(length(htpos)-1)*dt;
    timeofsimplespikes = (behavior.spikes)*0.001;
    
    if isempty(timeofsimplespikes)
        timeofsimplespikes = (behavior.events)*0.001;
    end
    timeofcomplexspikes=behavior.sortedSpikes{1}*0.001;
    
    % Fix the offset of hhvel
    hhvel = hhvel-mean(hhvel);
    
    %% LOAD ELECTROPHYS DATA
    if ephys_exists
        data = openmaestro(full_ephys);
        fs = 50000;

        %% Creates a time variable for the ephys recording data
        timerecording=0:1/fs:(length(data)-1)/fs;
        data=data-mean(data);

        %% Fix the offset on the ephys recording trace
       
        % Jennifer
        offsetguess = 0.002;
        % Akira
        %offsetguess = 0.1205;
        timerecording=timerecording+offsetguess;% Best guess
        
        
        %% Special Akira alignment - testing
        %[pks locs] = findpeaks(data*-1, timerecording);
        %spikeamt = length(timeofsimplespikes);
        %[pks_large, inds] = maxk(pks, spikeamt);
        %locs_large = locs(inds);
        
        
        
        %%
        figure(2); clf
        hephys = plot(timerecording,data,'k','LineWidth',1); hold on;
        hSS = plot(timeofsimplespikes,0*ones(1,length(timeofsimplespikes)),'+g','LineWidth',2);
        hCS = plot(timeofcomplexspikes,0*ones(1,length(timeofcomplexspikes)),'or','MarkerFaceColor','r');
        ylim([-2.5 2.5]);

        %% Find first reference point
        spike1 = 20;
        % Jennifer
        window = .0015;
        % Akira
        %window = .005;
        
        figure(4); clf
        hephys = plot(timerecording,data,'k','LineWidth',1); hold on;
        hSS = plot(timeofsimplespikes,0*ones(1,length(timeofsimplespikes)),'+g','LineWidth',2);
        hCS = plot(timeofcomplexspikes,0*ones(1,length(timeofcomplexspikes)),'or','MarkerFaceColor','r');
        ylim([-2.5 2.5]);
        xlim([timeofsimplespikes(spike1)-window timeofsimplespikes(spike1)+window ])
        title(filename(end-9:end))


        %% Find first reference point, con't
        plot(timeofsimplespikes(spike1),0,'+g','MarkerSize',10,'LineWidth',3)
        y1 = timeofsimplespikes(spike1);

        thresh = .0030;
        vline(timeofsimplespikes(spike1)+thresh)
        vline(timeofsimplespikes(spike1)-thresh)
        [~, currinds] = find(abs(timerecording-timeofsimplespikes(spike1))<thresh);
        currdata = data(currinds);
        [maxdata, maxind] = max(abs(currdata));
        x1 = timerecording(currinds(maxind));

        ephysshift = y1 - x1
        timerecording = timerecording + ephysshift;

        % Update time on graph
        set(hephys,'XData',timerecording)
        vline(timeofsimplespikes(spike1))
        pause(.01)
        data = data-mean(data);
    end
        
    %% Save data in a dat structure
    tstart = timebehavior(1);
    tend = timebehavior(end);
    
    % Calculate Velocity
    veltau = .01;
    fs = 500;
    htvel = movingslopeCausal(htpos,round(fs*veltau))*fs;
    
    % Store data
    beh        = dat(hgpos,'Horz Gaze Vel',1,500,tstart, tend,'deg');
    beh(end+1) = dat(vepos,'Vert Eye Pos',2,500,tstart, tend,'deg');
    beh(end+1) = dat(hevel,'Horz Eye Pos',3,500,tstart, tend,'deg/s');
    beh(end+1) = dat(htpos,'Horz Target Pos',4,500,tstart, tend,'deg');
    beh(end+1) = dat(hhvel,'Horz Head Vel',5,500,tstart, tend,'deg/s');
    beh(end+1) = dat(hdvel,'Horz d Vel',6,500,tstart, tend,'deg/s');
    beh(end+1) = dat(htvel,'Horz Target Vel',7,500,tstart, tend,'deg/s');
    if ephys_exists
        beh(end+1) = dat(data, 'Ephys',7,50000,timerecording(1),timerecording(end),'mV?');
    else
        beh(end+1) = dat([], 'Ephys',7,50000,tstart,tend,'mV?');
    end
    beh(end+1) = dat(timeofsimplespikes,'ss',8,'event',tstart, tend,'s');
    beh(end+1) = dat(timeofcomplexspikes,'cs',9,'event',tstart, tend,'s');
    

