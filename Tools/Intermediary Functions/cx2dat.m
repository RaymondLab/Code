function chanData = cx2dat(filename, chanAmt, samplerate)

    % Assume sample rate of 500
    if ~exist('samplerate','var')
        samplerate = 500;
    end
    
    %% Open 
    behavior = readcxdata(filename, 0, chanAmt);
    if isempty(behavior.data)
        warning('Something went wrong!')
        chanData = [];
        return
    end
    
    %% Flip data for elvis so that contra is up and ipsi is down TODO - double check
    if ~isempty(regexp(filename,'da','once'))
        behavior.data = -behavior.data;
    end
    
    %% Seperate, Label, Scale and Clean each Channel TODO - double check
    
    % Horizontal Gaze Velocity
    hgpos = behavior.data(1,:) *12.5 *(1/samplerate);
    
    % Vertical Eye Position
    vepos = behavior.data(2,:) *12.5 *(1/samplerate);
    
    % Horizontal Eye Velocity
    hevel = behavior.data(3,:) *0.09189;
    
    % Horizontal Gaze Position
    htpos = behavior.data(4,:) *12.5 *(1/samplerate);
    
    % Horizontal Head Velocity
    hhvel = behavior.data(5,:) *0.09189;
    hhvel = hhvel-mean(hhvel);
    
    % Horizontal Drum Velocity (Second Eye Chan?) TODO find out what this channel is
    hdvel = behavior.data(6,:) *0.09189;
    
    % Unknown Channel TODO find out what this channel is
    if chanAmt == 7
        unknown = behavior.data(7,:);
    end

    % Horizontal Target Velocity
    veltau = .01;
    htvel = movingslopeCausal(htpos,round(samplerate*veltau))*samplerate;
    
    %% Other calculations
    
    % Time Vectors
    timeVec = 0:1/samplerate:(length(htpos)-1)/samplerate;
    tstart = timeVec(1);
    tend   = timeVec(end);

    % ms --> s
    timeofcomplexspikes = behavior.sortedSpikes{1}*0.001;
    timeofsimplespikes = (behavior.spikes)*0.001;
    if isempty(timeofsimplespikes)
        timeofsimplespikes = (behavior.events)*0.001;
    end
    
    %% Store data in dat format
    chanData        = dat(hgpos,'Horz Gaze Vel',    1,samplerate,tstart, tend,'deg');
    chanData(end+1) = dat(vepos,'Vert Eye Pos',     2,samplerate,tstart, tend,'deg');
    chanData(end+1) = dat(hevel,'Horz Eye Pos',     3,samplerate,tstart, tend,'deg/s');
    chanData(end+1) = dat(htpos,'Horz Target Pos',  4,samplerate,tstart, tend,'deg');
    chanData(end+1) = dat(hhvel,'Horz Head Vel',    5,samplerate,tstart, tend,'deg/s');
    chanData(end+1) = dat(hdvel,'Horz d Vel (eye2)',6,samplerate,tstart, tend,'deg/s');
    chanData(end+1) = dat(htvel,'Horz Target Vel',  7,samplerate,tstart, tend,'deg/s');
    if chanAmt == 7
        chanData(end+1) = dat(unknown, 'Unknown',   8,samplerate, tstart, tend,'?');
    end
    chanData(end+1) = dat(timeofsimplespikes,'ss',  9,'event',tstart, tend,'s');
    chanData(end+1) = dat(timeofcomplexspikes,'cs', 10,'event',tstart, tend,'s');
    
end
