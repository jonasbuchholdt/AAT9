%% Impulse response of sound card
clear all
gain = -18;
cmd = 'ir'
[x_axis,result] = Lacoustics(cmd,gain);
plot(result)

%% Calibrate the soundcard
clear all
gain = -18;
cmd = 'cali_soundcard'
Lacoustics(cmd,gain);

%% Show calibration of soundcard
load('calibration.mat')
result = 20*log10(abs(calibration.preamp_transfer_function));
semilogx(result)
hold on
grid on
axis([20 20000 0 20])
xlabel('Frequency [Hz]')
ylabel('[dB]')

%% Calibrate the microphone
clear all
cmd = 'cali_mic'
gain = 0;
[x_axis,result] = Lacoustics(cmd,gain);
load('calibration.mat')

%% Make impulse response
clear all
cmd = 'transfer'
gain = -18;
[x_axis,result] = Lacoustics(cmd,gain);
result = abs(result);
result=20*log10(result/(20*10^-6));

figure(1)
semilogx(result)
hold on
grid on

axis([20 20000 60 120])
xlabel('Frequency [Hz]')
ylabel('Pressure [Pa]')