classdef chanData
    properties
        excelFile = [];
        expmt_table = [];
        whoseData = [];
        expmtDataFolder = [];
        bFiles = [];
        
    end
    
    methods
        function [self, bPath, expmtRow] = findBehavior(self, name, folder)
            expmtRow = find(strcmp(self.expmt_table.Filename, name));
            bPath = fullfile(folder, name);
            
            % Create new row for new file
            if isempty(expmtRow)
                TempRow = self.expmt_table(find(contains(self.expmt_table.Filename, 'PlaceHolder')), :);
                TempRow.Filename = name;
                self.expmt_table = [self.expmt_table; TempRow];
                expmtRow = find(contains(self.expmt_table.Filename, name));
                disp(name)
            elseif length(expmtRow) > 1
                warning('Possible Duplicate entry')
            end
            
        end
        
        function [self, ephys_exists, ePath] = findEphys(self, bFileName, bFileRow)
            
            if strcmp(self.whoseData, 'Akira')
                eFile = strrep(bFileName, 'unit', 'U');
            elseif strcmp(self.whoseData, 'Jennifer')
                eFile = strrep(bFileName, 'da', 'du');
            else
            end
            
            eFile = strrep(eFile, '.0', '.');

            ephys_loc = find(contains({self.bFiles.name}, eFile));
            
            if any(ephys_loc > 0)
                ephys_exists = 1;
                ePath = fullfile(self.bFiles(ephys_loc).folder, self.bFiles(ephys_loc).name);
                self.expmt_table.EphysFilename{bFileRow} = eFile;
                disp(['     -', eFile])
            else
                ephys_exists = 0;
                ePath = [];
                self.expmt_table.EphysFilename{bFileRow} = 'None';
                self.expmt_table.EphysAlignmentValue(bFileRow) = 0;
                disp('     -No Ephys')
            end
        end
        
        function [self, peakFreqEstimate] = findExpmtFreq(self, datObj, expmtRow)
            maxFreqLoc = [0,0,0,0,0; 0,0,0,0,0];
            for i = 1:8
                
                if length(datObj(i).data) < 1
                    continue
                end
                
                L = length(datObj(i).data);
                Y = fft(datObj(i).data);
                P2 = abs(Y/L);
                P1 = P2(1:floor(L/2+1));
                P1(2:end-1) = 2*P1(2:end-1);
                f = datObj(i).samplerate*(0:(L/2))/L;
                
                if sum(P1 == max(P1)) == 1
                    maxFreqLoc(1, i) = f(P1 == max(P1));
                    maxFreqLoc(2, i) = max(P1);
                end
            end
            
            if strcmp(self.expmt_table.SineStep{expmtRow}, {'Sine'})
                peakFreqEstimate = maxFreqLoc(1,maxFreqLoc(2,:) == max(maxFreqLoc(2,:)));
                peakFreqEstimate = round(peakFreqEstimate * 2)/2;
                self.expmt_table.Freq_Duration(expmtRow) = peakFreqEstimate;
                disp(['     -Freq Est: ', num2str(peakFreqEstimate)]);
            else
                peakFreqEstimate = NaN;
                self.expmt_table.Freq_Duration(expmtRow) = NaN;
                disp(['     -Freq Est: ', 'NaN']);
                
            end
        end
        
        function plotAllChans(~, datObj)
            figure(1); clf
            ha = tight_subplot(9,1,[.03 .03],[.03 .03],[.03 .03]);
            for i = 1:8
                
                axes(ha(i));
                
                if isempty(datObj(i).data)
                    title([datObj(i).chanlabel, ' is empty'])
                    continue
                end
                
                samplerate = datObj(i).samplerate;
                timeVec = 0:( 1/samplerate ):( length(datObj(i).data)-1 )/samplerate;
                plot(timeVec, datObj(i).data);
                
                switch i
                    case 1 % h gaze vel
                    case 2 % v eye pos
                    case 3 % h eye pos
                    case 4 % h Target Pos
                    case 5 % h Head vel
                    case 6 % h d Vel (eye2)
                    case 7 % h Target Vel
                    case 8 % ephys?
                end
                
                title(datObj(i).chanlabel)
                % Only show Tick labels on bottom (Epyhs Channel)
                if i ~= length(ha)-1
                    xticks([]);
                end
            end
        end
                
        function plotPowerSpec(~, datObj)
            figure(99);clf
            za = tight_subplot(9,1,[.03 .03],[.03 .03],[.03 .03]);
            for i = 1:7
                
                L = length(datObj(i).data);
                Y = fft(datObj(i).data);
                P2 = abs(Y/L);
                P1 = P2(1:floor(L/2+1));
                P1(2:end-1) = 2*P1(2:end-1);
                f = datObj(i).samplerate*(0:(L/2))/L;
                
                axes(za(i))
                plot(f, P1, 'k')
                
                % Cosmetics
                xlim([0 11])
                if sum(P1 == max(P1)) == 1
                    vline(f(P1 == max(P1)))
                    title([datObj(i).chanlabel, ':   ', num2str(f(P1 == max(P1)))])
                end
            end
        end
        
        function self = findStimType(self, expmtRow)
            % Sine or Step?
            if contains(self.expmt_table.SineStep{expmtRow}, 'Not Measured')
                
                % Input for Sine/Step Information
                answer = questdlg('Sine or Step?', ...
                    'Dessert Menu', ...
                    'Sine','Step','Unknown', 'Unknown');
                
                % Save Sine/Step information
                if contains(answer, 'Sine')
                    self.expmt_table.SineStep{expmtRow} = 'Sine';
                elseif contains(answer, 'Step')
                    self.expmt_table.SineStep{expmtRow} = 'Step';
                elseif contains(answer, 'Unknown')
                    self.expmt_table.SineStep{expmtRow} = 'Unknown';
                end
            end
            disp(['     -', self.expmt_table.SineStep{expmtRow}]);
            
