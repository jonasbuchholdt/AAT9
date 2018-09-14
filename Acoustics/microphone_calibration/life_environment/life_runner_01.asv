clear all

filename = 'testlog_01.xlsx';
fs = 48000;                                 % sample rate       [Hz]
blength = 3;                                % buffer length      [s]
tablelines = 8;                             % number of lines that are
                                            % buffered before writing file
TL = 0;
B= 0;
B=logical(B);

soundcard = audioDeviceReader('Driver','ASIO','SampleRate',fs,'SamplesPerFrame',2048);          % setting up audio object


buffer = zeros(blength * fs, 1);            % initializing audio buffer

RMS = [];                                   % initializing log variable

logtable = table(RMS);                      % initilizing log table



tic;

while toc < 10
    audioin = soundcard();                  % fetch samples from soundcard
    buffer = [buffer(2049:end); audioin];   % update buffer
    if B
        RMS = dummy(buffer);
        logtable = [logtable; table(RMS)];
        TL = TL + 1;
    end
    B= ~ B;
    
    if TL >= tablelines
%        writetable(logtable,filename);
        RMS=[];
        logtable = table(RMS);
        TL = 0;
    end
end

close all
plot(buffer)



function out = dummy(in)
    out = 20*log10(rms(in)/0.00002);
end