function varargout = VOR_GUI(varargin)
    % VOR_GUI MATLAB code for VOR_GUI.fig
    %      VOR_GUI, by itself, creates a new VOR_GUI or raises the existing
    %      singleton*.
    %
    %      H = VOR_GUI returns the handle to a new VOR_GUI or the handle to
    %      the existing singleton*.
    %
    %      VOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in VOR_GUI.M with the given input arguments.
    %
    %      VOR_GUI('Property','Value',...) creates a new VOR_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before VOR_GUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to VOR_GUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    % 
    %      For all 'Callback' Functions
    %      hObject    handle to [current object (button, text, etc...)] (see GCBO)
    %      eventdata  reserved - to be defined in a future version of MATLAB
    %      handles    structure with handles and user data (see GUIDATA)
    % 
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help VOR_GUI

    % Last Modified by GUIDE v2.5 01-Nov-2018 13:07:39

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @VOR_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @VOR_GUI_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT


% --- Executes just before VOR_GUI is made visible.
function VOR_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to VOR_GUI (see VARARGIN)

    % Choose default command line output for VOR_GUI
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes VOR_GUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VOR_GUI_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);

    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % add image
    try
        axes(handles.axes1)
        matlabImage = imread('Eye_Image.png');
        image(matlabImage)
        axis off
        axis image
    catch
        warning('GUI Image not found :( ')
    end

    % make defaults
    handles.checkbox2.Value = 1;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % Project Information
    warning('on');
    params.analysis = handles.popupmenu1.String{handles.popupmenu1.Value};
    params.folder = handles.edit1.String;
    params.smr_files = dir([params.folder '\**\*.smr']);
    params.smr_files = params.smr_files(~contains({params.smr_files.name}, '_cali'));
    params.count = length(params.smr_files);
    params.cleanPlot = handles.radiobutton8.Value;
    params.cleanAnalysis = handles.radiobutton5.Value;
    
    % Extras Analysis / plotting
    params.newSac = handles.checkbox8.Value;
    params.NoiseAnalysis = handles.checkbox9.Value;
    params.do_individual = handles.checkbox5.Value;
    params.do_eyeAmp_summary = 1;
    params.do_eyeGain_summary = 1;
    params.do_sineAnalysis = 1; % TODO
    params.do_filter = 0;%handles.checkbox7.Value;
    
    % Saccade Parameters
    params.saccadePre = str2double(handles.edit2.String);
    params.saccadePost = str2double(handles.edit3.String);
    params.saccadeThresh = str2double(handles.edit4.String);
    
    % Filtering Parameters
    %params.BPFilterLow = str2double(handles.edit5.String);
    %params.BPFilterHigh = str2double(handles.edit6.String);
    
    % Meta information
    params.Run_Date = strrep(char(datetime('now')), ':', '-');
    params.Computer = getenv('computername');
    params.Person = getenv('username');
    
    % Let the user know when the analysis is running & finished
    handles.text11.ForegroundColor = [.3, .75, .93];
    handles.text11.String = 'Running...';
    pause(.1)
    VOR_Tests(params);
    handles.text11.String = 'Finished!';
    handles.text11.ForegroundColor = [0 .6 .25];

% Z:\1_Maxwell_Gagnon\ProjectData_Amin\Delta 07 Amin Data\Gain Down\0.6 Hz Gain Down\KI

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)

    % If there is already a folder listed in the edit box, open the popup
    % window to that folder.
    try cd(handles.edit1.String)
    catch
        handles.edi1.String = 'C:/';
    end
    
    
    % Change string of edit box to the selected folder
    folder = uigetdir(handles.edit1.String, 'Choose Folder that Contains the Data');
    handles.edit1.String = folder;
    defaultFolder = handles.edit1.String;
    checkFolderStructure(folder, handles);



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu1
    % only display the 'polar plots' checkbox when running Dark Rearing
    % Analyis

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
    % handles    empty - handles not created until after all CreateFcns called
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit1_Callback(hObject, eventdata, handles)
    checkFolderStructure(handles.edit1.String, handles);
    % Hints: get(hObject,'String') returns contents of edit1 as text
    %        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
    % handles    empty - handles not created until after all CreateFcns called
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% Determines if given folder is valid
function checkFolderStructure( folder, handles )
   
    handles.text7.String = ' ';
    handles.text7.ForegroundColor = [0 0 0];
    
    % Check if Real Folder
    if exist(folder, 'var') && ~exist(folder, 'dir')
        handles.text7.String = 'Invalid Folder';
        handles.text7.ForegroundColor = [1 0 0];
        return
    end
    
    % Search for non-calibration smr files
    smr_files = dir([folder '\**\*.smr']);
    smr_files = smr_files(~contains({smr_files.name}, '_cali'));

    % How many files were found?
    handles.text7.String = ['Files Found: ' num2str(length(smr_files))];
    if isempty(smr_files)
        handles.text7.ForegroundColor = [1 0 0];
    else
        handles.text7.ForegroundColor = [0 .6 .25]; 
    end


function edit2_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of edit2 as text
    %        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit3_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of edit3 as text
    %        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
    % handles    empty - handles not created until after all CreateFcns called
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit4_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of edit4 as text
    %        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of checkbox2

    
% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of checkbox3

    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

    % close all figures, except the GUI
    figHandles = findobj('Type', 'figure');
    close(figHandles(~contains({figHandles.Name}, 'VOR_GUI')))


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    dbstop if error
else 
    dbclear if error
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)

if ~(handles.checkbox7.Value)
    handles.text12.Visible = 'off';
    handles.edit5.Visible = 'off';
    handles.text13.Visible = 'off';
    handles.edit6.Visible = 'off';
else
    handles.text12.Visible = 'on';
    handles.edit5.Visible = 'on';
    handles.text13.Visible = 'on';
    handles.edit6.Visible = 'on';
end

% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
    if hObject.Value
        % pre
        handles.edit2.String = '.05';
        % post
        handles.edit3.String = '.05';
        % thresh
        handles.edit4.String = '.02';
    else
        % pre
        handles.edit2.String = '.075';
        % post
        handles.edit3.String = '.2';
        % thresh
        handles.edit4.String = '.55';
    end
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)    
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
