function dfof=debleachBDH(time,sig,wavelen,savename,debleach_flag,numExp,startfit,endfit,baseline_method,manualbase)%,numExp startfit,endfit,baseline_method)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    exptname=strsplit(savename,'\'); exptname=exptname{1};
    
    %numExp = 0  %0 = cubic poly fit, 1=single exp fit,  2=dbl exp fit
    %startfit = 20%*6000%10*6000 % single exp fit, x val to start fitting
    %endfit = 2*6000 % single exp fit, x val to end fit
    %endfit = length(sig)
    %baseline_method=1   % 1=main peak of histogram for dataset 
                        % 2=median val
                        % 3=manually assigned baseline
    %manualbase=95
      
    
    if debleach_flag==1
        % subtract the final value of the recording to have it decay to zero
        % option 1% offset=sig(end-10); %resampling messes with the ends 
        % option 2 for offset, avoids creating -ive pts
        sig(1:50)=sig(51); %removes artifact of resampling in first 0.5sec
        offset=min(sig(100:endfit));  %%changed this from end to endfit
        base=sig-offset;
       
        % fit a single or double exponential and debleach. exclude the first 500 points
        %exp_fit=fit(time(500:end)',base(500:end),'exp1');  
        
        
        if numExp==0;
            lin_fit=fit(time(startfit:endfit)',base(startfit:endfit),'poly3');
            y_fit=lin_fit.p1*time.^3 + lin_fit.p2*time.^2 + lin_fit.p3*time + lin_fit.p4;
        
        elseif numExp==1;
            %%%%%%%%%%%%%%%% single exp
            %exp_fit=fit(time',base,'exp1');
            %%%%%%%%%%%% if experiment alters apparent decay rate
            exp_fit=fit(time(startfit:endfit)',base(startfit:endfit),'exp1');
            y_fit=exp_fit.a*exp(exp_fit.b*time);
    
        elseif numExp==2;
            %%%%%%%%%%%%%%%% double exp
            exp_fit=fit(time(startfit:endfit)',base(startfit:endfit),'exp2');   
            y_fit=exp_fit.a*exp(exp_fit.b*time)+exp_fit.c*exp(exp_fit.d*time);
            
        end
        
        debleach=sig-y_fit';
       
        % plot debleaching results
        debleachFig = figure;
        plot(time/60,sig);
        hold on
        plot(time/60,y_fit+offset,'r');
        plot(time/60,debleach,'g');
        title(strcat('Debleaching results for ',wavelen,' channel'));
        legend('Signal','Exp Fit','Debleached');
        xlabel('Time');
        ylabel('Fluorescence'); ylim=get(gca,'ylim');xlim=get(gca,'xlim');
        fittext=strcat('fit ', num2str(numExp),' exponentials, start @ ',num2str(startfit/6000),'m, end @ ',num2str(endfit/6000),'m');
        text(xlim(2)/3,ylim(1)+(ylim(2)-ylim(1))*.05,fittext);
  
        savefigDB = strcat(exptname,'\',exptname,'deBleach',wavelen); 
        savefigDBpng = strcat(exptname,'\',exptname,'deBleach',wavelen,'.png')
        savefig(debleachFig,savefigDB);
        saveas(debleachFig,savefigDBpng);
    else
        debleach=sig; 
        base=sig;
        y_fit=sig-sig;
        display('No debleaching required');
    end

    % calculate dF/F of signal, either histo (baseline_method=1) 
    % or sorting values (baseline_method~=1)
        dfof=zeros(1,length(debleach));
        
        % suitable for 405 or sig w v few transients
        if baseline_method==1;
            [h,x]=histcounts(debleach,100);
            x=x(1:100) + x(2:101); x=x/2;
            [hgt,xpos]=max(h);
            baseline=x(xpos)
        elseif baseline_method==2;
            sig_sort=sort(debleach);
            baseline=median(sig_sort);
        else
            baseline=manualbase
        end

    for a=1:length(debleach)
        dfof(a)=(debleach(a)-baseline)/baseline;
    end
    
    dFFfig=figure;plot(time/60,dfof);
    title(strcat('dF/F for ',wavelen,' channel'));
    savefigDFF = strcat(exptname,'\',exptname,'dFoF',wavelen); 
    savefigDFFpng = strcat(exptname,'\',exptname,'dFoF',wavelen,'.png')
    savefig(dFFfig,savefigDFF);
    saveas(dFFfig,savefigDFFpng);
    
    
    savenameDB=strcat(savename,wavelen,'.mat');
    save(savenameDB,'time','sig','base','y_fit','dfof', 'debleach');
    
    display('Completed dfof calculation');
end