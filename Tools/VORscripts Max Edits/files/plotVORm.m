%% plotVOR.m
% plots the results of a runVOR analysis
%
% plotVOR(results)  plots all the results
% plotVOR(results, 'vord') plots only the VORD trials
% plotVOR(results, mode, 1) normalizes the data to a gain of 1
%    Possible modes = 'cal', 'all', 'vord','drum','okr'
%

function h = plotVORm(results, varargin)

% Parse inputs
p = inputParser;

expectedModes = {'cal','all','vord','drum','okr','phase','bilat'};

addOptional(p,'mode','all',@(x) any(validatestring(x,expectedModes)))
addOptional(p,'norm',1,@isnumeric)

p.parse(varargin{:});

mode = p.Results.mode;
norm = p.Results.norm;

%% find the eye gain data
% gain = results.data(:,strcmpi('eyeHgain',results.header));
eyeamp = results.data(:,strcmpi('eyeHamp',results.header));
headamp = results.data(:,strcmpi('headamp',results.header));
% gain2 = eyeamp./headamp;
t = results.data(:,1);

% Identify VORD trials
VORDmask = ~cellfun(@isempty,regexp(results.labels,'VORD'));

switch norm
    case 0  % Plot eye amplitude
        gain = eyeamp;
        ylims = [0 max(gain(VORDmask))*1.1];
        ylabels ='Eye amplitude (deg/s)';
    case 1  % Plot eye gain
        gain = eyeamp./headamp;
        ylims = [0 2*max(gain)];
        ylabels = 'VOR gain';
    case 2  % Plot normalized gain
        gain = eyeamp/mean(eyeamp(t(:)==0&VORDmask(:)));
        ylims = [0 2];
        ylabels = 'VOR learning (normalized)';
end

phase = results.data(:,strcmpi('eyeHphase',results.header));

switch mode
    
    case 'all'
        clf
        
        conds = {'VORD','STIM','BILAT'};
        colors = {'k','g','m'};
        scatter(t,gain,40,'k'); hold on;
        plot(t(VORDmask),gain(VORDmask),'-k');
        ylims(2) = max(gain)*1.1; if isnan(ylims(2)); ylims = [0 1]; end
        hold on;
        for i = 1:length(conds)       
            mask = ~cellfun(@isempty,regexp(results.labels,conds{i}));
            tMask = t(mask);
            gainMask = gain(mask);
            h(i) = scatter(tMask,gainMask,80,colors{i},'fill');            
        end
        hold on; plot([0 35],[mean(gain(VORDmask & t==0)) mean(gain(VORDmask & t==0))],'-.k')           
        xlabel('Time (min)')
        legend(h,conds,'EdgeColor','w')
        
    case 'vord'
        mask = VORDmask(:) & t(:)>=0;
        t = t(mask);
        gain = gain(mask);
        h=plot(t(t<=30),gain(t<=30),'ok-','MarkerFaceColor','k');
        if any(t>30)
            hold on
            h2 = plot(t(t>30),gain(t>30),'ok-');
            h = [h,h2];
        end
        hold on; plot([0 35],[mean(gain(t==0)) mean(gain(t==0))],'-.k')
        xlabel('Time (min)')
        
    case 'phase'
        t = results.data(:,1);
        mask = regexp(results.labels,'VORD');
        mask = ~cellfun(@isempty,mask);
        mask = mask & t>=0;
        
        t = t(mask);
        
        phase = phase(mask);
        
        h = plot(t(t<=30),phase(t<=30),'ok-');
        
        if any(t>30)
            hold on
            h2 = plot(t(t>30),phase(t>30),'ok-');
            h = [h,h2];
        end
        hold on;
        xlabel('Time (min)')
        ylabels = 'VOR phase';
        
    case 'okr'
        maskOKR = ~cellfun(@isempty,regexp(results.labels,'OKR'));
        h=plot(1:sum(maskOKR), gain(maskOKR),'+k-');
        set(gca,'XTick',1:sum(maskOKR))
        set(gca,'XTickLabel',{results.labels{maskOKR}})
        
    case 'bilat'
        maskBilat = ~cellfun(@isempty,regexp(results.labels,'BILAT'));
        tplot = t(maskBilat);
        plot(tplot,gain(maskBilat),'o-k','MarkerFaceColor','k')
        set(gca,'XTick',tplot,'XTickLabel',{'Before','After'})
        title('VORD with bilateral PC suppression')
%         xlim([-5 35])
        
end
ylabel(ylabels)
ylim(ylims)


box off



