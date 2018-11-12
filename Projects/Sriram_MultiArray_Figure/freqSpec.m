function freqSpec(data, samplerate)
% Plot the requency spectrum of all channels in a signal --> default 32
% channels

plotSize = [8,4];
ha = tight_subplot(plotSize(1),plotSize(2),[.005 .005],[.005 .005],[.005 .005]);

for i = 1:size(data,1)
    sig = data(i,:);
    
    % Calculate 
    L = length(sig);
    Y = fft(sig);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = samplerate*(0:(L/2))/L;
    
    % plot
    axes(ha(i))
    plot(f,P1) 
    
    % cosmetics
    ylim([0 5])
    xlim([0 3500])
    vline(3183.5)
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
end