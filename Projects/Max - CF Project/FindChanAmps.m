%% Set up
clear;clc;
% open Excel File
excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
%excelFile = 'C:\Users\Public\RaymondLabCode\Projects\Max - CF Project\Monkey Metadata by Max (Akira).xlsx';
expmt_table = readtable(excelFile);

ExpmtDataFolder = 'D:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
%ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Akira and Sriram Complex Spikes';

%bFiles = dir([ExpmtDataFolder '\**\*.0*']);
bFiles = dir([ExpmtDataFolder '\**\*']);


%% Only Sine Waves
SineExpmts = expmt_table(contains(expmt_table.SineStep, {'Sine'}), :);
figure(1);
ha = tight_subplot(2,1,[.03 .03],[.03 .03],[.03 .03]);
for i = 1:height(SineExpmts)
    
    bPath = fullfile(bFiles(find(contains({bFiles.name}, SineExpmts.Filename(i)))).folder, ...
        bFiles(find(contains({bFiles.name}, SineExpmts.Filename(i)))).name);
    
    ePath = fullfile(bFiles(find(contains({bFiles.name}, SineExpmts.EphysFilename(i)))).folder, ...
        bFiles(find(contains({bFiles.name}, SineExpmts.EphysFilename(i)))).name);
    try
        
        [beh shiftAmt, shiftConfidence] = opensingleMAXEDIT(bPath, 0, ePath);
    catch
    end
    
    %% PLOT each channel
    OverviewPlot = 1;
    if OverviewPlot
        
        for q = 4:5

            axes(ha(q-3))

            if isempty(beh(q).data)
                title([beh(q).chanlabel, ' is empty'])
                continue
            end

                    
                    

                
            samplerate = beh(q).samplerate;
            timeVec = 0:( 1/samplerate ):( length(beh(q).data)-1 )/samplerate;
            timeVec2 = (1:length(beh(q).data))/samplerate;
            freq = SineExpmts.Freq_Duration(i);
            
            y1 = sin(2*pi*freq*timeVec2)';
            y2 = cos(2*pi*freq*timeVec2)';
            constant = ones(length(beh(q).data),1);
            vars = [y1 y2 constant];
            [b,~,~,~,stat] = regress(beh(q).data, vars);
            Amp(i) = sqrt(b(1)^2+b(2)^2);
            Phase = rad2deg(atan2(b(2), b(1)));

            % Plot
            %plot(timeVec, beh(q).data); hold on
            %title(beh(q).chanlabel)
            
            switch q
                case 1 % Horz Gaze Vel
                    ylim([-600 600])
                case 2
                case 3 % Horz Eye Pos
                    ylim([-600 600])
                case 4 % Horz Target Pos
                    ylim([-600 600])
                case 5 % Horz Head Vel
                    ylim([-600 600])
                case 6 % Horz D Vel
                    ylim([-600 600])
                case 7 % Horz Target Vel
                    ylim([-2000 2000])
                case 8
                    
            end
            % Only show Tick labels on bottom (Epyhs Channel)
            if q ~= length(ha)-1
                xticks([]);
            end
        end
        linkaxes(ha, 'x')
    end
end
