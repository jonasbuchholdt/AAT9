function varargout = kalibrerVer3(varargin)

% Written by Jens Bo Nielsen, CAHR, Technical University of Denmark
% Latest update: Nov. 28, 2013
% jbn@elektro.dtu.dk

% KALIBRERVER3 MATLAB code for kalibrerVer3.fig
%      KALIBRERVER3, by itself, creates a new KALIBRERVER3 or raises the existing
%      singleton*.
%
%      H = KALIBRERVER3 returns the handle to a new KALIBRERVER3 or the handle to
%      the existing singleton*.
%
%      KALIBRERVER3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KALIBRERVER3.M with the given input arguments.
%
%      KALIBRERVER3('Property','Value',...) creates a new KALIBRERVER3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kalibrerVer3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kalibrerVer3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kalibrerVer3

% Last Modified by GUIDE v2.5 15-Apr-2016 09:24:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kalibrerVer3_OpeningFcn, ...
                   'gui_OutputFcn',  @kalibrerVer3_OutputFcn, ...
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


% --- Executes just before kalibrerVer3 is made visible.
function kalibrerVer3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kalibrerVer3 (see VARARGIN)

global fl;
global c;
global lev;
% Choose default command line output for kalibrerVer3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.calibrationPanel,'BackgroundColor',c.panelColor);
set(handles.calibrationText,'BackgroundColor',c.panelColor);

file = [fl.helpDir '\' fl.calDataFile];
if exist(file,'file') == 2
    load(file,'calSoundLev','calFileLev');
    lev.calibration = calSoundLev;
    set(handles.calibrationField, 'String', num2str(calSoundLev));
end

% Create the audioplayer object:
[signal,Fs] = audioread([fl.noiseDir '\' fl.calNoiseFile]);
c.noiseObj = audioplayer(signal, Fs);

% The RMS level of the WAV signal file that is used for calibration
% (in dB relative to 1):
lev.calibrationFile  = 20 * log10(sqrt(mean(signal.^2)));

% UIWAIT makes kalibrerVer3 wait for user response (see UIRESUME)
% uiwait(handles.calibrationFig);


% --- Outputs from this function are returned to the command line.
function varargout = kalibrerVer3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in terminatePB.
function terminatePB_Callback(hObject, eventdata, handles)
% hObject    handle to terminatePB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fl;
global lev;
global c;

if lev.calibration > 39 && lev.calibration < 91
    calSoundLev = lev.calibration; %#ok<NASGU>
    calFileLev = lev.calibrationFile; %#ok<NASGU>
    save([fl.helpDir '\' fl.calDataFile],'calSoundLev','calFileLev');
    if isplaying(c.noiseObj)
        stop(c.noiseObj);
    end
    close;
else
    errordlg('Kalibreringslydtrykket skal ligge i intervallet 40-90 dB.','Kalibrering','error');
end


% --- Executes on button press in noisePlayPB.
function noisePlayPB_Callback(hObject, eventdata, handles)
% hObject    handle to noisePlayPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global c;

% Start the noise:
play(c.noiseObj);

function calibrationField_Callback(hObject, eventdata, handles)
% hObject    handle to calibrationField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calibrationField as text
%        str2double(get(hObject,'String')) returns contents of calibrationField as a double
global lev;

% The sound level to which the acoustic signal was calibrated:
lev.calibration = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function calibrationField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibrationField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
