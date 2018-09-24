clear all
calibrationfilename = 'cal_flexgroup.wav';
cal_factor = quickcal(calibrationfilename);
fs = 48000;                                 % sample rate       [Hz]
tau = 0.125 * fs;
audioraw = audioread(calibrationfilename)*cal_factor;
squared = audioraw.^2;
taxis = (1:length(audioraw))./fs;
alpha = exp(-1/tau);
NumF = [1-alpha;0;0];
DenF = [-alpha;0];
weightfilter = dsp.BiquadFilter('SOSMatrixSource',...
                                'Input port','ScaleValuesInputPort',false);
%setup(weightfilter,squared,NumF,DenF);
lpfiltered = weightfilter(squared,NumF,DenF);
Lout = 10*log10(lpfiltered/0.00002^2);

close all
figure(1)
plot(taxis,audioraw)
hold on
plot(taxis,squared)
plot(taxis,lpfiltered)
figure(2)
plot(taxis,Lout)