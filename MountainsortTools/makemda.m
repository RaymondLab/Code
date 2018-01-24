function makemda( inputfile, channel)
%% makemda creates a new mda file with a specific channel data from an smr file
% .mda is the input file format that MountainSort uses
% For more informaiton on mda file formats and MountainSort see - 
% https://github.com/magland/mountainlab/blob/master/old/doc/mda_format.md
%
% INPUTS
%   inputfile       This should be the location of an .smr file (from spike2)
%   channel         This should be the channel of the data that you want to
%                   extract. Typically channel 8?
% 
% Maxwell Gagnon & Hannah Payne  10/2017

% add the path to the CED code
cedpath = getenv('CEDS64ML');         % if you have set this up (this is the recommended way)
addpath( cedpath );                   % so CEDS64LoadLib.m is found 
CEDS64LoadLib( cedpath );             % load ceds64int.dll 


fhand1 = CEDS64Open(inputfile);

% if your data does not read enough of the smr file, try increasing
% '70000000' to something higher
fprintf('\nReading channel data...')
[~, vfWave, ~] = CEDS64ReadWaveF( fhand1, channel, 200000000, 0); 
fprintf('\nSuccess!\n\nWriting mda file...')

outputfile = strrep(inputfile, '.smr', '.mda');
writemda(vfWave', outputfile, 'float32');
fprintf('\nSuccess!')
output = readmda(outputfile);

% compare the original waveform vector to the vector created in the 
% mda file; this makes sure that everything is copied over nicely
% A = 1; equal
% A = 0; NOT equal, something went wrong
fprintf('\nVarifying...')
if isequal(output, vfWave') 
    fprintf('\n\nVarified! \nEverything worked!\n')
else
    fprintf('\nOops! \nSomething went wrong\n')
end


end

