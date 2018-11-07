clear all
close all

load('BP2.mat');
% BP2: 6th order Butter, fc 350,5000
[b,a] = sos2tf(SOS,G);
for k = 1:60
    if k < 10
        [in,fs] = audioread(strcat('raw/trainingWavFiles/trainingSent00',int2str(k),'.wav'));
        out = filter(b,a,in);
        audiowrite(strcat('processed/trainingWavFiles/trainingSent00',int2str(k),'.wav'),out,fs)
    else
        [in,fs] = audioread(strcat('raw/trainingWavFiles/trainingSent0',int2str(k),'.wav'));
        out = filter(b,a,in);
        audiowrite(strcat('processed/trainingWavFiles/trainingSent0',int2str(k),'.wav'),out,fs)
    end
    strcat('Training',int2str(k))
end

for k = 1:200
        if k < 10
        [in,fs] = audioread(strcat('raw/testWavFiles/HINTsentence00',int2str(k),'.wav'));
        out = filter(b,a,in);
        audiowrite(strcat('processed/testWavFiles/HINTsentence00',int2str(k),'.wav'),out,fs)
        elseif k>9 && k<100
        [in,fs] = audioread(strcat('raw/testWavFiles/HINTsentence0',int2str(k),'.wav'));
        out = filter(b,a,in);
        audiowrite(strcat('processed/testWavFiles/HINTsentence0',int2str(k),'.wav'),out,fs)
        else
        [in,fs] = audioread(strcat('raw/testWavFiles/HINTsentence',int2str(k),'.wav'));
        out = filter(b,a,in);
        audiowrite(strcat('processed/testWavFiles/HINTsentence',int2str(k),'.wav'),out,fs)
        end
        strcat('Test',int2str(k))
end

% [IN,faxis] = freqz(in,1,5000,fs);
% OUT = abs(freqz(out,1,5000,fs));
% 
% audiowrite('matching_noise_updated.wav',out,fs)
% semilogx(faxis,abs(IN))
% hold on
% semilogx(faxis,OUT)