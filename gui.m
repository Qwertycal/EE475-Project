function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 16-Apr-2015 15:27:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set up global variables for number of spaces
global totalspaces;
totalspaces = 0;
global totaloccupied;
totaloccupied = 0;
global totalempty;
totalempty = 0;

% Set up global variables for graph data;
global x;
x = [];
global y;
y = [];
global z;
z = [];



% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open the file loader
filename = uigetfile('*.jpg');

% Change to greyscale
I = imread(filename);
I  = I(:,:,1);

% Show the image
imshow(I);

% --- Executes on button press in drawbutton.
function drawbutton_Callback(hObject, eventdata, handles)
% hObject    handle to drawbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
BW = roipoly;


% --- Executes on button press in analysebutton.
function analysebutton_Callback(hObject, eventdata, handles)
% hObject    handle to analysebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global totalspaces;
global totaloccupied;
global totalempty;

global x;
global y;
global z;

% Reset the number of empty and occupied spaces
totaloccupied = 0;
totalempty = 0;

% Do the analysis
% for each ROI
% if space std >= some number
% totaloccupied++
% else totalempty++

% Calculate the total number of spaces
totalspaces = totaloccupied + totalempty;

% Check if data sets are empty. If they are, make them arrays with a single
% element and set it to the first data values
if(isempty(x) == 1)
    x = [0];
    y = [0]; 
    y(end) = totaloccupied;
    z = [0];
    z(end) = totalempty;
% If they are not empty, add new data value to the end of each array
else
    x(end+1) = x(end)+1; 
    y(end+1) = totaloccupied;
    z(end+1) = totalempty;
end

% Update text boxes on GUI
set(handles.edittotal,'String',totalspaces);
set(handles.editoccupied,'String',totaloccupied);
set(handles.editempty,'String',totalempty);


% --- Executes on button press in plotbutton.
function plotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x;
global y;
global z;

% Set up new figure
f = figure; 

% Plot the data on empty and occupied spaces on the same plot
plot(x,y,x,z);

% Set up labels and legend
xlabel('Picture number');
ylabel('Number of spaces');
title('Number of empty and occupied spaces over time');
legend('Occupied','Empty');

function edittotal_Callback(hObject, eventdata, handles)
% hObject    handle to edittotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edittotal as text
%        str2double(get(hObject,'String')) returns contents of edittotal as a double


% --- Executes during object creation, after setting all properties.
function edittotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edittotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editoccupied_Callback(hObject, eventdata, handles)
% hObject    handle to editoccupied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editoccupied as text
%        str2double(get(hObject,'String')) returns contents of editoccupied as a double


% --- Executes during object creation, after setting all properties.
function editoccupied_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editoccupied (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editempty_Callback(hObject, eventdata, handles)
% hObject    handle to editempty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editempty as text
%        str2double(get(hObject,'String')) returns contents of editempty as a double


% --- Executes during object creation, after setting all properties.
function editempty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editempty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
