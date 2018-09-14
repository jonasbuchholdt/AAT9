clear all

filename = 'testlog_01.xls';
fs = 48000;                                 % sample rate       [Hz]
blength = 3;                                % buffer length      [s]

soundcard = audioDeviceReader(fs);          % setting up audio object
%soundcard.Driver('ASIO')                    % choosing audio driver
soundcard.SamplesPerFrame = fs/8;           % setting up framesize for
                                            % fast sound weighting

buffer = zeros(blength * fs, 1);            % initializing audio buffer

RMS = [];                                   % initializing log variable

logtable = table(RMS);                      % initilizing log table



tic;

while toc < 10
    audioin = soundcard();                  % fetch samples from soundcard
    buffer = [buffer(6001:end); audioin];   % update buffer
    RMS = dummy(buffer);
    logtable = [logtable; table(RMS)]
end





function out = dummy(in)
    out = 20*log10(rms(in)/0.00002);
end