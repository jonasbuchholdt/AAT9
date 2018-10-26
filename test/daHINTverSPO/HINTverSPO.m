function varargout = HINTverSPO(varargin)
%
% Data overview:
%
% The result of each SRT measurement is written to a .mat-file. The file is stored
% in subfolder 'results'.
% The file name is composed as: clientNumber_date_listUsed(_counter).mat.
% The variables in the .mat file:
%
% testDate:         date of the test session
%
% clientName:       test subject name
%
% clientNumber:     subject (client) number
%
% testResponsible:  responsible test leader
%
% signalChannel:    signal is presented in the right ear (R), the left ear (L)
%                   or both ears (R+L)
%
% noiseFile:        name of the noise file
%
% noiseLevel:       fixed noise level for the session
%
% corrSents:        number of correctly repeated sentences
%
% SRT:              the SRT estimate for the subject
%
% sentScores:       the scores for each sentence in the list:
%                     - column 1: sentence number in list
%                     - column 2: sentence text
%                     - column 3: sentence correctly repeated (0 or 1)
%                     - column 4: speech level
%
% For each client session a client record is created - it is contained in the
% cell array 'clientRecord'. The records are stored as .mat-files in subfolder
% 'records'. The records are also saved as .txt-files and stored in seperate
% folders for each client. These folders are found in 'klientRapporter'.
%
% Record layout (example):
% Dansk HINT resultatoversigt
%
% Klientnavn:           'clientName'
%
% Klient/journalnr.:    'clientNumber'
%
% Testdato:             'date'
%
% Testansvarlig:        'testResposible'
%
% Støjniveau:           'noiseLevel'
%
% Måleresultater:
%
%                      Liste (kanal)    SRT
%                         1 (H)         2.6 dB
%                         4 (V)         1.7 dB
%                         7 (H+V)       2.1 dB
%                           :           :
%
% Written by Jens Bo Nielsen, CAHR, Technical University of Denmark
% Latest update: Dec. 14, 2017
% jbn@elektro.dtu.dk

% HINTVERSPO MATLAB code for HINTverSPO.fig
%      HINTVERSPO, by itself, creates a new HINTVERSPO or raises the existing
%      singleton*.
%
%      H = HINTVERSPO returns the handle to a new HINTVERSPO or the handle to
%      the existing singleton*.
%
%      HINTVERSPO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HINTVERSPO.M with the given input arguments.
%
%      HINTVERSPO('Property','Value',...) creates a new HINTVERSPO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HINTverSPO_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HINTverSPO_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HINTverSPO

% Last Modified by GUIDE v2.5 14-Dec-2017 10:23:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HINTverSPO_OpeningFcn, ...
    'gui_OutputFcn',  @HINTverSPO_OutputFcn, ...
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


% --- Executes just before HINTverSPO is made visible.
function HINTverSPO_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HINTverSPO (see VARARGIN)

global fl; % file locations: location of files and directories
global lev; % level of sound and files
global tm; % test material: text and sound
global c; % control: counters, flags, settings, etc.
global dr; % data and results: client data and measurement results

% Choose default command line output for HINTverSPO
handles.output = hObject;

% File locations and names:
fl.noiseDir = '.\noise';
fl.noiseFile = 'daHINTnoise5min.wav'; % default stationary noise file
fl.calNoiseFile = 'daHINTnoise5min.wav';
fl.calDataFile = 'calibrationData.mat';
fl.resultDir = '.\results';
fl.recordDir = '.\records';
fl.publicDir = '.\klientRapporter';
fl.helpDir = '.\helpFiles';
fl.settingsFile = 'settings.mat';
fl.textMat = 'textMat.mat';

