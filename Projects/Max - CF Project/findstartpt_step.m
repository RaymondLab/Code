function startpt = findstartpt_step(dat, chanNum, expmtType, freq)

    %% Calculate Fits
    samplerate = dat(5).samplerate;
    headVel = dat(5).data;
    drumVel = dat(7).data;
    
    % Fit vars
    segLength = length(headVel);
    segTime = (1:segLength)/samplerate; 
    cycleLength = round(samplerate/freq);
    %cycleTime = (1:cycleLength)/samplerate;
    
    y1 = sin(2*pi*freq*segTime(:));
    y2 = cos(2*pi*freq*segTime(:));
    constant = ones(segLength,1);
    vars = [y1 y2 constant];
    
    % headVel
    b = regress(headVel, vars);
    headVel_amp = sqrt(b(1)^2+b(2)^2);
    headVel_angle = rad2deg(atan2(b(2), b(1)));

    % drumVel
    b = regress(drumVel, vars);
    drumVel_amp = sqrt(b(1)^2+b(2)^2);
    drumVel_angle = rad2deg(atan2(b(2), b(1)));
    
    switch expmtType
        case 'x0'
            reference_angle = headVel_angle;
        case 'x2'
            reference_angle = headVel_angle;
        case 'OKR'
            reference_angle = drumVel_angle;
        case 'VORD'
            reference_angle = headVel_angle;
        otherwise
            reference_angle = 0;

    end

    
    % Find Start Point
    startpt = max(1,round(mod(-reference_angle,360)/360 * dat(chanNum).samplerate/freq));


end
