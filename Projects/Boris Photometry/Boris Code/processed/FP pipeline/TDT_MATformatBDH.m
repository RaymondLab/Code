% assign file paramters
function savename=TDTformatBDH(channel)
    if channel==1;
        eventList=['472_';'405_';'Cam1'];%'Fi1r'];
        %eventList=['472N';'405N';'Cam1'];
    elseif channel==2
        eventList=['B72B';'B05B';'Cam1'];
    end
    
    %eventList=['472_';'405_';'Cam1';'Tick'];%'Cam1'
   
    %eventList=['472N';'405N';'Cam1';'Tick'];%'Cam1'
    %event='FP1r'%
    %event='472N';

    filepath=uigetdir;
    %exptname=base; filename=dir+exptname; savename=filename+100Hz
    exptnameDef=strsplit(filepath,'\');
    exptnameDef=char(exptnameDef(length(exptnameDef)));  %the savename becomes the folder name
    exptnameDef = {exptnameDef}; %default expt name saved as a cell array of strings
    exptname = inputdlg('experiment name?','Input',1,exptnameDef,'on'); exptname = exptname{1};
    mkdir(exptname); addpath(exptname);% make a folder name for the m file output
    filename=strcat(exptname,'\',exptname); %savename dir becomes destination and filename
    
    
    % use the tdt2mat file to get a structure containing data
    S472 = TDT_MATconvertBDH(filepath,eventList(1,:));
    S405 = TDT_MATconvertBDH(filepath,eventList(2,:)); 
    Scam = TDT_MATconvertBDH(filepath,eventList(3,:));  
        %Ssync = TDT_MATconvertBDH(filepath,eventList(3,:));  % external sync pulse ('FP1r')
        %Stick= TDT_MATconvertBDH(filepath,eventList(3,:));
        %SFi1i= TDT_MATconvertBDH(filepath,eventList(3,:));
        %SFi1r= TDT_MATconvertBDH(filepath,eventList(3,:));

    % Get S.data as a vector (repeat for each channel)
    % unwrap data from m x 256 or 64 array 
    chani1S472 = S472.channels==1; sig_472 = S472.data(chani1S472,:); sig_472 = reshape(sig_472', [],1);% 472N 6kHz%'472N'
    chani1S405 = S405.channels==1; sig_405 = S405.data(chani1S405,:); sig_405 = reshape(sig_405', [],1);% 405N 6kHz%'405N'
    %camchan has timestamps and effective frame rate for camera
    if (exist('Scam'))
        camtime = Scam.timestamps; 
        camtime=camtime-camtime(1);
        
        camtime2(2:length(camtime))=camtime(1:length(camtime)-1); 
        camtime2(1)=0;
        camtime2=camtime2';%shift frame to get avg frame rate
        
        camFrRate = (camtime-camtime2); 
        camFrRate=1./camFrRate;
        camFrRateMed=median(camFrRate);
        
        figure;
        plot(camtime/60,camFrRate); 
        legend('Frame rate over time'); 
        xlabel('Time(min)');
        ylabel('FPS'); 
        title(strcat('Median frame rate =', num2str(median(camFrRate))));
    else
    end
    %sync pulse is stored on 4th channel of FP1r 'event'
        %chani4Ssync = Ssync.channels==4; sig_sync = Ssync.data(chani4Ssync,:); sig_sync = reshape(sig_sync', [],1); sig_sync = sig_sync*5;
        
    %Fi1i - not sure what this encodes
    
    %Fi1r contains raw data; channels 1 & 2 have modulated intensity of 405
    %& 472 LED (~220 & ~330Hz); channel 3 has convolved modulated fluorescence
        %SFi1rchan1=SFi1r.channels==1; SFi1rsig1=SFi1r.data(SFi1rchan1,:); SFi1rsig1=reshape(SFi1rsig1',[],1);
        %SFi1rchan2=SFi1r.channels==2; SFi1rsig2=SFi1r.data(SFi1rchan2,:); SFi1rsig2=reshape(SFi1rsig2',[],1);
        %SFi1rchan3=SFi1r.channels==3; SFi1rsig3=SFi1r.data(SFi1rchan3,:); SFi1rsig3=reshape(SFi1rsig3',[],1);
    
    %Tick has something on channel 1 ... ?
        %Stickchan1=Stick.channels==1; Sticksig1=SFi1r.data(Stickchan1,:); Sticksig1=reshape(Sticksig1',[],1);
       
    % if for some reason 405 is a different size, 0-pad sig_405 
    % although more likely the sampling rates are different...so fix it
    %if length(sig_405)~length(sig_472)
    %    sig_405=padarray(sig_405,[length(sig_472)-length(sig_405),0],'post');
    %end
    
    % create time vector
    % time basis for 472 and 405
    dTfp472=1/S472.sampling_rate;
    timeFP472=[0:dTfp472:(length(sig_472)-1)*dTfp472];
    dTfp405=1/S405.sampling_rate;
    timeFP405=[0:dTfp405:(length(sig_405)-1)*dTfp405];

    % time basis for sync, if it exists
    if exist('sig_sync');
     dTsync=1/Ssync.sampling_rate;
     timeSync=[0:dTsync:(length(sig_sync)-1)*dTsync];
    else
    end
    %save('calibrationData','FPstart','FPend');

    rawfig=figure;
    plot(timeFP472/60,sig_472,'b');
    hold on
    plot(timeFP405/60,sig_405,'k');
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    fileIDtxt=strcat('file:',exptname);
    text(xlim(2)/5,ylim(1)+(ylim(2)-ylim(1))*.05,fileIDtxt);
    if exist('sig_sync');
        plot(timeSync/60,sig_sync,'r');
        legend('GCaMP','Control','sync');
    else
    legend('GCaMP','Control');    
    end
    savefigFN = strcat(filename,'raw'); savefigFNpng = strcat(filename,'raw','.png')
    savefig(rawfig,savefigFN);
    saveas(rawfig,savefigFNpng);
    
    savename = strcat(filename,'_100Hz');
    [sig_472_RS,timeFP_RS]=resample(sig_472,timeFP472,100,10,10);  %resample @ 100Hz, "10,10" to fix artifact at end of resample
    sig_405_RS=resample(sig_405,timeFP405,100,10,10);
    if exist('sig_sync') && length(sig_sync)~=0;  %may not have anythign sync'ed - don't save the resampled for now
        [sig_sync_RS,timeSync_RS]=resample(sig_sync,timeSync,20);
        save(savename,'sig_472_RS','sig_405_RS','timeFP_RS','sig_sync_RS','timeSync_RS','savename'); 
    elseif exist('camtime')
        save(savename,'sig_472_RS','sig_405_RS','timeFP_RS','camtime','savename');
    else
        save(savename,'sig_472_RS','sig_405_RS','timeFP_RS','savename'); 
    end

end


