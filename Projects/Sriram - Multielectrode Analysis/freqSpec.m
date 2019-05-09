function freqSpec(data, samplerate)
% Plot the requency spectrum of all channels in a signal --> default 32
% channels

plotSize = [8,4];

fs = figure();
%fs.Visible = 'off';
ka = tight_subplot(plotSize(1),plotSize(2),[0 0],[0 0],[0 0]);

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
    plot(ka(i),f,P1,'Color',[0 0.4470 0.7410]) 
    
    % cosmetics
    ka(i);
    vline(3183.5)
    hold on
    
    set(ka(i),'xtick',[0:50:2000])
    set(ka(i), 'TickDir', 'in')
    box(ka(i),'off')    
    set(ka(i),'xticklabel',[])
    
    set(ka(i),'ytick',[])
    set(ka(i),'yticklabel',[])
    box(ka(i), 'off')
    
end
linkaxes(ka)
ylim([0 50])
xlim([0 3500])
fs.Visible = 'on';