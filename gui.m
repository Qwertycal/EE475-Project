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

% Last Modified by GUIDE v2.5 19-Apr-2015 20:09:04

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

global numberofregions oldcell totalspaces totaloccupied totalempty photonumber occupieddata emptydata;

% Set up global variables to keep track of how many masks there are and
% what the old cell looks like

% There are initially no masks
numberofregions = 0;

% Create a cell of size 0 with 1 dimension
oldcell = cell(0, 1);

% Set up global variables for number of spaces
totalspaces = 0;
totaloccupied = 0;
totalempty = 0;

% Set up global variables for graph data;
% Entry number or photo number
photonumber = [];
% Data on occupied spaces
occupieddata = [];
% Data on empty spaces
emptydata = [];


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Draws the image.
function draw()
global oldcell image numberofregions;

% Redraw the regions
imagewithoverlay = image;
for i = 0 : numberofregions - 1
    imagewithoverlay = imoverlay(imagewithoverlay, oldcell{i + 1}, [1 1 1]);
end
imshow(imagewithoverlay);

% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image;

% Open the file loader
[filename, pathname] = uigetfile('*.jpg', 'Select the image file');
image = imread(fullfile(pathname, filename));
% Change to greyscale so that impixel returns a RGB triplet
image = image(:, :, 1);
% Show the image
imshow(image);

% Redraw the regions
draw;


% --- Executes on button press in drawbutton.
function drawbutton_Callback(hObject, eventdata, handles)
% hObject    handle to drawbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
global numberofregions oldcell newcell image;

% Create new cell stack of size one greater then current number of masks
newcell = cell(numberofregions + 1, 1);

% Fill this new stack with all exisiting masks
newcell(1 : end - 1) = oldcell(:);

% Get coordinates of selected pixels
[c, r, P] = impixel;
% Add a coordinate to the end that is the same as the first one - this
% completes the shape
c(end + 1) = c(1);
r(end + 1) = r(1);
% Crete a binary (black and white) mask of same size as the image
BW = poly2mask(c, r, size(image,1), size(image,2));

% Add new mask to the stack
newcell{numberofregions + 1} = BW;
% This ammended stack now becomes the old one
oldcell = newcell;

% Increase the number of regions
numberofregions = numberofregions + 1;

% Draw the image
draw();




% --- Executes on button press in deletebutton.
function deletebutton_Callback(hObject, eventdata, handles)
% hObject    handle to deletebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global oldcell numberofregions;

% Check if there are regions to delete
if numberofregions > 0
    % Replicate the cell of masks, but cut off the last one
    oldcell = oldcell(1 : end - 1, :);
    numberofregions = numberofregions - 1;
    
    % Redraw the image
    draw();
end


% --- Executes on button press in analysebutton.
function analysebutton_Callback(hObject, eventdata, handles)
% hObject    handle to analysebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global totalspaces totaloccupied totalempty numberofregions oldcell image photonumber occupieddata emptydata;

% Update status text
set(handles.editstatus, 'String', 'Analysing');

% Reset the number of empty and occupied spaces
totaloccupied = 0;
totalempty = 0;

% Do the analysis
for i = 1 : numberofregions
    % Get the next mask to analyse
    BW = oldcell{i};
    % Create new vector consisting of the co ordinates of all points where
    % the mask overlaps the image
    [a, b] = ind2sub([size(image, 1), size(image, 2)], find(BW));

    % Create a zero array which is the same length as the number of
    % co-ordintates
	% (a and b are same length, so choose either)
    points = zeros(length(a), 1);
    
    % For every set of co-ordinates
    for j = 1 : length(a)
        % Fill this zero array with the pixel values
        points(j) = (image(a(j), b(j)));
    end
    
    % Testing - remove next comment to see calculated std
    disp(std(points));
    
    % If the standard deviation of the pixel values are low, no car
    if std(points) < 20
        totalempty = totalempty +  1;
    else
        totaloccupied = totaloccupied + 1;
    end
end

% Calculate the total number of spaces
totalspaces = totaloccupied + totalempty;

% Check if data sets are empty. If they are, make them arrays with a single
% element and set it to the first data values
if(isempty(photonumber))
    photonumber = 0;
    % Set the first data point to 1 rather than 0
    photonumber(end) = 1;
    occupieddata = 0; 
    occupieddata(end) = totaloccupied;
    emptydata = 0;
    emptydata(end) = totalempty;
% If they are not empty, add new data value to the end of each array
else
    % Make the next data point 1 bigger than the last one
    photonumber(end + 1) = photonumber(end) + 1; 
    occupieddata(end + 1) = totaloccupied;
    emptydata(end + 1) = totalempty;
end

% Update text boxes on GUI
set(handles.edittotal, 'String', totalspaces);
set(handles.editoccupied, 'String', totaloccupied);
set(handles.editempty, 'String', totalempty);
set(handles.editstatus, 'String', 'Done!');


% --- Executes on button press in plotbutton.
function plotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global photonumber occupieddata emptydata;

% Set up new figure
f = figure; 

% Plot the data on empty and occupied spaces on the same plot
plot(photonumber, occupieddata, photonumber, emptydata);

% Set up labels and legend
xlabel('Picture number');
ylabel('Number of spaces');
title('Number of empty and occupied spaces over time');
legend('Occupied','Empty');


% --- Executes on button press in clearbutton.
function clearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global photonumber occupieddata emptydata;

% Clear the data for x, y  and z
photonumber = 0;
photonumber(end) = 1;
occupieddata = 0;
emptydata = 0;


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



function editstatus_Callback(hObject, eventdata, handles)
% hObject    handle to editstatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editstatus as text
%        str2double(get(hObject,'String')) returns contents of editstatus as a double


% --- Executes during object creation, after setting all properties.
function editstatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editstatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

