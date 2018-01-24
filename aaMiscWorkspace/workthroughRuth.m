%% open file and set up Environment 
activateCEDS64
file = 'Z:\1_Maxwell_Gagnon\RuthProjectData\2017_11_09\x0 light and dark at 0.6Hz FOM 1.smr';
fhand1 = CEDS64Open(file);

%% get the transition times between light and dark
[ iRead, vMObd] = CEDS64ReadMarkers(1, 9, 200, 0);

lightStart  = vMObd(1:2:end).m_Time;
darkEnd     = vMObd(1:2:end).m_Time;
lightEnd    = vMObd(2:2:end).m_Time;
darkStart   = vMObd(2:2:end).m_Time;
%consider time=0 to be the 'start' of the first dark segment
darkStart   = [0, darkStart];


%% Get the control / dummy channel data
[ iRead, ephysWave, i64Times ] = CEDS64ReadWaveF(1, 12, 600000000, 0);

% consider time=end to be the 'end' of the last dark segment
darkEnd = [darkEnd, length(ephysWave)];

light = 0;

% arbitrary start time
[ iRead, vMObd] = CEDS64ReadMarkers(1, 10, 200, 0);


AST = 55.36270;
cycleLength = 1.66666;
[ ASTinTicks ] = CEDS64SecsToTicks(1, AST);
[ cycleLengthInTicks ] = CEDS64SecsToTicks(1, cycleLength);

CycleStartTimes = ephysWave(ASTinTicks:2:end);

