%% batchBuildMDA creates a new mda file with a specific channel data from an smr file

% .mda is the input file format that MountainSort uses

% For more informaiton on mda file formats and MountainSort see -
% https://github.com/magland/mountainlab/blob/master/old/doc/mda_format.md

% Maxwell Gagnon 10/2017

activateCEDS64
channel = 8;

filenames = [
	% FILE NAMES GO HERE
    ];

%fileList = csvread(char(filenames(i))s);
worked = zeros(length(filenames),1);

for i = 1:length(filenames)
    
    fhand1 = CEDS64Open(char(filenames(i)));
    if fhand1 < 0;
        fprintf('\n%s\n NOT FOUND\n\n', filenames(i))
        fprintf('Error # (%d)', fhand1)
        worked(i,1) = -1;
        continue
    else
        fprintf('\n%s\nFOUND\n', filenames(i))
        worked(i,1) = 1;
    end
    
    % if your data does not read enough of the smr file, try increasing
    % the third input to CEDS64ReadWaveF to something higher
    fprintf('Reading channel data...\n')
    [~, vfWave, ~] = CEDS64ReadWaveF( fhand1, channel, 200000000, 0);
    fprintf('Writing mda file...\n')
    
    outputfile = strrep(char(filenames(i)), '.smr', '.mda');
    outputfile = strrep(outputfile, '.smrFiles', '.mdaFiles');
    writemda(vfWave', outputfile, 'float32');
    output = readmda(outputfile);
    
    % compare the original waveform vector to the vector created in the
    % mda file; this makes sure that everything is copied over nicely
    % A = 1; equal
    % A = 0; NOT equal, something went wrong
    fprintf('Varifying...\n')
    if isequal(output, vfWave')
        fprintf('Everything worked!\n')
    else
        fprintf('\nOops! \nSomething went wrong\n')
    end
end

worked