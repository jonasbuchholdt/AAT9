clear all
close all
%% loading in file
[in,fs] = audioread('raw/daHINTnoise5min.wav');
% all filters 8th order Butterworth
Nin = in./max(abs(in));
audiowrite('processed/normed_reference.wav',Nin,fs);
%% Bandpass Third Octave Ctr 2k
load('thirdOc2k.mat');
[b,a] = sos2tf(SOS,G);
thirdfiltered = filter(b,a,in);
Nthird = thirdfiltered./max(abs(thirdfiltered));
audiowrite('processed/thirdOc2k.wav',Nthird,fs);
%% Bandpass 1k to 4k
clear SOS G
load('BP1k4k.mat');
[b,a] = sos2tf(SOS,G);
BP1k4k = filter(b,a,in);
NBP1k4k = BP1k4k./max(abs(BP1k4k));
audiowrite('processed/BP1k4k.wav',NBP1k4k,fs);
%% Bandpass 1k to 2k
clear SOS G
load('BP1k2k.mat');
[b,a] = sos2tf(SOS,G);
BP1k2k = filter(b,a,in);
NBP1k2k = BP1k2k./max(abs(BP1k2k));
audiowrite('processed/BP1k2k.wav',NBP1k2k,fs);
%% Highpass 400
clear SOS G
load('HP400.mat');
[b,a] = sos2tf(SOS,G);
HP400 = filter(b,a,in);
NHP400 = HP400./max(abs(HP400));
audiowrite('processed/HP400.wav',NHP400,fs);
%%
plot(20*log10(abs(fft(in))))
hold on

plot(20*log10(abs(fft(NHP400))))
plot(20*log10(abs(fft(NBP1k4k))))
plot(20*log10(abs(fft(NBP1k2k))))
plot(20*log10(abs(fft(Nthird))))