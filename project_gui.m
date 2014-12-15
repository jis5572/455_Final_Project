function varargout = project_gui(varargin)
% PROJECT_GUI MATLAB code for project_gui.fig
%      PROJECT_GUI, by itself, creates a new PROJECT_GUI or raises the existing
%      singleton*.
%
%      H = PROJECT_GUI returns the handle to a new PROJECT_GUI or the handle to
%      the existing singleton*.
%
%      PROJECT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT_GUI.M with the given input arguments.
%
%      PROJECT_GUI('Property','Value',...) creates a new PROJECT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project_gui

% Last Modified by GUIDE v2.5 10-Dec-2014 03:08:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @project_gui_OutputFcn, ...
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

end
% --- Executes just before project_gui is made visible.
function project_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project_gui (see VARARGIN)

% Choose default command line output for project_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end
% --- Outputs from this function are returned to the command line.
function varargout = project_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenu1
global I; %image to be worked on 
I = imread('cameraman.tif');
global len;
global theta;
global noisyI;
global wnoise;
global blurredI; 


name = get(handles.popupmenu1,'Value');

switch name
    case 1
        I = imread('cameraman.tif');
    case 2
        I = imread('circuit.tif');
    case 3
        I = imread('Trees.jpg');
        I = rgb2gray(I);
    case 4
        I = imread('Rec.jpg');
        I = rgb2gray(I);
    case 5
        I = imread('Eisenhower.jpg');
        I = rgb2gray(I);
    case 6
        I = imread('Arts.jpg');
        I = rgb2gray(I);
end

axes(handles.axes1);
imshow(I);

noisyI = addNoise(I);

axes(handles.axes5);
imshow(noisyI);


sLen = get(handles.edit3, 'String');
len = str2num(sLen);

sTheta = get(handles.edit4, 'String');
theta = str2num(sTheta);
wnoise = 0.5*randn(size(I));  
blurredI = addBlur(noisyI);

axes(handles.axes6);
imshow(blurredI);

cla(handles.axes3);
cla(handles.axes2);

set(handles.edit1, 'String', '');
set(handles.edit2, 'String', '');


end
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%Degradation Functions:

% Adds Additive Gaussian Noise to Image
function n = addNoise(I)
global noise;
noise = imnoise(I, 'gaussian');
n = imnoise(I, 'gaussian');
% noise = imadd(I, n1);
% n = imadd(I, n1);
end

%add user-defined blur to image
function b = addBlur(I)
%Simulates linear motion blue across LEN pixels
%and angle of THETA degrees
global len;
global theta;
PSF = calcPSF(len, theta);
b = imfilter(I, PSF, 'circular', 'conv');
end

%Performs Wiener deconvolution to image Im using NSR
function w = fWiener(Im, n, handles)
global I;
global len; 
global theta;

% NSR = sum(n(:).^2)/sum(im2double(I(:)).^2); %Calculate NSR

% c.) Compute autocorrelation functions & apply Weiner Filter
NP = abs(fftn(n)).^2;
NPOW = sum(NP(:))/prod(size(n)); %noise power
NCORR = fftshift(real(ifftn(NP))); %noise ACF, centered
IP = abs(fftn(im2double(I))).^2; 
IPOW = sum(IP(:))/prod(size(I)); %original image power
ICORR = fftshift(real(ifftn(IP))); %image ACF, centered
PSF = calcPSF(len, theta);
w = deconvwnr(Im, PSF, NCORR, ICORR);

% w = deconvwnr(Im, PSF, NSR);

SNR = snr(w, I);
set(handles.edit1, 'String', SNR);

end

function lr = fLucyRich(bI, handles)
global len;
global theta;
global I;

damparArray = I;


sNumit = get(handles.edit5,'String');
numit = str2num(sNumit);

sDampar = get(handles.edit6,'String');
dampar = str2num(sDampar);

damparArray(:,:) = dampar;
PSF = calcPSF(len, theta);
lr = deconvlucy(bI, PSF, numit, damparArray);

SNR = snr(lr,I);
%set(SNR,handles.edit2,'String');
set(handles.edit2,'String',SNR);

end

function p = calcPSF(L, T)
p = fspecial('motion', L, T);  % h 
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

end
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

end 



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

end
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

end
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)  % Inputs parameters and perform restoration techniques
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global len;
global theta;
global noisyI;
global blurredI;
global wnoise;
global I;



sLen = get(handles.edit3, 'String');
len = str2num(sLen);

sTheta = get(handles.edit4, 'String');
theta = str2num(sTheta);

blurredI = addBlur(noisyI);
axes(handles.axes6);
imshow(blurredI);

wienerI = fWiener(blurredI, wnoise, handles);
axes(handles.axes2);
imshow(wienerI);

lucyRichI = fLucyRich(blurredI, handles);
axes(handles.axes3);
imshow(lucyRichI);


blurNoiseSNR = snr(blurredI, I);
set(handles.edit7, 'String', blurNoiseSNR);

end




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

end
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


end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

end
% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

end
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
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

end
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
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

end
% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
