clear all
close all
[in,fs] = audioread('daHINTnoise5min.wav');
load('BP2.mat');
% BP2: 6th order Butter, fc 350,5000
[b,a] = sos2tf(SOS,G);
out = filter(b,a,in);

[IN,faxis] = freqz(in,1,5000,fs);
OUT = abs(freqz(out,1,5000,fs));

audiowrite('matching_noise_updated.wav',out,fs)
semilogx(faxis,abs(IN))
hold on
semilogx(faxis,OUT)