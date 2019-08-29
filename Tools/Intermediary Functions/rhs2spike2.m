 %% rhs files in folder
clear;clc;close all
% CEDS64CloseAll();
% unloadlibrary ceds64int;
dbstop if error

% Desired Folder
folder = 'G:\My Drive\Expmt Data\MultiElectrode Data\In_vivo_Cerebellar_Vermis_Exp3and4';

% Find all rhs files
cd(folder)
seg_file_names = dir;
seg_file_names(~contains({seg_file_names.name}, '1_190129_150035.rhs')) = [];

%% OR rhs files in directory
clear;clc;close all
dbstop if error

% Desired Folder
%folder = 'C:\Users\maxwellg\Desktop\Intan_Recordings';
%folder = 'C:\Users\maxwellg\Desktop\290119-selected (2) - Copy';
folder = 'G:\My Drive\Expmt Data\MultiElectrode Data\In_vivo_Cerebellar_Vermis_Exp3and4';

% Find all rhs files
seg_file_names = dir([char(folder) '\**\*.rhs']);


%% Extract matrix and other relevant data
for i = 1:length(seg_file_names)
    
    % get data from .rhs file
    try
        clear amplifier_data
        read_Intan_RHS2000_file(seg_file_names(i).folder, seg_file_names(i).name);
    catch
        warning(['File Error: ', seg_file_names(i).name])
        continue
    end
    
    
    % Pre-allocate
    data_filt = ones(size(amplifier_data));
    
    
    % Create new smr file
    activateCEDS64
    spike2_fileName = strrep(seg_file_names(i).name, '.rhs', '_combFilt-60_bpFilt20-2000_Order-1_Scaled-1000.smr');
    %spike2_fileName = strrep(seg_file_names(i).name, '.rhs', '_Scaled1000.smr');
    %spike2_fileName = fullfile(seg_file_names(i).folder, spike2_fileName);
    fhand1 = CEDS64Create( spike2_fileName, 32, 1);
    [dsec] = CEDS64TimeBase(fhand1, .00003); % seconds per tick? 
    
    
    % Check if it worked
    if (fhand1 <= 0)
        fprintf(num2str(fhand1));
        CEDS64ErrorMessage(fhand1);
        unloadlibrary ceds64int;
        return;
    end  
    
    
    % Write all multi-electrode channels to smr (spike2) file
    for j = 1:size(amplifier_data, 1)
        
        
        % Bandpass Filter
        N = 1;
        freq = 30000;
        fc = [20 2000];
        [bb,aa] = butter(N, fc/(freq/2), 'bandpass');
        data_filt(j,:) = filtfilt(bb,aa,amplifier_data(j,:));
        
        
        % Comb Filter
        fo = 60;  
        q = 35; 
        bw = (fo/(freq/2))/q;
        [b,a] = iircomb(freq/fo,bw,'notch');
        data_filt(j,:) = filtfilt(b,a,data_filt(j,:));
        
        
        % Scale data 
        ScaleFactor = 1000;
        data_filt(j, :) = data_filt(j,:) / ScaleFactor;
        %amplifier_data(j, :) = amplifier_data(j,:) / ScaleFactor;
        
        
        % Get free channel
        free_chan = CEDS64GetFreeChan(fhand1);
        
        
        % Create Wave Channel
        CEDS64SetWaveChan(fhand1, free_chan, 1, 9, freq);
        
        
        % Seconds to Ticks conversion - I don't understand this part
        sTime = CEDS64SecsToTicks(fhand1, 1);
        
        
        % Write data to channel
        CEDS64WriteWave(fhand1, free_chan, data_filt(j, :), sTime);
        %CEDS64WriteWave(fhand1, free_chan, amplifier_data(j, :), sTime);
        
        
        % Set title of channel
        CEDS64ChanTitle(fhand1, free_chan, ['Chan ', num2str(j)]);
        
    end
    
    CEDS64CloseAll();
    unloadlibrary ceds64int;
    fprintf([seg_file_names(i).name, '...Complete!\n'])

end
fprintf('All Done! :)\n')
