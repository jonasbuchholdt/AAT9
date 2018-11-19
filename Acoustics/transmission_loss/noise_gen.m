clear all
close all

fs = 48000;
spf = 2048;
ngen = dsp.ColoredNoise('Color','pink','SamplesPerFrame',spf);

noiselength = 300;

noise=zeros(round(noiselength*fs/spf)*spf,1);

for k = 1:round(noiselength*fs/spf);
    noise = [noise; ngen()];
end
%% Filtering
noise = noise./max(noise);
load('Bandpass.mat')
[b,a] = sos2tf(SOS,G);
BPnoise = filter(b,a,noise); 

load('LF_atten.mat')
[b,a] = sos2tf(SOS,G);
NotBlowNoise = filter(b,a,BPnoise);

audiowrite('BPnoise.wav',BPnoise,fs);
audiowrite('NBnoise.wav',NotBlowNoise,fs);

%% Checking area
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);
for k=1:Nfc
    oneThirdOctaveFilterBank{k} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(k), 'Bandwidth', BW, 'SampleRate', fs);
end
clear oneThirdOctaveFilter


for k=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{k};
    infiltered(:,k) = oneThirdOctaveFilter(noise);
    BPfiltered(:,k) = oneThirdOctaveFilter(BPnoise);
    NBfiltered(:,k) = oneThirdOctaveFilter(NotBlowNoise);
end

Leq_3rd = 10*log10(1/(length(infiltered))*sum(infiltered.^2));
LBP = 10*log10(1/(length(infiltered))*sum(BPfiltered.^2));
NBP = 10*log10(1/(length(infiltered))*sum(NBfiltered.^2));





%% Plots
figure()
semilogx(F0,Leq_3rd,'o')
hold on
semilogx(F0,LBP,'o')
semilogx(F0,NBP,'o')










