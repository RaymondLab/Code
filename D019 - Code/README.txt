Read Me for Hannah's eye calibration and VOR analysis

===========SETUP===========
First add all the files in this folder to your MATLAB path by entering 
this line at your MATLAB command prompt: (change this to wherever this 
folder is stored). You will also need to add the "dat" folder and 
subfolders to your path
>> addpath(genpath('C:\Dropbox\rlab\code\autoVOR'))
>> addpath(genpath('C:\Dropbox\rlab\code\eyetrack'))
>> addpath(genpath('C:\Dropbox\rlab\code\dat'))
>> savepath 

===========CALIBRATION===========
1. To run a calibration session, run runSETUP.m with both cameras
Normally 1-3 minutes are run, a shorter version is provided for testing 
in the folder 20150604_PC2_calib

2. To analyze a calibration session:
Run the last two sections in the runSETUP.m script, changing parameters 
as needed. Check images to make sure correct channel was chosen

3. Copy the "*_calib.mat" output file to the relevant experiment folders you 
wish to use it for. scale Ch1 and scaleCh2 are the relevant scale factors to 
convert from Volts to degrees


===========VOR EXPERIMENT ANALYSIS===========
1. After an experiment, navigate to the expmt folder in matlab.
Make sure there are two files, both with the same name as the folder. 
yyyymmdd_PC2_x2.smr : experiment data file
yyyymmdd_PC2_x2.xlsx : timestamps for analysis (see template provided)

The calibration file should also be located in the folder, or you can 
navigate to it when prompted

2. Run the main runVOR script in MATLAB
>> runVOR

3. Analysis should run! Each segment will display and a final plot
 of all the horizontal eye amplitudes will appear.

4. Results are stored in a structure named 'result'. The data is identified
 with the result.header field. 'eyeHgain' is column 4, so you can access it
 as follows:
>> result.data(:,4)


