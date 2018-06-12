function varargout = VOR_Analysis(varargin)
    % VOR_ANALYSIS MATLAB code for VOR_Analysis.fig
    %      VOR_ANALYSIS, by itself, creates a new VOR_ANALYSIS or raises the existing
    %      singleton*.
    %
    %      H = VOR_ANALYSIS returns the handle to a new VOR_ANALYSIS or the handle to
    %      the existing singleton*.
    %
    %      VOR_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in VOR_ANALYSIS.M with the given input arguments.
    %
    %      VOR_ANALYSIS('Property','Value',...) creates a new VOR_ANALYSIS or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before VOR_Analysis_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to VOR_Analysis_OpeningFcn via varargin.
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

    % Edit the above text to modify the response to help VOR_Analysis

    % Last Modified by GUIDE v2.5 17-May-2018 13:42:44

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @VOR_Analysis_OpeningFcn, ...
                       'gui_OutputFcn',  @VOR_Analysis_OutputFcn, ...
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


% --- Executes just before VOR_Analysis is made visible.
function VOR_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to VOR_Analysis (see VARARGIN)

    % Choose default command line output for VOR_Analysis
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes VOR_Analysis wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VOR_Analysis_OutputFcn(hObject, eventdata, handles) 
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
    handles.checkbox1.Value = 1;
    handles.checkbox2.Value = 1;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % Analysis/Project
    params.analysis = handles.popupmenu1.String{handles.popupmenu1.Value};

    % Data Location
    params.folder = handles.edit1.String;

    % Extras
    params.do_subplots = handles.checkbox1.Value;
    params.do_individual = handles.checkbox5.Value;
    params.do_polar_plots = handles.checkbox3.Value;

    % Other Parameters
    params.saccadePre = str2double(handles.edit2.String);
    params.saccadePost = str2double(handles.edit3.String);
    params.saccadeThresh = str2double(handles.edit4.String);

    % Single / Batch
    params.count = handles.text7.String;
    
    % Let the user know when the analysis is running & finished
    handles.text11.ForegroundColor = [.3, .75, .93];
    handles.text11.String = 'Running...';
    pause(.1)
    runTest(params);
    handles.text11.String = 'Finished!';
    handles.text11.ForegroundColor = [0 .6 .25];



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % Change string of edit box to the selected folder
    folder = uigetdir('C:\', 'Choose Folder that Contains the Data');
    handles.edit1.String = folder;
    checkFolderStructer(folder, handles)



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu1
    % only display the 'polar plots' checkbox when running Dark Rearing
    % Analyis
    if strcmp(hObject.String{handles.popupmenu1.Value}, 'Dark Rearing')
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.Value = 1;
    elseif strcmp(hObject.String{handles.popupmenu1.Value}, 'Dark Rearing + Generalization')
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.Value = 1;
    else
        handles.checkbox3.Visible = 'off';
        handles.checkbox3.Value = 0;
    end

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
    checkFolderStructer(handles.edit1.String, handles)
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


% Determines if analysis is for 1 or > 1 .smr files
function checkFolderStructer( folder, handles )
   
    handles.text7.String = ' ';
    handles.text7.ForegroundColor = [0 0 0];

    % Check that a real folder was selected
    try
        cd(folder)
        HeadfolderContents = dir;
        [~, headFolder] = fileparts(HeadfolderContents(1).folder);
    catch
        handles.text7.String = 'Invalid Folder';
        handles.text7.ForegroundColor = [1 0 0];
        return
    end

    % check if there is a .smr file directly in folder
    for i = 3:length(HeadfolderContents)
        if strcmp(HeadfolderContents(i).name, strcat(headFolder, '.smr')) && ~contains(HeadfolderContents(i).name, 'calib')
            handles.text7.String = 'Single Analysis';
            handles.text7.ForegroundColor = [0 .6 .25];

            return
        end
    end

    % check if .smr file is one level down
    for i = 3:length(HeadfolderContents)
        try
            cd(HeadfolderContents(i).name)
            tempDirectory = dir;
            for j = 3:length(tempDirectory)
                if strcmp(tempDirectory(j).name, strcat(HeadfolderContents(i).name, '.smr')) && ~contains(HeadfolderContents(i).name, 'calib')
                    handles.text7.String = 'Batch Analysis';
                    handles.text7.ForegroundColor = [0 .6 .25];
                    return
                end 
            end
        end
    end

    % print that nothing was found
    handles.text7.String = 'No ''.smr'' Detected';
    handles.text7.ForegroundColor = [1 0 0];


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
    for i = 1:length(figHandles)
        if strcmp(figHandles(i).Name, 'VOR_Analysis')
            figHandles(i) = [];
            break
        end
    end
    close(figHandles)


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
