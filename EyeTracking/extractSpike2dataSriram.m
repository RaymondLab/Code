
[data,dataSubset,keystrokes] = importDatObject(fullfilename);      %extracts raw data from .smr experimental file
SampKeys = strcat(keystrokes.samplerate(any(keystrokes.samplerate == ('V'), 2))');
SampKeyTimes = keystrokes.data(any(keystrokes.samplerate == ('V'), 2))';
% 
segmentStart = SampKeyTimes(strfind(SampKeys, 'V'));