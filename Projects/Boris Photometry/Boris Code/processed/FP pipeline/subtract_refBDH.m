function sig=subtract_refBDH(time,sig,sig_control,savename,subtract_method)
    
    exptname=strsplit(savename,'\'); exptname=exptname{1};

    %subtract_method=2
    % subraction of sig & control
    % subtract_method='MinResid'  use bestfit model
    % subtract_method='Subtract' just subtract them
    % subtract_method='None' no correction with 405
    % subtract_method= number, manually offset by this value
   
    sig_control=smooth(sig_control,20);
    bestfit = fminsearch(@(x) leastsquareserror_scale(x,sig_control,sig'),1);
    
    corrFig = figure;
    plot(time/60,sig)
    hold on
    
        
    % subtract best fit motion signal
    if strcmp(subtract_method,'MinResid');%subtract_method=='MinResid';
        sig=sig-(sig_control'*bestfit);
        plot(time/60,sig_control'*bestfit,'r');
        savetag = 'dFoFsubMinRes';
    elseif strcmp(subtract_method,'Subtract');%subtract_method=='Subtract';
        sig=sig-sig_control';
        %sig(30000:length(sig))=sig(30000:length(sig) - sig_control(30000:length(sig)'));
        plot(time/60,sig_control','r');
        savetag = 'dFoFsubArith';
    elseif strcmp(subtract_method,'None');%subtract_method=='None';
        sig=sig;
        savetag = 'dFoFsubNone';
    elseif isnumeric(subtract_method);%add this number
        sig=sig+subtract_method;
        savetag = 'dFoF_offset';
    end
    
    % plot signal
    plot(time/60,sig,'k');
    xlabel('Time');
    ylabel('dF/F');
    
    if subtract_method==1;
        title('Least-squares scaling results');
    elseif subtract_method==2;
        title('Simple subtraction results');
    end
    
    legend('Original sig','scaled control','Subtracted sig');
    hold off
    
    savefigDFFcorr = strcat(exptname,'\',exptname,savetag); 
    savefigDFFcorrpng = strcat(exptname,'\',exptname,savetag,'.png')
    savefig(corrFig,savefigDFFcorr);
    saveas(corrFig,savefigDFFcorrpng);

    function f = leastsquareserror_scale(x,series1,series2)
        f = sum((series2-(x.*series1)).^2);
    end

end