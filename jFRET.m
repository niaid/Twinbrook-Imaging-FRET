function varargout = jFRET(varargin)
%JFRET M-file for jFRET.fig
%      JFRET, by itself, creates a new JFRET or raises the existing
%      singleton*.
%
%      H = JFRET returns the handle to a new JFRET or the handle to
%      the existing singleton*.
%
%      JFRET('Property','Value',...) creates a new JFRET using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to jFRET_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      JFRET('CALLBACK') and JFRET('CALLBACK',hObject,...) call the
%      local function named CALLBACK in JFRET.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jFRET

% Last Modified by GUIDE v2.5 04-May-2017 12:29:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jFRET_OpeningFcn, ...
                   'gui_OutputFcn',  @jFRET_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before jFRET is made visible.
function jFRET_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for jFRET
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jFRET wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jFRET_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fret_data_folder
folder_name = uigetdir;
if folder_name == 0
    folder_name = 'Try again!';
end
set(handles.edit1,'String',folder_name)
fret_data_folder = folder_name;



% --- Executes on button press in next_step.
function next_step_Callback(hObject, eventdata, handles)
% hObject    handle to next_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fret_data_folder outputs Gfactor coloc r_thresh mlimits pb method mode
fret_data_folder = get(handles.edit1,'String');
Gfactor = str2double(get(handles.edit2,'String'));
coloc = get(handles.checkbox1,'Value');
mlimits = get(handles.checkbox3,'Value');
r_thresh = get(handles.checkbox2,'Value');
pb = get(handles.edit3,'String');
%check the mode (file input radiobutton selection)
file_input = get(handles.radiobutton1,'Value');
if file_input == 1
    mode = 'ZEN';
else
    mode = 'PFRET';
end
%check the method selection
meth_input = get(handles.radiobutton4,'Value');
if meth_input == 1
    method = 'se';
else
    method = 'ap';
end
check_dir = exist(fret_data_folder,'dir');
if check_dir == 0
    empty = imread('empty_chest.jpg'); 
    msgbox('Folder not found. Try again.','Warning','custom',empty)
    return
elseif check_dir == 7
    lczi = dir([fret_data_folder,'/*.czi']);
    ltif = dir([fret_data_folder,'/*.tif']);
    if strcmp(mode,'ZEN') == 1
        if isempty(lczi) && isempty(ltif)
            empty = imread('empty_chest.jpg'); 
            uiwait(msgbox('There are no CZI or TIF files in the folder you selected. Try selecting another folder or the ''Group'' option.','Warning',...
                'custom',empty))
            tempfoldername = 'Try again!';
            set(handles.edit1,'String',tempfoldername)
            return
        end
    elseif strcmp(mode,'PFRET') == 1
        check_sub = exist([fret_data_folder,'/1'],'dir');
        if isempty(lczi) && isempty(ltif)
            if check_sub == 0
                empty = imread('empty_chest.jpg'); 
                uiwait(msgbox('Folder does not contain grouped image data that we can process. Try selecting another folder.','Warning',...
                    'custom',empty))
                tempfoldername = 'Try again!';
                set(handles.edit1,'String',tempfoldername)
                return
            end
        end
    end
    outputs = jFRET_work(method,mode);
    if strcmp(mode,'PFRET') == 1
        outFRET(outputs)
    end
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
response = questdlg('Would you like to exit?','Confirm Close');
switch response
    case 'No'
        % go back
    case 'Yes'
        delete(handles.figure1)
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpfile = [cd,'/readme.txt'];
%open(helpfile)
%fileread(helpfile)
%read text file lines as cell array of strings
fid = fopen( fullfile(helpfile) );
str = textscan(fid, '%s', 'Delimiter','\n'); 
str = str{1}(7:end); %**** Edit this part to make it look normal!!!!!!
fclose(fid);

%# GUI with multi-line editbox
hFig = figure('Menubar','none', 'Toolbar','none');
hPan = uipanel(hFig, 'Title','FRET Help', ...
    'Units','normalized', 'Position',[0.05 0.05 0.9 0.9]);
hEdit = uicontrol(hPan, 'Style','edit', 'FontSize',12, ...
    'Min',0, 'Max',2, 'HorizontalAlignment','left', ...
    'Units','normalized', 'Position',[0 0 1 1], ...
    'String',str);

% enable horizontal scrolling
%jEdit = findobj(hEdit);
%jEditbox = jEdit.getViewport().getComponent(0);
%jEditbox.setWrapping(false);                % turn off word-wrapping
%jEditbox.setEditable(false);                % non-editable
%set(jEdit,'HorizontalScrollBarPolicy',30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
% maintain horizontal scrollbar policy which reverts back on component resize 
%hjEdit = handle(jEdit,'CallbackProperties');
%set(hjEdit, 'ComponentResizedCallback',...'set(gcbo,''HorizontalScrollBarPolicy'',30)')



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
