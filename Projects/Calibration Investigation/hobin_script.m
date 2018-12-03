% go through 1_Maxwell_Gagnon and then ProjectData_Testing
% in each folder in this directory (i.e. Delta7, Delta7-Gen)
%   - FOR each folder in Delta7
%   - open the .xlsx file that matches the name of the folder 
%   - onto the final destination .xlsx file do what is done
%   - open the .mat file that matches the name of the folder + '_calib'
%   - onto the final destination .xlsx file do what is done

% create xlsx_files vector and remove csv duplicates
xlsx_files = dir('**/*.xlsx');
i = 1;
vec_length = length(xlsx_files);
while i <= vec_length
    if contains(xlsx_files(i,1).name, '._')
        xlsx_files(i) = [];
        vec_length = vec_length - 1;
    else
        i = i + 1;
    end
end

xlsx_vector = strings(vec_length,1);
for i = 1:vec_length
    xlsx_vector(i,1) = strcat(xlsx_files(i,1).folder, '\', xlsx_files(i,1).name);
end

combo_vector = strings(length(xlsx_vector), 2);
for i = 1:vec_length
    combo_vector(i,1) = xlsx_vector(i,1);
    bare = extractBefore(xlsx_vector(i,1), ...
        max(strfind(xlsx_vector(i,1), ".xlsx")));
    combo_vector(i,2) = strcat (bare, "_calib.mat");
end

% create the master dst file
dst_file = 'Z:\1_Maxwell_Gagnon\ProjectData_Testing\dst.xlsx';

xlStartRange = 1;

for i = 1:vec_length
    xlsx_file = combo_vector(i,1);
    mat_file = combo_vector(i,2);
    xlEndRange = getInfo(dst_file, xlsx_file, mat_file, xlStartRange);
    xlStartRange = xlEndRange;
end

% -- getInfo 
% @pre: reads .xlsx file input (complete file path)
% @post: writes onto dst.xlsx 
function xlEndRange = getInfo(dst_file, xlsx_file, mat_file, xlStartRange)
[num, txt, raw] = xlsread(xlsx_file);

% TYPE
raw_type = raw(:,1);
raw_length = length(raw(:,1));
i = 1;
while i <= raw_length
    if ismissing(string(raw(i,1)))
        raw_type(i) = [];
        raw_length = raw_length - 1;
    else
        i = i + 1;
    end
end

xlRange_TypeLength = length(raw_type);
xlrange_Type = strcat('B', num2str(xlStartRange), ':B',num2str(xlStartRange - 1 + xlRange_TypeLength));

if (xlStartRange == 1)
    xlrange_Type = strcat('B', num2str(xlStartRange), ':B',num2str(xlStartRange - 1 + xlRange_TypeLength));
    xlswrite(dst_file, string(raw_type), xlrange_Type); 
else 
    xlrange_Type = strcat('B', num2str(xlStartRange), ':B',num2str(xlStartRange - 2 + xlRange_TypeLength));
    xlswrite(dst_file, string(raw_type(2:end,1)), xlrange_Type);
end

% NAME
just_xlsxname = extractBetween(xlsx_file, ...
       max(strfind(xlsx_file, "\")) + 1, ... 
       max(strfind(xlsx_file, ".xlsx")) - 1);
   
if (xlStartRange == 1)
    xlswrite(dst_file, {'Name'}, 'A1:A1');
    xlrange_Name = strcat('A', num2str(xlStartRange + 1), ':A', num2str(xlStartRange - 1 + xlRange_TypeLength));
    xlswrite(dst_file, cellstr(just_xlsxname), xlrange_Name) ;
else
    xlrange_Name = strcat('A', num2str(xlStartRange), ':A', num2str(xlStartRange - 2 + xlRange_TypeLength));
    xlswrite(dst_file, cellstr(just_xlsxname), xlrange_Name) ;
end

% TIME POINT
raw_timepoint1 = char(raw(1,2));
raw_timepoint2 = sym(raw(2:end,2));
raw_timepoint2 = raw_timepoint2(~isnan(raw_timepoint2));

if (xlStartRange == 1) 
    xlRange_TimepointLength = 1 + length(raw_timepoint2) ;
    xlrange_Timepoint = strcat('C', num2str(xlStartRange + 1), ':C', num2str(xlRange_TimepointLength)) ;
    xlswrite(dst_file, {raw_timepoint1}, 'C1:C1');
    xlswrite(dst_file, double(raw_timepoint2), xlrange_Timepoint) ;
else
    xlRange_TimepointLength = 1 + length(raw_timepoint2) ;
    xlrange_Timepoint = strcat('C', num2str(xlStartRange), ':C', num2str(xlStartRange - 2 + xlRange_TimepointLength)) ;
    xlswrite(dst_file, double(raw_timepoint2), xlrange_Timepoint) ;
end

% FREQUENCY
raw_frequency1 = char(raw(1,3));
raw_frequency2 = sym(raw(2:end,3));
raw_frequency2 = raw_frequency2(~isnan(raw_frequency2));

if (xlStartRange == 1) 
    xlRange_FrequencyLength = 1 + length(raw_frequency2) ;
    xlrange_Frequency = strcat('D', num2str(xlStartRange + 1), ':D', num2str(xlRange_FrequencyLength)); 
    xlswrite(dst_file, {raw_frequency1}, 'D1:D1');
    xlswrite(dst_file, double(raw_frequency2), xlrange_Frequency) ;
else
    xlRange_FrequencyLength = 1 + length(raw_frequency2) ;
    xlrange_Frequency = strcat('D', num2str(xlStartRange), ':D', num2str(xlStartRange - 2 + xlRange_FrequencyLength)); 
    xlswrite(dst_file, double(raw_frequency2), xlrange_Frequency) ;
end

% EYEHAMP
raw_eyehamp1 = char(raw(1,16));
raw_eyehamp2 = sym(raw(2:end,16));
raw_eyehamp2 = raw_eyehamp2(~isnan(raw_eyehamp2));

if (xlStartRange == 1) 
    xlRange_EyehampLength = 1 + length(raw_eyehamp2) ;
    xlrange_Eyehamp = strcat('E', num2str(xlStartRange + 1), ':E', num2str(xlRange_EyehampLength)) ;
    xlswrite(dst_file, {raw_eyehamp1}, 'E1:E1');
    xlswrite(dst_file, double(raw_eyehamp2), xlrange_Eyehamp) ;
else
    xlRange_EyehampLength = 1 + length(raw_eyehamp2) ;
    xlrange_Eyehamp = strcat('E', num2str(xlStartRange), ':E', num2str(xlStartRange - 2 + xlRange_EyehampLength)) ;
    xlswrite(dst_file, double(raw_eyehamp2), xlrange_Eyehamp) ;
end

% mat_file
mat_file = matfile(mat_file);

% SCALECH1 - note that we are using the xlRange_EyehampLength
%            because it is the length of the data vector; the choice
%            was arbitrary
if (xlStartRange == 1) 
    xlrange_scaleCh1 = strcat('F', num2str(xlStartRange + 1), ':F', num2str(xlRange_EyehampLength));
    xlswrite(dst_file, {'scaleCh1'}, 'F1:F1');
    xlswrite(dst_file, mat_file.scaleCh1, xlrange_scaleCh1) ;
else
    xlrange_scaleCh1 = strcat('F', num2str(xlStartRange), ':F', num2str(xlStartRange - 2 + xlRange_EyehampLength));
    xlswrite(dst_file, mat_file.scaleCh1, xlrange_scaleCh1) ;
end

% SCALECH2
if (xlStartRange == 1) 
    xlrange_scaleCh2 = strcat('G', num2str(xlStartRange + 1), ':G', num2str(xlRange_EyehampLength));
    xlswrite(dst_file, {'scaleCh2'}, 'G1:G1');
    xlswrite(dst_file, mat_file.scaleCh2, xlrange_scaleCh2) ;
else
    xlrange_scaleCh2 = strcat('G', num2str(xlStartRange), ':G', num2str(xlStartRange - 2 + xlRange_EyehampLength));
    xlswrite(dst_file, mat_file.scaleCh2, xlrange_scaleCh2) ;    
end

% update getInfo output
xlEndRange = xlStartRange + xlRange_TypeLength;
end