function rhs2spike2(files,clean)

  % Use raw data by default
  if ~exist('clean','var')
      clean = 0;
  end

  %% Extract matrix and other relevant data
  for i = 1:length(files(i))

      % get data from .rhs file
      try
          clear amplifier_data
          read_Intan_RHS2000_file(files(i));
      catch
          warning(['File Error: ', files(i)])
          continue
      end

      % Pre-allocate
      data_filt = ones(size(amplifier_data));

      % Create new smr file
      activateCEDS64
      spike2_fileName = strrep(files(i), '.rhs', '.smr');
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

          if clean
            % Bandpass Filter
            N = 1;
            freq = 30000;
            fc = [20 2000];
            [bb,aa] = butter(N, fc/(freq/2), 'bandpass');
            amplifier_data(j,:) = filtfilt(bb,aa,amplifier_data(j,:));

            % Comb Filter
            fo = 60;
            q = 35;
            bw = (fo/(freq/2))/q;
            [b,a] = iircomb(freq/fo,bw,'notch');
            amplifier_data(j,:) = filtfilt(b,a,amplifier_data(j,:));
          end

          % Scale data
          ScaleFactor = 1000;
          amplifier_data(j, :) = amplifier_data(j,:) / ScaleFactor;

          % Get free channel
          free_chan = CEDS64GetFreeChan(fhand1);

          % Create Wave Channel
          CEDS64SetWaveChan(fhand1, free_chan, 1, 9, freq);

          % Seconds to Ticks conversion - I don't understand this part
          sTime = CEDS64SecsToTicks(fhand1, 1);

          % Write data to channel
          CEDS64WriteWave(fhand1, free_chan, amplifier_data(j, :), sTime);

          % Set title of channel
          CEDS64ChanTitle(fhand1, free_chan, ['Chan ', num2str(j)]);

      end

      CEDS64CloseAll();
      unloadlibrary ceds64int;
      fprintf([files(i), '...Complete!\n'])

  end
  fprintf('All Done! :)\n')