%             % What kind of Sine? 
%             if contains(self.expmt_table.SineStep{expmtRow}, 'Sine')
%                 % Input for Sine/Step Information
%                 answer = questdlg('Expmt Type?', ...
%                     'Dessert Menu', ...
%                     'OKR','VORD', 'Unknown', 'Unknown');
%                 if contains(answer, 'Unknown')
%                     answer = questdlg('Exmpt Type?', ...
%                         'Dessert Menu', ...
%                         'x0', 'x2', 'Unknown', 'Unknown');
%                 end
%                 
%                 % Save StimType information
%                 self.expmt_table.StimType(expmtRow) = answer;
%                 disp(['     -Stim Type: ', answer]);
%             end
            

        end
        
        function self = findAmpPhase(self, datObj, peakFreqEstimate, expmtRow)
            
            % Make sure you have a peakFreqEstimate value
            if isnan(peakFreqEstimate)
                return
            end
            
            % Generate Fit
            for i = 1:8
                if isempty(datObj(i).data)
                    continue
                end
                
                segLength = length(datObj(i).data);
                segTime = (1:segLength)/datObj(i).samplerate;
                freq = peakFreqEstimate;
                y1 = sin(2*pi*freq*segTime(:));
                y2 = cos(2*pi*freq*segTime(:));
                constant = ones(segLength,1);
                vars = [y1 y2 constant];
                
                b = regress(datObj(i).data, vars);
                amp = sqrt(b(1)^2+b(2)^2);
                phase = rad2deg(atan2(b(2), b(1)));
                
                switch datObj(i).chanlabel
                    case 'Horz Target Vel'
                        self.expmt_table.rawTargetVelAmp(expmtRow) = amp;
                        self.expmt_table.rawTargetVelPhase(expmtRow) = phase;
                        disp(['     -Target Amp: ',  num2str(amp)]);
                    case 'Horz Head Vel'
                        self.expmt_table.rawHeadVelAmp(expmtRow) = amp;
                        self.expmt_table.rawHeadVelPhase(expmtRow) = phase;
                        disp(['     -Head Amp: ',  num2str(amp)]);
                    case 'Horz Gaze Vel'
                        self.expmt_table.rawGazeVelAmp(expmtRow) = amp;
                        self.expmt_table.rawGazeVelPhase(expmtRow) = phase;
                        disp(['     -Gaze Amp: ', num2str(amp)]);
                end
            end
        end
        
        function self = findCSInfo(self, datObj, expmtRow)
            if isempty(datObj(contains({datObj.chanlabel}, 'cs')).data)
                self.expmt_table.CSPresent(expmtRow) = 0;
                self.expmt_table.CSSorted(expmtRow) = 0;
            end
        end
        
        function self = findEphysAllignment(self, datObj, expmtRow, shiftConfidence)
            % Add Alignment Value
            ephys_shift = datObj(contains({datObj.chanlabel}, 'Ephys')).tstart;
            if ~(self.expmt_table.EphysAlignmentValue(expmtRow) == ephys_shift) && (shiftConfidence > 30)
                self.expmt_table.EphysAlignmentValue(expmtRow) = ephys_shift;
                disp(['     -Ephys Shift: ', num2str(ephys_shift)]);
            else
                self.expmt_table.EphysAlignmentValue(expmtRow) = NaN;
                disp('     -Ephys Shift: NaN');
            end
        end
        
        function plot2(~, datObj)
            figure(98);clf
            pa = tight_subplot(2,1,[.03 .03],[.03 .03],[.03 .03]);
            
            axes(pa(1))
            % Head Vel
            samplerate = datObj(5).samplerate;
            timeVec = 0:( 1/samplerate ):( length(datObj(5).data)-1 )/samplerate;
            plot(timeVec, datObj(5).data, 'b'); hold on
            
            % Target Vel
            samplerate = datObj(7).samplerate;
            timeVec = 0:( 1/samplerate ):( length(datObj(7).data)-1 )/samplerate;
            plot(timeVec, datObj(7).data, 'r');
            
            % Gaze Vel
            samplerate = datObj(1).samplerate;
            timeVec = 0:( 1/samplerate ):( length(datObj(1).data)-1 )/samplerate;
            plot(timeVec, datObj(1).data, 'k');
            
            
            ylim([-50 50])
            xlim([0 30])
            title('Vel')
            
            axes(pa(2))
            % target Pos
            samplerate = datObj(4).samplerate;
            timeVec = 0:( 1/samplerate ):( length(datObj(4).data)-1 )/samplerate;
            plot(timeVec, datObj(4).data, 'r'); hold on
            
            % eye Pos
            samplerate = datObj(3).samplerate;
            timeVec = 0:( 1/samplerate ):( length(datObj(3).data)-1 )/samplerate;
            plot(timeVec, datObj(3).data, 'k'); hold on
            ylim([-30 30])
            xlim([0 30])
            title('Pos')
            
            
            
            
        end
        
    end
end
