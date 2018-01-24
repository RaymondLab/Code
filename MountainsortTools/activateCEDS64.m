%% This script actiates the CEDS64 library aka Spike2 MATLAB SON Interface 
%
% see http://ced.co.uk/upgrades/spike2matson for more information
% 
% Maxwell Gagnon

% add path to CED code
if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', 'C:\CEDMATLAB\CEDS64ML');
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);

CEDS64LoadLib( cedpath );