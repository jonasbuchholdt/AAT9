clear all
calibrationfilename = '18_09_24_calibration.wav';
infilename = '18_09_24_group.wav';
outfilename = 'check_123.csv';
fs = 48000;                                 % sample rate       [Hz]
bufferSize = 6000;                          % Buffer size         []
blength = 1;                              % buffer length      [s]
tablelines = 20;                            % number of lines that are
[Nfc,oneThirdOctaveFilterBank,timefilter,timepar] = third_init(fs);                                           % buffered before writing file
TL = 1;
nr=0;                                       % number of loops runs

cal_factor = quickcal(calibrationfilename);

%soundcard = audioDeviceReader('Driver','ASIO','SampleRate',fs,'SamplesPerFrame',bufferSize);          % setting up audio object
%soundcard = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',bufferSize);          % setting up audio object
soundcard = dsp.AudioFileReader('Filename',infilename,'SamplesPerFrame',bufferSize);

buffer = zeros(blength * fs, 1);            % initializing audio buffer

%RMS = [];                                   % initializing log variables
F=zeros(1,31);
S=zeros(1,31);

headline={'Number','L_FB','L_SB','L_F20','L_F25','L_F32','L_F40','L_F50','L_F63','L_F80','L_F100','L_F125','L_F160','L_F200','L_F250','L_F315','L_F400','L_F500','L_F630',...
    'L_F800','L_F1k','L_F1k25','L_F1k6','L_F2k','L_F2k5','L_F3k15','L_F4k','L_F5k','L_F6k3','L_F8k','L_F10k','L_F12k5','L_F16k','L_F20k','L_S20','L_S25',...
    'L_S32','L_S40','L_S50','L_S63','L_S80','L_S100','L_S125','L_S160','L_S200','L_S250','L_S315','L_S400','L_S500','L_S630',...
    'L_S800','L_S1k','L_S1k25','L_S1k6','L_S2k','L_S2k5','L_S3k15','L_S4k','L_S5k','L_S6k3','L_S8k','L_S10k','L_S12k5','L_S16k','L_S20k'};
logtable = zeros(tablelines,length(headline));                      % initilizing log table

cell2csv(outfilename,headline)



while ~isDone(soundcard)
    audioin = soundcard();                  % fetch samples from soundcard
    buffer = [buffer(bufferSize+1:end); audioin];   % update buffer
    nr = nr+1                              % update number of runs counter
    if (nr > (fs*blength/bufferSize))
        %tic
        [F,S,gesF,gesS] = third_run(buffer*cal_factor,oneThirdOctaveFilterBank,timefilter,timepar);
        %times(nr)=toc;
        logtable(TL,1) = nr;
        logtable(TL,2) = round(gesF,2);
        logtable(TL,3) = round(gesS,2);
        logtable(TL,4:34) = round(F,2);
        logtable(TL,35:65) = round(S,2);
        if TL >= tablelines
            dlmwrite(outfilename,logtable,'-append');
            TL = 0;
        end
        TL = TL + 1;
    end

    

end
release(soundcard);



