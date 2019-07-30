%% Set up

% open Excel File
excelFile = 'C:\Users\maxwellg\Documents\RL_Code\Projects\Max - CF Project\Monkey Metadata by Max.xlsx';
expmt_table = readtable(excelFile);

% Filters
%expmt_table(~strcmp(expmt_table.SineStep, {'Sine'}),:) = [];

ExpmtDataFolder = 'G:\My Drive\Expmt Data\2019_05 - Max Climbing Fiber\Initial Data for testing';
bFiles = dir([ExpmtDataFolder '\**\*.0*']);

% Filters
%bFiles(contains({bFiles.name}, {'301'})) = [];


%% Match the corresponding ephys folders with their motor folders
for j = 1:length(bFiles)

    % If the file is an ephys or oddly named file, skip it
    if length(bFiles(j).name) ~= 11
        continue
    end
        
    %% Add new line if new entry
    expmt_row = find(strcmp(expmt_table.Filename, bFiles(j).name));
    
    % Filters
    %if ~strcmp(expmt_table.SineStep(expmt_row), {'Sine'})
    %    continue
    %end
    
    if isempty(expmt_row)
        TempRow = expmt_table(find(contains(expmt_table.Filename, 'PlaceHolder')), :);
        TempRow.Filename = bFiles(j).name;
        expmt_table = [expmt_table; TempRow];
        expmt_row = find(contains(expmt_table.Filename, bFiles(j).name));
        disp(bFiles(j).name)
    end
    
    %% Does this experiment have a matching Ephys file?
    ephys_exists = 1;
    ePath = [];
    if contains(bFiles(j).name, '.0')
        eFile = strrep(bFiles(j).name, 'da', 'du');
        eFile = strrep(eFile, '.0', '.');
        ephys_loc = find(contains({bFiles.name}, eFile));
        if ephys_loc > 0
            ephys_exists = 1;
            ePath = fullfile(bFiles(ephys_loc).folder, bFiles(ephys_loc).name);
        end
    end
    
    % Open file
    try
        bPath = fullfile(bFiles(j).folder, bFiles(j).name)
        [beh shiftAmt, shiftConfidence] = opensingleMAXEDIT(bPath, ephys_exists, ePath);
    catch
        warning(fullfile(bFiles(j).folder, bFiles(j).name))
        continue
    end

    %% PLOT each channel
    OverviewPlot = 1;
    if OverviewPlot
        figure(1); clf
        ha = tight_subplot(5,1,[.03 .03],[.03 .03],[.03 .03]);
        for q = 4:8

            axes(ha(q-3))

            if isempty(beh(q).data)
                title([beh(q).chanlabel, ' is empty'])
                continue
            end

            samplerate = beh(q).samplerate;
            timeVec = 0:( 1/samplerate ):( length(beh(q).data)-1 )/samplerate;

            % Plot
            plot(timeVec, beh(q).data)
            title(beh(q).chanlabel)

            % Only show Tick labels on bottom (Epyhs Channel)
            if q ~= length(ha)-1
                xticks([]);
            end
        end
        linkaxes(ha, 'x')
    end
    
    %% PLOT the power Spectrum of each channel
    freqPlot = 0;
    if freqPlot
        maxFreqLoc = [0,0,0,0,0; 0,0,0,0,0];
        figure(85); clf
        za = tight_subplot(5,1,[.03 .03],[.03 .03],[.03 .03]);
        for w = 4:8
            if length(beh(w).data) < 1
                continue
            end
            axes(za(w-3))
            L = length(beh(w).data);
            Y = fft(beh(w).data);
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2+1));
            P1(2:end-1) = 2*P1(2:end-1);
            f = beh(w).samplerate*(0:(L/2))/L;
            plot(f,P1, 'k')
            
            % Cosmetics
            xlim([0 11])
            vline(f(P1 == max(P1)))
            title([beh(w).chanlabel, ':   ', num2str(f(P1 == max(P1)))])
            maxFreqLoc(1, w-3) = f(P1 == max(P1));
            maxFreqLoc(2, w-3) = max(P1);
        end
    end
    
    %% GATHER and STORE Sine/Step
    if contains(expmt_table.SineStep{expmt_row}, 'Not Measured')
        
        % Input for Sine/Step Information
        answer = questdlg('Sine or Step?', ...
            'Dessert Menu', ...
            'Sine','Step','Unknown', 'Unknown');
        
        % Save Sine/Step information
        if contains(answer, 'Sine')
            expmt_table.SineStep{expmt_row} = 'Sine';
        elseif contains(answer, 'Step')
            expmt_table.SineStep{expmt_row} = 'Step';
        elseif contains(answer, 'Unknown')
            expmt_table.SineStep{expmt_row} = 'Unknown';
        end
    end
  
    %% GATHER and STORE Sine freq information
    if freqPlot && strcmp(expmt_table.SineStep{expmt_row}, {'Sine'})
        peakFreqEstimate = maxFreqLoc(1,maxFreqLoc(2,:) == max(maxFreqLoc(2,:)));
        peakFreqEstimate = round(peakFreqEstimate * 2)/2
        expmt_table.Freq_Duration(expmt_row) = peakFreqEstimate;
    end
    
    %% ephys information
    if ephys_exists
        
        % Add Ephys File Name
        if ~contains(expmt_table.EphysFilename{expmt_row}, eFile)
            expmt_table.EphysFilename{expmt_row} = eFile;
        end
        
        % Add Alignment Value
        ephys_shift = beh(contains({beh.chanlabel}, 'Ephys')).tstart;
        if ~(expmt_table.EphysAlignmentValue(expmt_row) == ephys_shift) && (shiftConfidence > 30)
            ephys_shift
            expmt_table.EphysAlignmentValue(expmt_row) = ephys_shift;
        else
            expmt_table.EphysAlignmentValue(expmt_row) = NaN;
        end
        
    % No ephys information
    else
        expmt_table.EphysFilename{expmt_row} = 'None';
        expmt_table.EphysAlignmentValue(expmt_row) = 0; 
    end

    %% GATHER and STORE CS Information
    if isempty(beh(contains({beh.chanlabel}, 'cs')).data)
        expmt_table.CSPresent(expmt_row) = 0;
        expmt_table.CSSorted(expmt_row) = 0;
    end
    
    fclose('all');
end

writetable(expmt_table, excelFile);