
%% Calibrate the soundcard
clear all
gain = -18;
cmd = 'cali_soundcard'
Lacoustics(cmd,gain);

%% Show calibration of soundcard
clear all
gain = -18;
cmd = 'test'
[f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain);
load('calibration.mat')
transfer_function = f_result./calibration.preamp_transfer_function;
result = 20*log10(abs(transfer_function));
semilogx(f_axis,result)
hold on
grid on
axis([20 20000 -1 1])
xlabel('Frequency [Hz]')
ylabel('[dB]')
clear calibration

%% Calibrate the microphone
clear all
cmd = 'cali_mic'
gain = 0;
Lacoustics(cmd,gain);

%% Show calibration of microphone
load('calibration.mat')
calibration.mic_sensitivity
clear calibration

fs = 48000;                                 % sample rate       [Hz]
blength = 3;                                % buffer length      [s]

soundcard = audioDeviceReader(fs);          % setting up audio object
%soundcard.Driver(ASIO)                    % choosing audio driver
soundcard.SamplesPerFrame = fs/8;           % setting up framesize for
                                            % fast sound weighting
buffer = zeros(blength * fs, 1);            % initializing audio buffer
RMS = [];                                   % initializing log variable
logtable = table(RMS);                      % initilizing log table
tic;
while toc < 4
    audioin = soundcard()/calibration.mic_sensitivity;                  % fetch samples from soundcard
    buffer = [buffer(6001:end); audioin];   % update buffer
    RMS = dummy(buffer);
    logtable = [logtable; table(RMS)]
end



%% Make impulse response
clear all
cmd = 'transfer'
gain = -18;
[f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain);

result=20*log10(abs(f_result)/(20*10^-6));

figure(1)
semilogx(f_axis,result)
hold on
grid on

axis([20 20000 60 140])
xlabel('Frequency [Hz]')
ylabel('Pressure [Pa]')


%% function
function out = dummy(in)
    out = rms(in)*sqrt(2);
end