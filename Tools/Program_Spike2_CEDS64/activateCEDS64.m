function  activateCEDS64
% This script actiates the CEDS64 library aka Spike2 MATLAB SON Interface 
%
% see http://ced.co.uk/upgrades/spike2matson for more information
% Each computer MUST install this!
% 
% Maxwell Gagnon

if isempty(getenv('CEDS64ML'))
    setenv('CEDS64ML', 'C:\CEDMATLAB\CEDS64ML');
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);

CEDS64LoadLib( cedpath );