% Load the settings for
%   1. names of noise files (stationary and modulated)
%   2. selection of progress trigger ('Afspil' or 'Godkend')
%   3. how to play the noise (continuous or interrupted)
%   3. the duration of the noise onset (ahead of the sentence)
% or set the defaults:
file = [fl.helpDir '\' fl.settingsFile];
if exist(file,'file') == 2
    load(file,'settings');
    c.settings = settings;
else
    c.settings.progressTrigger = 'accept'; % sentence plays after press on 'Godkend'
    c.settings.noisePlay = 'interrrupted';
    c.settings.noiseOnset = 1;
    c.settings.procedure = 'standard';
    settings = c.settings;
    save([fl.helpDir '\' fl.settingsFile],'settings');
end


% Initial playback levels and sentence file level:
% The default speech level at test start in silence:
lev.speechDefaultInSilence = 45;
% The HINT standard noise level (and speech level at test start):
lev.noiseStandard = 65;
% The RMS level of the HINT sentence files (in dB relative to 1):
lev.sentenceFile = -26; % (the assumed level irrespective of the changes due to intelligibility equalization)

% Number of sentences in the test and training lists:
c.lastSentNum = 20;

% Adjust the alignment of the alternative words:
c.microAlign = -1;
% Order the alternative words according to length ('n'/'y'):
c.wordOrdered = 'n';

dr.date = datestr(date,'dd-mm-yyyy');
set(handles.dateField,'String',dr.date);
rand('state',sum(100*clock));

% Set 'default' client data (so data can be saved if fields are left empty):
dr.clientName = 'Klientnavn';
dr.clientNumber = 'Kundenummer';
dr.tester = 'Testansvarlig';

% Give text boxes the same color as the GUI background color:
screenColor = get(handles.HINTscreen,'Color');
set(handles.headerText,'BackgroundColor', screenColor);
set(handles.CAHRtext,'BackgroundColor', screenColor);

c.panelColor = get(handles.testDataPanel,'BackgroundColor');
setControlPanelColor(handles, c.panelColor);

panelColor = get(handles.sentencePanel,'BackgroundColor');
setRunPanelColor(handles, panelColor);
setAltWordColors(handles, panelColor, [0.6 0.6 0.6]);

% Set the GUI fields and buttons:
disableChannelSelect(handles);
disableTrainLists(handles);
removeTrainSelection(handles);
disableTestLists(handles);
removeTestSelection(handles);
removeTestTypes(handles);
set(handles.playSentencePB, 'Enable', 'Off');
set(handles.correctCB, 'Enable', 'Off');
set(handles.incorrectCB, 'Enable', 'Off');
set(handles.acceptPB, 'Enable', 'Off');
set(handles.startPB, 'Enable', 'Off');

% Title and labels for the plot figure:
plot(handles.testProgressFig,1,1);
set(handles.testProgressFig, 'XLim',[0 21], 'YLim',[55 75]);
%set(handles.testProgressFig,'YDir','reverse');
set(handles.testProgressFig, 'XTick', 1:20, 'YTick',50:2:100,'XGrid','on','YGrid','on');
xlabel(handles.testProgressFig,'Sætningsnummer','fontsize',12);
ylabel(handles.testProgressFig,'Niveau [dB]','fontsize',12);
title(handles.testProgressFig,'Testforløb                                                      ','fontsize',14,'fontweight','bold','Color',get(handles.sentencePanel,'ForegroundColor'));

% Display the CAHR logo:
axes(handles.CAHRlogo);
logo = imread([fl.helpDir '/' 'CAHRlogo.png']);
color = get(handles.HINTscreen,'Color');
temp = logo(:,:,1);
temp(temp == 255) = color(1)*255;
logo(:,:,1) = temp;
temp = logo(:,:,2);
temp(temp == 255) = color(2)*255;
logo(:,:,2) = temp;
temp = logo(:,:,3);
temp(temp == 255) = color(3)*255;
logo(:,:,3) = temp;

image(logo);
set(handles.CAHRlogo, 'visible','off');

axes(handles.testProgressFig);

% Update handles structure
guidata(hObject, handles);
drawnow;

% Load the sentence texts:
tm = load([fl.helpDir '\' fl.textMat]);

% Load the stationary (default) noise signal:
[tm.noiseSignal,tm.Fs] = audioread([fl.noiseDir '\' fl.noiseFile]);

% Load calibration data:
file = [fl.helpDir '\' fl.calDataFile];
if exist(file,'file') == 2
    load(file,'calSoundLev','calFileLev');
    lev.calibration = calSoundLev;
    lev.calibrationFile = calFileLev;
end

% UIWAIT makes HINTverSPO wait for user response (see UIRESUME)
% uiwait(handles.HINTscreen);

% --- Outputs from this function are returned to the command line.
function varargout = HINTverSPO_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function nameField_Callback(hObject, ~, ~)
% hObject    handle to nameField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nameField as text
%        str2double(get(hObject,'String')) returns contents of nameField as a double
global dr;

dr.clientName = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function nameField_CreateFcn(hObject, ~, ~)
% hObject    handle to nameField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numberField_Callback(hObject, ~, ~) %#ok<*DEFNU>
% hObject    handle to numberField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberField as text
%        str2double(get(hObject,'String')) returns contents of numberField as a double
global dr;

dr.clientNumber = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function numberField_CreateFcn(hObject, ~, ~)
% hObject    handle to numberField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function recomLevelField_Callback(hObject, ~, ~)
% hObject    handle to recomLevelField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recomLevelField as text
%        str2double(get(hObject,'String')) returns contents of recomLevelField as a double
global lev;
temp = lev.noiseRecom; 
lev.noiseRecom = str2double(get(hObject,'String'));
if (lev.noiseRecom >= 0 && lev.noiseRecom <= 85)
    lev.noise = lev.noiseRecom;
else
    errordlg('Støjniveauet skal ligge mellem 0 til 85 dB.','Onset','error');
    lev.noiseRecom = temp; % reset field to previous value
    set(hObject, 'String', num2str(lev.noiseRecom));
end

% --- Executes during object creation, after setting all properties.
function recomLevelField_CreateFcn(hObject, ~, ~)
% hObject    handle to recomLevelField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dateField_Callback(hObject, ~, ~)
% hObject    handle to dateField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateField as text
%        str2double(get(hObject,'String')) returns contents of dateField as a double
global dr;

dr.date = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function dateField_CreateFcn(hObject, ~, ~)
% hObject    handle to dateField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function testerField_Callback(hObject, ~, ~)
% hObject    handle to testerField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testerField as text
%        str2double(get(hObject,'String')) returns contents of testerField as a double
global dr;

dr.tester = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function testerField_CreateFcn(hObject, ~, ~)
% hObject    handle to testerField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in testTypeGroup.
function testTypeGroup_SelectionChangeFcn(hObject, ~, handles)
% hObject    handle to the selected object in testTypeGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global fl;
global tm;
global c;
global lev;

switch hObject
    case handles.trainSilenceRB
        c.selectedTestType = 'Training in silence';
        enableTrainLists(handles);
        disableTestLists(handles);
        removeTestSelection(handles);
        set(handles.standardLevelRB, 'Value', 0);
        set(handles.recomLevelRB, 'Value', 0);
        set(handles.recomLevelField, 'Visible','Off');
        set(handles.standardLevelRB, 'Enable', 'Off');
        set(handles.recomLevelRB, 'Enable', 'Off');
        fl.speechDir = '.\trainingWavFiles';
        fl.speechFile = 'trainingSent%03d.wav';
        tm.text = tm.trainText;
        lev.noise = 0;
        lev.speech = lev.speechDefaultInSilence;
        
    case handles.trainNoiseRB
        c.selectedTestType = 'Training in noise';
        enableTrainLists(handles);
        disableTestLists(handles);
        removeTestSelection(handles);
        if lev.noiseRecom ~= lev.noiseStandard;
            set(handles.recomLevelRB, 'Value', 1);
            set(handles.recomLevelField, 'String', num2str(lev.noiseRecom),'Visible','On');
            lev.noise = lev.noiseRecom;
        else
            set(handles.standardLevelRB, 'Value', 1);
            set(handles.recomLevelField,'Visible','Off');
            lev.noise = lev.noiseStandard;
        end
        set(handles.standardLevelRB, 'Enable', 'On');
        set(handles.recomLevelRB, 'Enable', 'On');
        set(handles.recomLevelField, 'Enable', 'On');
        fl.speechDir = '.\trainingWavFiles';
        fl.speechFile = 'trainingSent%03d.wav';
        tm.text = tm.trainText;
        
    case handles.testNoiseRB
        c.selectedTestType = 'Measurement in noise';
        enableTestLists(handles);
        disableTrainLists(handles);
        removeTrainSelection(handles);
        if lev.noiseRecom ~= lev.noiseStandard;
            set(handles.recomLevelRB, 'Value', 1);
            set(handles.recomLevelField, 'String', num2str(lev.noiseRecom),'Visible','On');
            lev.noise = lev.noiseRecom;
        else
            set(handles.standardLevelRB, 'Value', 1);
            set(handles.recomLevelField,'Visible','Off');
            lev.noise = lev.noiseStandard;
        end
        set(handles.standardLevelRB, 'Enable', 'On');
        set(handles.recomLevelRB, 'Enable', 'On');
        set(handles.recomLevelField, 'Enable', 'On');
        fl.speechDir = '.\testWavFiles';
        fl.speechFile = 'HINTsentence%03d.wav';
        tm.text = tm.testText;
end

% --- Executes on button press in startPB.
function startPB_Callback(hObject, ~, handles)
% hObject    handle to startPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fl;
global lev;
global c;
global dr;
global tm;

switch get(hObject, 'String')
    case 'Start liste'  % user starts the list
        % Initialisations:
        c.sentScored = 0;
        c.sentNum = 0;
        dr.sentScores = cell(21,4);
        set(handles.noiseLevelText,'Visible','Off');
        set(handles.SRTtext,'Visible','Off');
        if strcmp(c.selectedTestType,'Training in silence')
            lev.speech = lev.speechDefaultInSilence;
        else
            lev.speech = lev.noise;
        end
        c.plotMiddle = lev.speech;
        % Reset the plot figure:
        hold off;
        plot(handles.testProgressFig,1,1);
        set(handles.testProgressFig, 'XLim',[0 21]);
        set(handles.testProgressFig, 'YLim',[c.plotMiddle-10 c.plotMiddle+10]);
        % set(handles.testProgressFig,'YDir','reverse');
        set(handles.testProgressFig, 'XTick', 1:20, 'YTick',10:2:100,'XGrid','on','YGrid','on');
        
        xlabel(handles.testProgressFig,'Sætningsnummer','fontsize',12);
        ylabel(handles.testProgressFig,'Niveau [dB]','fontsize',12);
        title(handles.testProgressFig,'Testforløb                                                      ','fontsize',14,'fontweight','bold');
        
        % Check that calibration data are available:
        file = [fl.helpDir '\' fl.calDataFile];
        if exist(file,'file') == 2
            disableTrainLists(handles);
            disableTestLists(handles);
            disableTestTypes(handles);
            disableChannelSelect(handles);
            
            set(handles.standardLevelRB, 'Enable', 'Off');
            set(handles.recomLevelRB, 'Enable', 'Off');
            set(handles.recomLevelField, 'Enable', 'Off');           
            set(hObject, 'String', 'Afbryd liste');          
            set(handles.settingsPB, 'Enable', 'Off');
            set(handles.newClientPB, 'Enable', 'Off');
            set(handles.playSentencePB, 'Visible', 'On', 'Enable', 'On');
            
            % Data to use with the maximum-likelihood procedure:
            c.hypoPI = -20:0.2:200000; % interval of mean values of the PI-functions
            c.sigma = 2.6596; % std. deviation; corresponds to a slope of 15%/dB (for all functions)
            c.responseProp = zeros(21,length(c.hypoPI)); % probability for the recorded response (correct or incorrect) for each of the hypothetical PI functions
            c.cumulatProp = c.responseProp;% cumulated probability for each PI function
            c.maxProp = zeros(21,1); % maximum likelihood (probability) based on the cumulated responses
            c.MLEofPI = zeros(21,1); % hypothetical function (index) with the maximum likelihood
            lev.mlSNR = zeros(22,1); % SNRs during the maximum-likelihood procedure 
            
            % Start the noise signal if continuous noise is selected:         
            if strcmp(c.settings.noisePlay,'continuous') && ~strcmp(c.selectedTestType,'Training in silence')
                % Adjust the playback level of the noise signal:
                inputNoiseRMSlin = sqrt(mean(tm.noiseSignal.^2));
                noiseLevelLin = 10^((lev.noise - lev.calibration + lev.calibrationFile)/20);
                tm.noiseSignal = tm.noiseSignal.*(noiseLevelLin/inputNoiseRMSlin);
                if max(tm.noiseSignal) > 1
                    errordlg(['Støjsignalet kan ikke afspilles uden forvrænning.'...
                        'Benyt et lavere lydtryk under testen eller kalibrér udstyret'...
                        'til et højere lydtryk.'], 'Kalibrering','error');
                    % terminate the list:
                    set(handles.sentenceText, 'Visible', 'Off');
                    set(handles.sentencePanel, 'Title','Afspillet sætning ( )');
                    removeAltWords(handles);
                    enableTestTypes(handles);
                    set(hObject, 'String', 'Start liste');
                    set(handles.acceptPB, 'Enable', 'Off');
                    set(handles.playSentencePB, 'visible', 'Off');
                    set(handles.correctCB, 'Enable', 'Off');
                    set(handles.incorrectCB, 'Enable', 'Off');
                    
                    enableChannelSelect(handles);
                    
                    set(handles.settingsPB, 'Enable', 'On');
                    set(handles.newClientPB, 'Enable', 'On');
                    
                    if strcmp(c.selectedTestType,'Measurement in noise')
                        enableTestLists(handles);
                    else
                        enableTrainLists(handles);
                    end
                    if ~strcmp(c.selectedTestType,'Training in silence')
                        set(handles.standardLevelRB, 'Enable', 'On');
                        set(handles.recomLevelRB, 'Enable', 'On');
                        set(handles.recomLevelField, 'Enable', 'On');
                    end
                    return
                end
                % Play the stimulus in selected channels:
                switch c.channel
                    case 'coloc'
                        tm.noiseObj = audioplayer(tm.noiseSignal, tm.Fs);
                    case 'sep'
                        tm.noiseObj = audioplayer([tm.noiseSignal zeros(length(tm.noiseSignal),1)], tm.Fs);
                end
                % Start the noise signal:
                play(tm.noiseObj);
            end
            
        else
            errordlg('Ingen tilgængelige kalibreringsdata. Kalibrér ved hjælp af kalibreringsfunktionen under Indstillinger.','Kalibrering','error');
        end
        
    case 'Afbryd liste' % user disrupts the list
        response = questdlg('Data vil ikke blive gemt for denne liste. Skal listen afbrydes?', ...
            'Afbryd?', ...
            'Ja', 'Nej','Nej');
        if strcmp(response, 'Ja')
            if strcmp(c.settings.noisePlay,'continuous') && ~strcmp(c.selectedTestType,'Training in silence')
                stop(tm.noiseObj);
            end
            set(handles.sentenceText, 'Visible', 'Off');
            set(handles.sentencePanel, 'Title','Afspillet sætning ( )');
            removeAltWords(handles);
            enableTestTypes(handles);
            set(hObject, 'String', 'Start liste');
            set(handles.acceptPB, 'Enable', 'Off');
            set(handles.startPB, 'Enable', 'Off');
            set(handles.correctCB, 'Enable', 'Off');
            set(handles.incorrectCB, 'Enable', 'Off');
            set(handles.playSentencePB, 'Enable', 'Off');
            
            enableChannelSelect(handles);
            
            set(handles.settingsPB, 'Enable', 'On');
            set(handles.newClientPB, 'Enable', 'On');
            
            if strcmp(c.selectedTestType,'Measurement in noise')
                enableTestLists(handles);
            else
                enableTrainLists(handles);
            end
            if ~strcmp(c.selectedTestType,'Training in silence')
                set(handles.standardLevelRB, 'Enable', 'On');
                set(handles.recomLevelRB, 'Enable', 'On');
                set(handles.recomLevelField, 'Enable', 'On');
            end
        end
        
    case 'Beregn SRT' % user calculates SRT
        %Record the score and speech level for the last played sentence:
        dr.sentScores{c.sentNum,1} = c.sentID(c.sentNum); % sentence number in list
        dr.sentScores{c.sentNum,2} = tm.text{c.sentID(c.sentNum),1}; % sentence text
        dr.sentScores{c.sentNum,3} = get(handles.correctCB,'Value'); % sentence score
        dr.sentScores{c.sentNum,4} = lev.speech; % sentence level
        
        if strcmp(c.settings.procedure, 'standard') % the standard procedure is applied
            % store the speech level for sentence 21 (non-existing):
            if dr.sentScores{c.sentNum,3} == 1
                dr.sentScores{c.sentNum+1,4} = lev.speech - 2;
            else
                dr.sentScores{c.sentNum+1,4} = lev.speech + 2;
            end
        else % the maximum-likelihood procedure is applied
            if dr.sentScores{c.sentNum,3} == 1
                c.responseProp(c.sentNum+1,:) = PsyFcn(lev.mlSNR(c.sentNum+1),c.hypoPI(:),c.sigma);
            else
                c.responseProp(c.sentNum+1,:) = 1 - PsyFcn(lev.mlSNR(c.sentNum+1),c.hypoPI(:),c.sigma);
            end
                c.cumulatProp(c.sentNum+1,:) = prod(c.responseProp(1:c.sentNum+1,:),1);
                [c.maxProp(c.sentNum+1),c.MLEofPI(c.sentNum+1)] = max(c.cumulatProp(c.sentNum+1,:));
                % the 50% point on the chosen PI function will be the next presentation level:
                lev.mlSNR(c.sentNum+2) = c.hypoPI(c.MLEofPI(c.sentNum+1)); % this is the SNR for the next sentence 
                lev.speech = lev.mlSNR(c.sentNum+2) + lev.noise;
                dr.sentScores{c.sentNum+1,4} = lev.speech;
        end
        
        % Calculate and display the result of the SRT determination:
        corrSents = sum(cell2mat(dr.sentScores(:,3))); %#ok<NASGU>
        if strcmp(c.selectedTestType,'Training in silence')
            % SRT is reported as the mean absolute level (and not as SNR):
            SRT = mean(cell2mat(dr.sentScores(5:21,4)));
            lev.noiseRecom = round(max(SRT,45)) + 20;
            if lev.noiseRecom > lev.noiseStandard
                set(handles.noiseLevelText, 'String',['Anbefalet støjniv.: ' num2str(lev.noiseRecom,2) ' dB'],'Visible','On');
                set(handles.recomLevelField,'String', num2str(lev.noiseRecom));
            else
                set(handles.noiseLevelText, 'String','Standard støjniveau anbefales','Visible','On');
                set(handles.recomLevelField,'String', num2str(lev.noiseRecom));
            end
        else
            % SRT is reported as SNR:
            if strcmp(c.settings.procedure, 'standard') % the standard procedure is applied
                SRT = mean(cell2mat(dr.sentScores(5:21,4))) - lev.noise;
            else % the maximum-likelihood procedure is applied
                SRT = lev.mlSNR(c.sentNum+2);
            end
        end
        
        % Store the SRT and noise level for the client record:
        c.srtCount = c.srtCount + 1;
        dr.clientRecord{11+c.srtCount,2} = [c.selectedList ' (' c.channel ')'];
        dr.clientRecord{11+c.srtCount,3} = [num2str(SRT,2) ' dB'];
        dr.clientRecord{11+c.srtCount,4} = [num2str(lev.noise) ' dB'];
        
        if SRT < 0
            set(handles.SRTtext, 'String',['SRT målt til: - ' num2str(abs(SRT),2) ' dB'],'Visible','On'); % the way MATLAB writes minus is hard to read
        else
            set(handles.SRTtext, 'String',['SRT målt til: ' num2str(SRT,2) ' dB'],'Visible','On');
        end
        % Save the SRT measurement :
        testDate = dr.date; %#ok<NASGU>
        dr.clientRecord{7,2} = dr.date;
        clientName = dr.clientName; %#ok<NASGU>
        dr.clientRecord{3,2} = dr.clientName;
        clientNumber = dr.clientNumber; %#ok<NASGU>
        dr.clientRecord{5,2} = dr.clientNumber;
        testResponsible = dr.tester; %#ok<NASGU>
        signalChannel = c.channel; %#ok<NASGU>
        noiseFileName = fl.noiseFile; %#ok<NASGU>
        dr.clientRecord{9,2} = dr.tester;
        noiseLevel = lev.noise; %#ok<NASGU>
        % corrSents
        % SRT
        sentScores = dr.sentScores; %#ok<NASGU>
        testType = c.selectedTestType; %#ok<NASGU>
        listID = c.selectedList; %#ok<NASGU>
        fileName = [num2str(dr.clientNumber) '_' dr.date '_' c.selectedList '.mat'];
        file = [fl.resultDir '\' fileName];
        n = 0;
        while  exist(file,'file') == 2
            n = n + 1;
            file = [fl.resultDir '\' num2str(dr.clientNumber) '_' dr.date '_' c.selectedList '_' num2str(n) '.mat'];
        end
        save(file, 'clientName', 'clientNumber', 'testDate', ...
            'testResponsible', 'signalChannel', 'noiseFileName', 'testType', ...
            'listID', 'noiseLevel', 'corrSents','SRT', 'sentScores');
        
        set(handles.sentenceText, 'Visible', 'Off');
        set(handles.sentencePanel, 'Title','Afspillet sætning ( )');
        removeAltWords(handles);
        enableTestTypes(handles);
        set(hObject, 'String', 'Start liste');
        set(handles.acceptPB, 'Enable', 'Off');
        enableChannelSelect(handles);
        set(handles.settingsPB, 'Enable', 'On');
        set(handles.newClientPB, 'Enable', 'On');
        set(handles.startPB, 'Enable', 'Off');
        
        if strcmp(c.selectedTestType,'Measurement in noise')
            enableTestLists(handles);
        else
            enableTrainLists(handles);
        end
        if ~strcmp(c.selectedTestType,'Training in silence')
            set(handles.standardLevelRB, 'Enable', 'On');
            set(handles.recomLevelRB, 'Enable', 'On');
            set(handles.recomLevelField, 'Enable', 'On');
        end
end

% --- Executes on button press in newClientPB.
function newClientPB_Callback(hObject, ~, handles)
% hObject    handle to newClientPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dr;
global c;
global lev;
global fl;

switch get(hObject, 'String')
    case 'Ny klient'
        set(handles.nameText,'Enable','On');
        set(handles.numberText,'Enable','On');
        set(handles.dateText,'Enable','On');
        set(handles.testerText,'Enable','On');
        set(handles.nameField,'Enable','On');
        set(handles.numberField,'Enable','On');
        set(handles.dateField,'Enable','On');
        set(handles.testerField,'Enable','On');
        enableTestTypes(handles);
        
        % Initialisations:
        c.sentScored = 0;
        c.sentNum = 0;
        c.selectedList = ' ';
        c.selectedTestType = ' ';
        c.srtCount = 0; % counts the number of SRTs to report for the current client
        dr.sentScores = cell(21,4);
        lev.noiseRecom = lev.noiseStandard;
        set(handles.recomLevelField, 'String', num2str(lev.noiseRecom));
        set(handles.channel_coloc_RB, 'Value', 1);
        c.channel = 'coloc';
        enableChannelSelect(handles);
        
        dr.clientRecord = cell(25,4);
        dr.clientRecord{1,1} = 'Dansk HINT resultatoversigt';
        dr.clientRecord{3,1} = 'Klientnavn:';
        dr.clientRecord{5,1} = 'Klient/journalnr.:';
        dr.clientRecord{7,1} = 'Testdato:';
        dr.clientRecord{9,1} = 'Testansvarlig:';
        dr.clientRecord{11,1} = 'SRT-målinger:';
        dr.clientRecord{11,2} = 'Liste (kanal)';
        dr.clientRecord{11,3} = 'SRT';
        dr.clientRecord{11,4} = 'Støj';
        
        set(handles.nameField, 'String', '');
        set(handles.numberField, 'String', '');
        set(handles.recomLevelField, 'Visible','Off');
        set(handles.standardLevelRB, 'Value', 0);
        set(handles.recomLevelRB, 'Value', 0);
        set(handles.correctCB,'Value',0);
        set(handles.incorrectCB,'Value',0);
        
        set(hObject, 'String','Afslut klient');
        
    case 'Afslut klient'
        set(handles.nameText,'Enable','Off');
        set(handles.numberText,'Enable','Off');
        set(handles.dateText,'Enable','Off');
        set(handles.testerText,'Enable','Off');
        set(handles.nameField,'Enable','Off');
        set(handles.numberField,'Enable','Off');
        set(handles.dateField,'Enable','Off');
        set(handles.testerField,'Enable','Off');
        
        removeTestTypes(handles);
        disableTestTypes(handles);
        disableTrainLists(handles);
        removeTrainSelection(handles);
        disableTestLists(handles);
        removeTestSelection(handles);
        disableChannelSelect(handles);
        set(handles.noiseLevelText,'Visible','Off');
        set(handles.SRTtext,'Visible','Off');
        set(handles.playSentencePB, 'Enable', 'Off');
        set(handles.correctCB, 'Enable', 'Off');
        set(handles.incorrectCB, 'Enable', 'Off');
        set(handles.acceptPB, 'Enable', 'Off');
        set(handles.startPB, 'Enable', 'Off');
        set(handles.standardLevelRB, 'Enable', 'Off');
        set(handles.recomLevelRB, 'Enable', 'Off');
        set(handles.recomLevelField, 'Enable', 'Off');
        set(hObject, 'String','Ny klient');
        
        % Reset the plot figure:
        hold off;
        plot(handles.testProgressFig,1,1);
        set(handles.testProgressFig, 'XLim',[0 21], 'YLim',[55 75]);
        % set(handles.testProgressFig,'YDir','reverse');
        set(handles.testProgressFig, 'XTick', 1:20, 'YTick',50:2:100,'XGrid','on','YGrid','on');
        xlabel(handles.testProgressFig,'Sætningsnummer','fontsize',12);
        ylabel(handles.testProgressFig,'Niveau [dB]','fontsize',12);
        title(handles.testProgressFig,'Testforløb                                                      ','fontsize',14,'fontweight','bold');
        
        if c.srtCount > 0 % SRT(s) have been determined for this client
            clientRecord = dr.clientRecord;
            
            fileName = [num2str(dr.clientNumber) '_' dr.date '.mat'];
            file = [fl.recordDir '\' fileName];
            n = 0;
            while  exist(file,'file') == 2
                n = n + 1;
                file = [fl.recordDir '\' num2str(dr.clientNumber) '_' dr.date '_' num2str(n) '.mat'];
            end
            save(file, 'clientRecord');
            
            mkdir(fl.publicDir , num2str(dr.clientNumber));
            if n > 0
                file = [fl.publicDir '\' num2str(dr.clientNumber) '\' dr.clientName '_' dr.date '_' num2str(n) '.txt'];
            else
                file = [fl.publicDir '\' num2str(dr.clientNumber) '\' dr.clientName '_' dr.date '.txt'];
            end
            printClientRecord(file,clientRecord);
        end
end

% --- Executes on button press in playSentencePB.
function playSentencePB_Callback(~, ~, handles)
% hObject    handle to playSentencePB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c;

if strcmp(c.settings.progressTrigger,'accept') % press on 'Godkend' plays the next sentence
    set(handles.playSentencePB, 'Visible', 'off');
end

playSentence(handles);

% --- Executes on button press in correctCB.
function correctCB_Callback(~, ~, handles)
% hObject    handle to correctCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of correctCB

set(handles.incorrectCB,'Value',0);
set(handles.acceptPB,'Enable','On');

% --- Executes on button press in incorrectCB.
function incorrectCB_Callback(~, ~, handles)
% hObject    handle to incorrectCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of incorrectCB

set(handles.correctCB,'Value',0);
set(handles.acceptPB,'Enable','On');

% --- Executes on button press in acceptPB.
function acceptPB_Callback(hObject, ~, handles)
% hObject    handle to acceptPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acceptPB

global c;
global tm;

if strcmp(c.settings.progressTrigger,'play') % press on 'Afspil' is required to play the next sentence
    if strcmp(get(hObject, 'String'),'Godkend')  % user accepts the score
        if c.sentNum < c.lastSentNum
            set(handles.playSentencePB,'Enable','On');
        else
            set(handles.startPB, 'Enable','On');
            if strcmp(c.settings.noisePlay,'continuous')
                stop(tm.noiseObj); % last sentence has been scored
            end
        end
        set(hObject, 'String','Fortryd');
        set(handles.correctCB,'Enable','Off');
        set(handles.incorrectCB,'Enable','Off');
        c.sentScored = 1;
    else % user regrets the score
        if c.sentNum == c.lastSentNum
            set(handles.startPB, 'Enable','Off');
        end
        set(hObject, 'String','Godkend');
        set(handles.correctCB,'Enable','On');
        set(hObject, 'String','Godkend');
        set(handles.incorrectCB,'Enable','On');
        set(handles.playSentencePB,'Enable','Off');
        c.sentScored = 0;
    end
else % press on 'Godkend' plays the next sentence
    set(hObject, 'Enable','Off');
    set(handles.correctCB,'Enable','Off');
    set(handles.incorrectCB,'Enable','Off');
    c.sentScored = 1;
    if c.sentNum < c.lastSentNum
        playSentence(handles); % next sentence is played right away
    else
        set(handles.startPB, 'Enable','On');
        if strcmp(c.settings.noisePlay,'continuous') && ~strcmp(c.selectedTestType,'Training in silence')
            stop(tm.noiseObj); % last sentence has been scored
        end
    end
end

function alignWordTextBoxes(handles, sNumber, adjustPos)
% Align the alternative word responses with the left boundary of the
% sentence text box. Word 1 is already aligned.
leftReference = get(handles.sentenceText, 'Position');
wordXpos = leftReference(1) -1;%+ adjustPos;

wordOffset = determineOffset(handles, sNumber);

% word 1 positions:
wordPos = get(handles.wordText11, 'Position');
wordPos(1) = leftReference(1);
set(handles.wordText11, 'Position', wordPos);

wordPos = get(handles.wordText12, 'Position');
wordPos(1) = leftReference(1);
set(handles.wordText12, 'Position', wordPos);

wordPos = get(handles.wordText13, 'Position');
wordPos(1) = leftReference(1);
set(handles.wordText13, 'Position', wordPos);

% word 2 positions:
wordPos = get(handles.wordText21, 'Position');
wordPos(1) = wordXpos + wordOffset(2);
set(handles.wordText21, 'Position', wordPos);

wordPos = get(handles.wordText22, 'Position');
wordPos(1) = wordXpos + wordOffset(2);
set(handles.wordText22, 'Position', wordPos);

wordPos = get(handles.wordText23, 'Position');
wordPos(1) = wordXpos + wordOffset(2);
set(handles.wordText23, 'Position', wordPos);

% word 3 positions:
wordPos = get(handles.wordText31, 'Position');
wordPos(1) = wordXpos + wordOffset(3);
set(handles.wordText31, 'Position', wordPos);

wordPos = get(handles.wordText32, 'Position');
wordPos(1) = wordXpos + wordOffset(3);
set(handles.wordText32, 'Position', wordPos);

wordPos = get(handles.wordText33, 'Position');
wordPos(1) = wordXpos + wordOffset(3);
set(handles.wordText33, 'Position', wordPos);

% word 4 positions:
wordPos = get(handles.wordText41, 'Position');
wordPos(1) = wordXpos + wordOffset(4);
set(handles.wordText41, 'Position', wordPos);

wordPos = get(handles.wordText42, 'Position');
wordPos(1) = wordXpos + wordOffset(4);
set(handles.wordText42, 'Position', wordPos);

wordPos = get(handles.wordText43, 'Position');
wordPos(1) = wordXpos + wordOffset(4);
set(handles.wordText43, 'Position', wordPos);

% word 5 positions:
wordPos = get(handles.wordText51, 'Position');
wordPos(1) = wordXpos + wordOffset(5);
set(handles.wordText51, 'Position', wordPos);

wordPos = get(handles.wordText52, 'Position');
wordPos(1) = wordXpos + wordOffset(5);
set(handles.wordText52, 'Position', wordPos);

wordPos = get(handles.wordText53, 'Position');
wordPos(1) = wordXpos + wordOffset(5);
set(handles.wordText53, 'Position', wordPos);

function wordOffset = determineOffset(handles, sNumber)
% Determines the offset of the words in the sentences. The offsets refer
% to the text box with handle 'sentenceText'. The offset is equal to 0 at the
% left boundary.
global tm;

wordOffset = zeros(1,5);

% Index of the spaces in the sentence string:
spaceI = find(isspace(tm.text{sNumber,1}) == 1);

% Determine the extent of the 'subsentences' from the sentence beginning to
% to the beginning of each word:
for n = 1:4
    set(handles.sentenceText, 'String', tm.text{sNumber,1}(1:spaceI(n)), ...
        'Visible', 'Off');
    textExtent = get(handles.sentenceText,'Extent');
    wordOffset(n+1) = textExtent(3);
end

function writeAltWords(handles, sNumber)
% Writes the word alternatives under each of the five words of the test
% sentence
global tm;
global c;
order = 1:3;
for w = 1:5
    if ~isempty(tm.text{sNumber,w+1})
        altList = tm.text{sNumber,w+1};
        altWords = regexp(altList,', ','split');
        if strcmp(c.wordOrdered, 'y')
            [~, order] = sort(cellfun('size',altWords,2));
        end
        switch w
            case 1
                if ~isempty(altWords)
                    set(handles.wordText11, 'String', altWords{order(1)});
                    textExtent = get(handles.wordText11,'Extent');
                    boxPos = get(handles.wordText11, 'Position');
                    boxPos(3) = textExtent(3);
                    set(handles.wordText11, 'Position', boxPos, 'Visible', 'On');
                    
                    if length(altWords) > 1
                        set(handles.wordText12, 'String', altWords{order(2)});
                        textExtent = get(handles.wordText12,'Extent');
                        boxPos = get(handles.wordText12, 'Position');
                        boxPos(3) = textExtent(3);
                        set(handles.wordText12, 'Position', boxPos, 'Visible', 'On');
                        
                        if length(altWords) > 2
                            set(handles.wordText13, 'String', altWords{order(3)});
                            textExtent = get(handles.wordText13,'Extent');
                            boxPos = get(handles.wordText13, 'Position');
                            boxPos(3) = textExtent(3);
                            set(handles.wordText13, 'Position', boxPos, 'Visible', 'On');
                        end
                    end
                end
            case 2
                if ~isempty(altWords)
                    set(handles.wordText21, 'String', altWords{order(1)});
                    textExtent = get(handles.wordText21,'Extent');
                    boxPos = get(handles.wordText21, 'Position');
                    boxPos(3) = textExtent(3);
                    set(handles.wordText21, 'Position', boxPos, 'Visible', 'On');
                    
                    if length(altWords) > 1
                        set(handles.wordText22, 'String', altWords{order(2)});
                        textExtent = get(handles.wordText22,'Extent');
                        boxPos = get(handles.wordText22, 'Position');
                        boxPos(3) = textExtent(3);
                        set(handles.wordText22, 'Position', boxPos, 'Visible', 'On');
                        
                        if length(altWords) > 2
                            set(handles.wordText23, 'String', altWords{order(3)});
                            textExtent = get(handles.wordText23,'Extent');
                            boxPos = get(handles.wordText23, 'Position');
                            boxPos(3) = textExtent(3);
                            set(handles.wordText23, 'Position', boxPos, 'Visible', 'On');
                        end
                    end
                end
            case 3
                if ~isempty(altWords)
                    set(handles.wordText31, 'String', altWords{order(1)});
                    textExtent = get(handles.wordText31,'Extent');
                    boxPos = get(handles.wordText31, 'Position');
                    boxPos(3) = textExtent(3);
                    set(handles.wordText31, 'Position', boxPos, 'Visible', 'On');
                    
                    if length(altWords) > 1
                        set(handles.wordText32, 'String', altWords{order(2)});
                        textExtent = get(handles.wordText32,'Extent');
                        boxPos = get(handles.wordText32, 'Position');
                        boxPos(3) = textExtent(3);
                        set(handles.wordText32, 'Position', boxPos, 'Visible', 'On');
                        
                        if length(altWords) > 2
                            set(handles.wordText33, 'String', altWords{order(3)});
                            textExtent = get(handles.wordText33,'Extent');
                            boxPos = get(handles.wordText33, 'Position');
                            boxPos(3) = textExtent(3);
                            set(handles.wordText33, 'Position', boxPos, 'Visible', 'On');
                        end
                    end
                end
            case 4
                if ~isempty(altWords)
                    set(handles.wordText41, 'String', altWords{order(1)});
                    textExtent = get(handles.wordText41,'Extent');
                    boxPos = get(handles.wordText41, 'Position');
                    boxPos(3) = textExtent(3);
                    set(handles.wordText41, 'Position', boxPos, 'Visible', 'On');
                    
                    if length(altWords) > 1
                        set(handles.wordText42, 'String', altWords{order(2)});
                        textExtent = get(handles.wordText42,'Extent');
                        boxPos = get(handles.wordText42, 'Position');
                        boxPos(3) = textExtent(3);
                        set(handles.wordText42, 'Position', boxPos, 'Visible', 'On');
                        
                        if length(altWords) > 2
                            set(handles.wordText43, 'String', altWords{order(3)});
                            textExtent = get(handles.wordText43,'Extent');
                            boxPos = get(handles.wordText43, 'Position');
                            boxPos(3) = textExtent(3);
                            set(handles.wordText43, 'Position', boxPos, 'Visible', 'On');
                        end
                    end
                end
            case 5
                if ~isempty(altWords)
                    set(handles.wordText51, 'String', altWords{order(1)});
                    textExtent = get(handles.wordText51,'Extent');
                    boxPos = get(handles.wordText51, 'Position');
                    boxPos(3) = textExtent(3);
                    set(handles.wordText51, 'Position', boxPos, 'Visible', 'On');
                    
                    if length(altWords) > 1
                        set(handles.wordText52, 'String', altWords{order(2)});
                        textExtent = get(handles.wordText52,'Extent');
                        boxPos = get(handles.wordText52, 'Position');
                        boxPos(3) = textExtent(3);
                        set(handles.wordText52, 'Position', boxPos, 'Visible', 'On');
                        
                        if length(altWords) > 2
                            set(handles.wordText53, 'String', altWords{order(3)});
                            textExtent = get(handles.wordText53,'Extent');
                            boxPos = get(handles.wordText53, 'Position');
                            boxPos(3) = textExtent(3);
                            set(handles.wordText53, 'Position', boxPos, 'Visible', 'On');
                        end
                    end
                end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for enabling, disabling, and deselecting radiobuttons %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableTrainLists(handles)
set(handles.trainListRB1, 'Enable', 'on');
set(handles.trainListRB2, 'Enable', 'on');
set(handles.trainListRB3, 'Enable', 'on');

function removeTrainSelection(handles)
set(handles.trainListRB1, 'Value',0);
set(handles.trainListRB2, 'Value',0);
set(handles.trainListRB3, 'Value',0);

function disableTrainLists(handles)
set(handles.trainListRB1, 'Enable', 'off');
set(handles.trainListRB2, 'Enable', 'off');
set(handles.trainListRB3, 'Enable', 'off');

function enableTestLists(handles)
set(handles.testListRB1, 'Enable', 'on');
set(handles.testListRB2, 'Enable', 'on');
set(handles.testListRB3, 'Enable', 'on');
set(handles.testListRB4, 'Enable', 'on');
set(handles.testListRB5, 'Enable', 'on');
set(handles.testListRB6, 'Enable', 'on');
set(handles.testListRB7, 'Enable', 'on');
set(handles.testListRB8, 'Enable', 'on');
set(handles.testListRB9, 'Enable', 'on');
set(handles.testListRB10, 'Enable', 'on');

function disableTestLists(handles)
set(handles.testListRB1, 'Enable', 'off');
set(handles.testListRB2, 'Enable', 'off');
set(handles.testListRB3, 'Enable', 'off');
set(handles.testListRB4, 'Enable', 'off');
set(handles.testListRB5, 'Enable', 'off');
set(handles.testListRB6, 'Enable', 'off');
set(handles.testListRB7, 'Enable', 'off');
set(handles.testListRB8, 'Enable', 'off');
set(handles.testListRB9, 'Enable', 'off');
set(handles.testListRB10, 'Enable', 'off');
%
function removeTestSelection(handles)
set(handles.testListRB1,'Value',0);
set(handles.testListRB2,'Value',0);
set(handles.testListRB3,'Value',0);
set(handles.testListRB4,'Value',0);
set(handles.testListRB5,'Value',0);
set(handles.testListRB6,'Value',0);
set(handles.testListRB7,'Value',0);
set(handles.testListRB8,'Value',0);
set(handles.testListRB9,'Value',0);
set(handles.testListRB10,'Value',0);

function enableTestTypes(handles)
set(handles.trainSilenceRB, 'Enable', 'on');
set(handles.determineNoiseText, 'Enable', 'on');
set(handles.trainNoiseRB, 'Enable', 'on');
set(handles.testNoiseRB, 'Enable', 'on');

function disableTestTypes(handles)
set(handles.trainSilenceRB, 'Enable', 'off');
set(handles.determineNoiseText, 'Enable', 'off');
set(handles.trainNoiseRB, 'Enable', 'off');
set(handles.testNoiseRB, 'Enable', 'off');

function removeTestTypes(handles)
set(handles.trainSilenceRB, 'Value', 0);
set(handles.trainNoiseRB, 'Value', 0);
set(handles.testNoiseRB, 'Value', 0);

function removeAltWords(handles)
set(handles.wordText11, 'Visible', 'Off');
set(handles.wordText12, 'Visible', 'Off');
set(handles.wordText13, 'Visible', 'Off');

set(handles.wordText21, 'Visible', 'Off');
set(handles.wordText22, 'Visible', 'Off');
set(handles.wordText23, 'Visible', 'Off');

set(handles.wordText31, 'Visible', 'Off');
set(handles.wordText32, 'Visible', 'Off');
set(handles.wordText33, 'Visible', 'Off');

set(handles.wordText41, 'Visible', 'Off');
set(handles.wordText42, 'Visible', 'Off');
set(handles.wordText43, 'Visible', 'Off');

set(handles.wordText51, 'Visible', 'Off');
set(handles.wordText52, 'Visible', 'Off');
set(handles.wordText53, 'Visible', 'Off');

function setAltWordColors(handles, backgroundColor, textColor)
set(handles.wordText11,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText12,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText13,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);

set(handles.wordText21,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText22,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText23,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);

set(handles.wordText31,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText32,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText33,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);

set(handles.wordText41,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText42,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText43,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);

set(handles.wordText51,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText52,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);
set(handles.wordText53,'BackgroundColor',backgroundColor, 'ForegroundColor', textColor);

function enableChannelSelect(handles)
set(handles.channel_sep_RB, 'Enable', 'on');
set(handles.channel_coloc_RB, 'Enable', 'on');
set(handles.channelText, 'Enable', 'on');

function disableChannelSelect(handles)
set(handles.channel_sep_RB, 'Enable', 'off');
set(handles.channel_coloc_RB, 'Enable', 'off');
set(handles.channelText, 'Enable', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes when selected object is changed in testListGroup.
function testListGroup_SelectionChangeFcn(hObject, ~, handles)
% hObject    handle to the selected object in testListGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global c;

set(handles.startPB,'Enable','On');
switch hObject
    case handles.testListRB1
        c.selectedList = 'test 1';
        c.sentID = randperm(20);
        
    case handles.testListRB2
        c.selectedList = 'test 2';
        c.sentID = randperm(20) + 20;
        
    case handles.testListRB3
        c.selectedList = 'test 3';
        c.sentID = randperm(20) + 40;
        
    case handles.testListRB4
        c.selectedList = 'test 4';
        c.sentID = randperm(20) + 60;
        
    case handles.testListRB5
        c.selectedList = 'test 5';
        c.sentID = randperm(20) + 80;
        
    case handles.testListRB6
        c.selectedList = 'test 6';
        c.sentID = randperm(20) + 100;
        
    case handles.testListRB7
        c.selectedList = 'test 7';
        c.sentID = randperm(20) + 120;
        
    case handles.testListRB8
        c.selectedList = 'test 8';
        c.sentID = randperm(20) + 140;
        
    case handles.testListRB9
        c.selectedList = 'test 9';
        c.sentID = randperm(20) + 160;
        
    case handles.testListRB10
        c.selectedList = 'test 10';
        c.sentID = randperm(20) + 180;
end

% --- Executes when selected object is changed in noiseLevelGroup.
function noiseLevelGroup_SelectionChangeFcn(hObject, ~, handles)
% hObject    handle to the selected object in noiseLevelGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global lev;
global c;

switch hObject
    case handles.standardLevelRB
        lev.noise = lev.noiseStandard;
        set(handles.recomLevelField, 'Visible', 'Off');
        
    case handles.recomLevelRB
        set(handles.recomLevelField, 'Enable','On', 'Visible', 'On');
        lev.noise = str2double(get(handles.recomLevelField,'String'));
end

% --- Executes when selected object is changed in trainingListGroup.
function trainingListGroup_SelectionChangeFcn(hObject, ~, handles)
% hObject    handle to the selected object in trainingListGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global c;

set(handles.startPB,'Enable','On');
switch hObject
    case handles.trainListRB1
        c.selectedList = 'træn 1';
        c.sentID = randperm(20);
        
    case handles.trainListRB2
        c.selectedList = 'træn 2';
        c.sentID = randperm(20) + 20;
        
    case handles.trainListRB3
        c.selectedList = 'træn 3';
        c.sentID = randperm(20) + 40;
        
end

function setControlPanelColor(handles, panelColor)
set(handles.nameText,'BackgroundColor',panelColor);
set(handles.numberText,'BackgroundColor',panelColor);
set(handles.dateText,'BackgroundColor',panelColor);
set(handles.testerText,'BackgroundColor',panelColor);

set(handles.testTypeGroup,'BackgroundColor',panelColor);
set(handles.trainSilenceRB,'BackgroundColor',panelColor);
set(handles.determineNoiseText,'BackgroundColor',panelColor);
set(handles.trainNoiseRB,'BackgroundColor',panelColor);
set(handles.testNoiseRB,'BackgroundColor',panelColor);

set(handles.trainingListGroup,'BackgroundColor',panelColor);
set(handles.trainListRB1,'BackgroundColor',panelColor);
set(handles.trainListRB2,'BackgroundColor',panelColor);
set(handles.trainListRB3,'BackgroundColor',panelColor);

set(handles.testListGroup,'BackgroundColor',panelColor);
set(handles.testListRB1,'BackgroundColor',panelColor);
set(handles.testListRB2,'BackgroundColor',panelColor);
set(handles.testListRB3,'BackgroundColor',panelColor);
set(handles.testListRB4,'BackgroundColor',panelColor);
set(handles.testListRB5,'BackgroundColor',panelColor);
set(handles.testListRB6,'BackgroundColor',panelColor);
set(handles.testListRB7,'BackgroundColor',panelColor);
set(handles.testListRB8,'BackgroundColor',panelColor);
set(handles.testListRB9,'BackgroundColor',panelColor);
set(handles.testListRB10,'BackgroundColor',panelColor);

set(handles.noiseLevelGroup,'BackgroundColor',panelColor);
set(handles.standardLevelRB,'BackgroundColor',panelColor);
set(handles.recomLevelRB,'BackgroundColor',panelColor);

function setRunPanelColor(handles, panelColor)
set(handles.sentenceText,'BackgroundColor',panelColor);

set(handles.scorePanel,'BackgroundColor',panelColor);
set(handles.correctCB,'BackgroundColor',panelColor);
set(handles.incorrectCB,'BackgroundColor',panelColor);

set(handles.resultPanel,'BackgroundColor',panelColor);
set(handles.SRTtext,'BackgroundColor',panelColor);
set(handles.noiseLevelText,'BackgroundColor',panelColor);


function printClientRecord(filename,clientRecord)
fid = fopen(filename, 'w');
nrows = 25;
for row=1:10
    fprintf(fid, '%*s', 18, clientRecord{row,1});
    fprintf(fid, '%*s \n', length(clientRecord{row,2})+2, clientRecord{row,2});
end

for row=11:nrows
    fprintf(fid, '%*s', 18, clientRecord{row,1});
    fprintf(fid, '%*s', 15, clientRecord{row,2});
    fprintf(fid,'%*s', 10, clientRecord{row,3});
    fprintf(fid,'%*s \n', 8, clientRecord{row,4});
end
fclose(fid);


% --- Executes on button press in settingsPB.
function settingsPB_Callback(~, ~, handles)
% hObject    handle to settingsPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenColor = get(handles.HINTscreen,'Color');
h = figure(indstilVer4);
set(h,'Color', screenColor);

% --- Executes when selected object is changed in channelGroup.
function channelGroup_SelectionChangeFcn(hObject, ~, handles)
% hObject    handle to the selected object in channelGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global c;

switch hObject
    case handles.channel_sep_RB
        c.channel = 'sep';
        
    case handles.channel_coloc_RB
        c.channel = 'coloc';       
end



function playSentence(handles)
% Play the next sentence and execute related tasks.
global fl;
global c;
global tm;
global lev;
global dr;

removeAltWords(handles);

% sentNum is currently equal to the sentence number for the previous
% sentence.
if c.sentNum > 0
    %Record the score and speech level:
    dr.sentScores{c.sentNum,1} = c.sentID(c.sentNum); % sentence number in list
    dr.sentScores{c.sentNum,2} = tm.text{c.sentID(c.sentNum),1}; % sentence text
    dr.sentScores{c.sentNum,3} = get(handles.correctCB,'Value'); % sentence score
    dr.sentScores{c.sentNum,4} = lev.speech; % sentence level
    
    % Level adjustment for the sentence to play now:
    if strcmp(c.settings.procedure,'standard') % the standard HINT procedure is used
        switch c.sentNum
            case 1
                switch dr.sentScores{c.sentNum,3}
                    case 0
                        lev.speech = lev.speech + 4;
                        c.sentNum = 0; % The first sentence will be replayed
                    case 1
                        lev.speech = lev.speech - 4;
                end
                
            case {2, 3}
                switch dr.sentScores{c.sentNum,3}
                    case 0
                        lev.speech = lev.speech + 4;
                    case 1
                        lev.speech = lev.speech - 4;
                end
                
            case 4
                switch dr.sentScores{c.sentNum,3}
                    case 0
                        lev.speech = (sum(cell2mat(dr.sentScores(1:4,4))) + lev.speech+4)/5;
                    case 1
                        lev.speech = (sum(cell2mat(dr.sentScores(1:4,4))) + lev.speech-4)/5;
                end
                
            case {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
                switch dr.sentScores{c.sentNum,3}
                    case 0
                        lev.speech = lev.speech + 2;
                    case 1
                        lev.speech = lev.speech - 2;
                end
        end
        
    else % the maximum-likelihood procedure is used
        switch c.sentNum
            case 1
                switch dr.sentScores{c.sentNum,3}
                    case 0
                        lev.speech = lev.speech + 4;
                        c.sentNum = 0; % The first sentence will be replayed
                    case 1
                        lev.mlSNR(2) = lev.speech - lev.noise; % the final SNR for sentence one (correct response)
                        lev.speech = lev.speech - 4;
                        lev.mlSNR(1) = lev.speech - lev.noise ; % SNR where an incorrect response is assumed
                        
                        % probabilities of an incorrect response at the lower limit:
                        c.responseProp(1,:) = 1 - PsyFcn(lev.mlSNR(1),c.hypoPI(:),c.sigma);
                        c.cumulatProp(1,:) = prod(c.responseProp(1,:),1);
                        [c.maxProp(1),c.MLEofPI(1)] = max(c.cumulatProp(1,:));
                        
                        % probabilities of a correct response at the upper interval limit:
                        c.responseProp(2,:) = PsyFcn(lev.mlSNR(2),c.hypoPI(:),c.sigma);
                        c.cumulatProp(2,:) = prod(c.responseProp(1:2,:),1);
                        [c.maxProp(2),c.MLEofPI(2)] = max(c.cumulatProp(2,:));
                        lev.mlSNR(3) = c.hypoPI(c.MLEofPI(2)); % this is the SNR for sentence 2
                        lev.speech = lev.mlSNR(3) + lev.noise;                     
                end
                
            case {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}
                switch dr.sentScores{c.sentNum,3}
                    case 0
                         c.responseProp(c.sentNum+1,:) = 1 - PsyFcn(lev.mlSNR(c.sentNum+1),c.hypoPI(:),c.sigma);
                    case 1
                         c.responseProp(c.sentNum+1,:) = PsyFcn(lev.mlSNR(c.sentNum+1),c.hypoPI(:),c.sigma);
                end
                c.cumulatProp(c.sentNum+1,:) = prod(c.responseProp(1:c.sentNum+1,:),1);
                [c.maxProp(c.sentNum+1),c.MLEofPI(c.sentNum+1)] = max(c.cumulatProp(c.sentNum+1,:));
                % the 50% point on the chosen PI function will be the next presentation level:
                lev.mlSNR(c.sentNum+2) = c.hypoPI(c.MLEofPI(c.sentNum+1)); % this is the SNR for the next sentence 
                lev.speech = lev.mlSNR(c.sentNum+2) + lev.noise;
        end
    end
    
end
c.sentNum = c.sentNum + 1;

%Record the text for the sentence:
dr.sentScores{c.sentNum,2} = tm.text{c.sentID(c.sentNum),1}; % sentence text
dr.sentScores{c.sentNum,4} = lev.speech; % sentence level

% Plot speech and noise level for the sentence to play:
x = 1:c.sentNum;
plot(handles.testProgressFig, x, cell2mat(dr.sentScores(1:c.sentNum,4)),'-or');
hold on;
if ~strcmp(c.selectedTestType,'Training in silence')
    plot(handles.testProgressFig, x, ones(1,length(x))*lev.noise, '-sqb');
end
set(handles.testProgressFig, 'XLim',[0 21], ...
    'YLim',[min(min(cell2mat(dr.sentScores(1:c.sentNum,4))-1), c.plotMiddle-10) max(max(cell2mat(dr.sentScores(1:c.sentNum,4))+1), c.plotMiddle+10)], ...
    'XTick', 1:20, 'YTick',10:2:100,'XGrid','on','YGrid','on');
%set(handles.testProgressFig,'YDir','reverse');
xlabel(handles.testProgressFig,'Sætningsnummer','fontsize',12);
ylabel(handles.testProgressFig,'Niveau [dB]','fontsize',12);
if strcmp(c.selectedTestType,'Training in silence')
    legend(handles.testProgressFig,'talesignal', [470,168,100,100],'Orientation','horizontal');
else
    legend(handles.testProgressFig,'talesignal','støjsignal', [430,168,100,100],'Orientation','horizontal');
end
title(handles.testProgressFig,'Testforløb                                                      ','fontsize',14,'fontweight','bold');

alignWordTextBoxes(handles, c.sentID(c.sentNum), c.microAlign);
set(handles.sentenceText, 'String', tm.text{c.sentID(c.sentNum),1}, 'Visible', 'On');
set(handles.acceptPB, 'String','Godkend');
set(handles.playSentencePB,'Enable','Off');
set(handles.correctCB,'Value',0);
set(handles.incorrectCB,'Value',0);
set(handles.acceptPB,'Value',0);
set(handles.acceptPB,'Enable','Off');
set(handles.sentencePanel, 'Title',['Afspillet sætning (' num2str(c.sentNum) ')']);

% Read the speech signal:
filename = sprintf(fl.speechFile, c.sentID(c.sentNum));
[speechSignal,Fs] = audioread([fl.speechDir '\' filename]);
% speechSignal = [0 0 0 0 0 0 0 0]'; % OBS: the speech can be removed for faster testing
speechLength = length(speechSignal);
drawnow;

% Adjust the playback level of the speech signal:
origRMSlin = 10^(lev.sentenceFile/20);
adaptRMSlin = 10^((lev.speech-lev.calibration + lev.calibrationFile)/20);
speechSignal = speechSignal.*(adaptRMSlin/origRMSlin);
combinedSignal = speechSignal; % do not add noise
if strcmp(c.selectedTestType,'Training in silence') || strcmp(c.settings.noisePlay,'continuous')
     switch c.channel
        case 'coloc'
            tm.stimObj = audioplayer(combinedSignal, Fs);
        case 'sep'
            tm.stimObj = audioplayer([zeros(length(speechSignal),1) speechSignal], Fs);
     end
else
    % Adjust the length of the noise file. It should start before the
    % speech signal as defined by variable c.settings.noiseOnset and end 0.6 sec.
    % after. Start with a random sample:
    startSampleMax = 1e5; % max. start sample to randomly select in the noise file
    startSample = ceil(rand(1)*startSampleMax);
    Nstart = int32(c.settings.noiseOnset*Fs);
    Nfinish = int32(0.6*Fs);
    noiseToPlay = tm.noiseSignal(1+startSample:startSample+Nstart+speechLength+Nfinish,:);
    
    % Adjust the length of the speech signal:
    speechSignal = [zeros(Nstart, 1); speechSignal; zeros(Nfinish, 1)];
    
    % Adjust the playback level of the noise signal:
    inputNoiseRMSlin = sqrt(mean(noiseToPlay.^2));
    noiseLevelLin = 10^((lev.noise - lev.calibration + lev.calibrationFile)/20);
    noiseToPlay = noiseToPlay.*(noiseLevelLin/inputNoiseRMSlin);
    noiseToPlay = rampOneChan(noiseToPlay, 0.4, Fs);
    combinedSignal = speechSignal + noiseToPlay;
    switch c.channel
        case 'coloc'
            tm.stimObj = audioplayer(combinedSignal, Fs);
        case 'sep'
            tm.stimObj = audioplayer([noiseToPlay speechSignal], Fs);
    end    
end

if max(combinedSignal) > 1
    errordlg('Talesignalet er meget højt og kan blive forvrænget. Fortsætter problemet, bør udstyret kalibreres til et højere lydtryk.', 'Kalibrering','error');
end

play(tm.stimObj);

if strcmp(c.selectedTestType,'Training in silence') || strcmp(c.settings.noisePlay,'continuous')
    pause(speechLength/Fs); % delay the appearance of the alternative responses and the feedback checkboxes
else                        % until speech ends
    pause(c.settings.noiseOnset + speechLength/Fs); % delay the appearance of the alternative responses and the feedback checkboxes
end                                                 % until speech ends
set(handles.correctCB,'Enable','On');
set(handles.incorrectCB,'Enable','On');
if c.sentNum == c.lastSentNum
    set(handles.startPB, 'String','Beregn SRT','Enable','Off');
    set(handles.playSentencePB,'Visible','Off');
end
writeAltWords(handles, c.sentID(c.sentNum));

% Restart the continuous noise if there is less than one minute left:
if ~strcmp(c.selectedTestType,'Training in silence')
    if strcmp(c.settings.noisePlay,'continuous') && tm.noiseObj.isplaying % noise is continuous and playing
        if (tm.noiseObj.TotalSamples - tm.noiseObj.CurrentSample)/tm.noiseObj.SampleRate < 60
            pause(2); % delay the stop/start of the noise till two sec. after the sentence
            stop(tm.noiseObj);
            play(tm.noiseObj);
        end
    end
end
