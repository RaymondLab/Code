%% Set Up
clear;clc;close all
dbstop if error
%files = dir('C:\Users\maxwellg\OneDrive\04 Work\01 Stanford - LSRP\CF Project\Data\D1_1995\**\**');
%files = dir('C:\Users\maxwellg\OneDrive\04 Work\01 Stanford - LSRP\CF Project\Data\D1_1995\da0208');
%files = dir('C:\Users\maxwellg\Documents\CF_Project\Data\D2_1995\da0315');
%files = dir('C:\Users\maxwellg\Documents\CF_Project\Data\D2_1995\**\**');
files = dir('G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes\**\**');%Unit data files\Unit data files\2005');
%files = dir('G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes\Unit data files\Unit data files\2005');

% remove . and .. files
%files(~contains({files.name}, '.0')) = [];

% figure inital setup
q = figure('units','normalized','outerposition',[0 0 1 1]);
ha = tight_subplot(7,1,[.005 .005],[.015 .015],[.005 .005]);

do = 1;
%% Open File
for j = 1:length(files)

    clc
%     for qq = 1:30        
%         qq
%         RawRecording = readcxdata(fullfile(files(j).folder, files(j).name), 0, qq)
%         clc
%     end

    
    RawRecording = readcxdata(fullfile(files(j).folder, files(j).name), 0, 7)
    if isempty(RawRecording.data)
        continue
    end
    
    fullfile(files(j).folder, files(j).name)
    DatRecording = opensingleMAXEDIT(fullfile(files(j).folder, files(j).name), 0);
    clf(ha);
    t = linspace(DatRecording(1).tstart, DatRecording(1).tend, length(DatRecording(1).data));
   
    if do
        for i = 1:(length(DatRecording))

            % Plot
            plot(ha(i), t(1:length(DatRecording(i).data)), DatRecording(i).data)
            hold on
            hline(0, ':r')

            %title
            set(ha(i).Title, 'String', DatRecording(i).chanlabel)
            ha(i).Title.Units = 'normalized';
            ha(i).Title.Position = [.5 .9 0];

            % y axis
            ylabel(DatRecording(i).units)
            set(ha(i), 'TickDir', 'in')
            set(ha(i),'ytick',min(DatRecording(i).data):50:max(DatRecording(i).data))
            set(ha(i),'yticklabel',[])

            % x axis
            set(ha(i), 'xlim', [0, 1.005*max(t)])
            set(ha(i),'xtick',0:10:max(t))
            if i ~= (length(DatRecording))
                set(ha(i),'xticklabel',[])
            end
            
%             if i == 6
%                 figure(2)
%                 b = scatter(DatRecording(i).data, ones(length(DatRecording(i).data), 1), 'filled', 'SizeData', 10);
%                 hold on
%                 plot(t(1:length(DatRecording(1).data)), DatRecording(1).data)
%             end

            box(ha(i),'off')
        end
    end

end