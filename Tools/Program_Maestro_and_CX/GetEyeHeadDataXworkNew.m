function EyeHeadData = GetEyeHeadDataXworkNew

clear


XWORK = uigetfile('*.00**','Enter file');
data = readcxdata(XWORK, 0, 7);

MaestroConvEPos = 0.025;
MaestroConvEVel = 0.0919;
MaestroConvHVel = 0.1057;

Epos = MaestroConvEPos*data.data(1, :);
Evel = MaestroConvEVel*data.data(2, :); %hevel, just to compare with Eye_velocity obtained by VOREyeHeadDataFitAK
Hvel = MaestroConvHVel*data.data(4, :);


EyeHeadData.lh = [];

EyeHeadData.headvel = [];
EyeHeadData.eyevel = [];%hevel, just to compare with Eye_velocity obtained by VOREyeHeadDataFitAK

EyeHeadData.lh = Epos;
EyeHeadData.eyevel = Evel;%hevel, just to compare with Eye_velocity obtained by VOREyeHeadDataFitAK
EyeHeadData.headvel = Hvel;
