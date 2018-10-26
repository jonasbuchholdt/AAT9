function varargout = indstilVer4(varargin)

% Written by Jens Bo Nielsen, CAHR, Technical University of Denmark
% Latest update: Dec. 14, 2017
% jbn@elektro.dtu.dk

% INDSTILVER4 MATLAB code for indstilVer4.fig
%      INDSTILVER4, by itself, creates a new INDSTILVER4 or raises the existing
%      singleton*.
%
%      H = INDSTILVER4 returns the handle to a new INDSTILVER4 or the handle to
%      the existing singleton*.
%
%      INDSTILVER4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INDSTILVER4.M with the given input arguments.
%
%      INDSTILVER4('Property','Value',...) creates a new INDSTILVER4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before indstilVer4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to indstilVer4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help indstilVer4

% Last Modified by GUIDE v2.5 15-Nov-2016 13:31:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @indstilVer4_OpeningFcn, ...
                   'gui_OutputFcn',  @indstilVer4_OutputFcn, ...
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


% --- Executes just before indstilVer4 is made visible.
function indstilVer4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to indstilVer4 (see VARARGIN)

global c;

% Choose default command line output for indstilVer4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.settingsPanel,'BackgroundColor',c.panelColor);
set(handles.noiseOnsetField, 'String', num2str(c.settings.noiseOnset));
if  strcmp(c.settings.progressTrigger, 'play') 
    set(handles.playPressRB,'Value',1); %'Afspil' is the trigger
else 
    set(handles.acceptPressRB,'Value',1); %'Godkend' is the trigger   
end

if  strcmp(c.settings.noisePlay, 'continuous') 
    set(handles.continuousRB,'Value',1);
    set(handles.noiseOnsetText, 'Enable','Off'); 
    set(handles.noiseOnsetField, 'Enable','Off'); 
else
    set(handles.interruptedRB,'Value',1);
    set(handles.noiseOnsetText, 'Enable','On'); 
    set(handles.noiseOnsetField, 'Enable','On'); 
end

if  strcmp(c.settings.procedure, 'standard') 
    set(handles.standardProdRB,'Value',1); % standard HINT procedure
else 
    set(handles.maxLikeHoodRB,'Value',1); % maximum-likelihood procedure  
end

% UIWAIT makes indstilVer4 wait for user response (see UIRESUME)
% uiwait(handles.settingsScreen);


% --- Outputs from this function are returned to the command line.
function varargout = indstilVer4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in calibrationPB.
function calibrationPB_Callback(hObject, ~, handles)
% hObject    handle to calibrationPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


screenColor = get(handles.settingsScreen,'Color');
h = figure(kalibrerVer3);
set(h,'Color', screenColor);

% --- Executes when selected object is changed in progressGroup.
function progressGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in progressGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global c;

switch hObject
    case handles.playPressRB
        c.settings.progressTrigger = 'play';
        
    case handles.acceptPressRB
        c.settings.progressTrigger = 'accept';      
end

% --- Executes when selected object is changed in noiseControlGroup.
function noiseControlGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in noiseControlGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c;

switch hObject
    case handles.continuousRB
        c.settings.noisePlay = 'continuous';
        set(handles.noiseOnsetText, 'Enable','Off'); 
        set(handles.noiseOnsetField, 'Enable','Off');
        msgbox([{'Ved brug af kontinuerlig støj er det vigtigt, at afspilningen '; ...
             'ikke påvirkes af software til stabilisering af lydtrykket. '; ... 
            'Det kan for eksempel være ''Intelligent Volume Stabilizer'''; ... 
            'på visse Dell computere (under ''Dell Audio'' i Windows'' '; ...
            'kontrolpanel).';' '; ...
            'Softwaren kan ændre signal/støj-forholdet mellem';...
            'tale og baggrundsstøj og resultere i en upålidelig'; ...
            'SRT-måling. Deaktivér om nødvendigt softwaren.';' '; ...
            'Efter deaktivering er en ny kalibrering af lydtrykket';...
            'nødvendig.'}],'Justering af lydtryk','warn');
        
    case handles.interruptedRB
        c.settings.noisePlay = 'interrupted';
        set(handles.noiseOnsetText, 'Enable','On'); 
        set(handles.noiseOnsetField, 'Enable','On'); 
end

function noiseOnsetField_Callback(hObject, eventdata, handles)
% hObject    handle to noiseOnsetField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noiseOnsetField as text
%        str2double(get(hObject,'String')) returns contents of noiseOnsetField as a double
global c;

% The sound level to which the acoustic signal was calibrated:
c.settings.noiseOnset = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function noiseOnsetField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noiseOnsetField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in procedureControlGroup.
function procedureControlGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in procedureControlGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global c;

switch hObject
    case handles.standardProdRB
        c.settings.procedure = 'standard';
     
    case handles.maxLikeHoodRB
        c.settings.procedure = 'maxLikeHood';
        msgbox([{'Maximum-likelihood er ikke standard proceduren for HINT.'; ...
             'Maximum-likelihood bør foreløbigt kun bruges i forbindelse'; ... 
            'med undersøgelser af selve proceduren.'; ...
            'BRUG IKKE maximum-likelihood proceduren i forbindelse'; ...
            'med SRT bestemmelse i stilhed.'}], ...
            'Ny testprocedure','warn');

end

% --- Executes on button press in updatePB.
function updatePB_Callback(hObject, eventdata, handles)
% hObject    handle to updatePB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fl;
global c;

if (c.settings.noiseOnset >= 0.5 && c.settings.noiseOnset <= 5)
    file = [fl.noiseDir '\' c.settings.statNoiseFile];                                                      
    if exist(file,'file') == 2
        file = [fl.noiseDir '\' c.settings.modNoiseFile];
        if exist(file,'file') == 2
            settings = c.settings;
            save([fl.helpDir '\' fl.settingsFile],'settings');
            close;
        else
            errordlg('Lydfilen for moduleret støj findes ikke.','Filnavn','error');
        end
    else
        errordlg('Lydfilen for stationær støj findes ikke.','Filnavn','error');
    end
else
    errordlg('Onset skal ligge mellem 0.5 til 5 sek.','Onset','error');
end
