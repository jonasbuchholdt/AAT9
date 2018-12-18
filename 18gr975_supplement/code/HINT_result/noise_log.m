clear all
close all

%% user inputs
fs = 44100;
p0 = 1;
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

for k = 1
% if k<10
% inname = strcat('../bp_noise_matching/raw/testWavFiles/HINTsentence00',int2str(k),'.wav');               % path for investigated audio
% elseif k<100 && k>9
%     inname = strcat('../bp_noise_matching/raw/testWavFiles/HINTsentence0',int2str(k),'.wav');
% elseif k>99
%     inname = strcat('../bp_noise_matching/raw/testWavFiles/HINTsentence',int2str(k),'.wav');
% end
inname = '../matching_filters/raw/daHINTnoise5min.wav';
logname = '12_10_noise.csv';                    % name for logfile
linename = int2str(k);                       % name for the line in log



%% loading stuff
[in, fs] = audioread(inname);

in = in(1:20*fs);
% caltone = audioread(calname);

%% calibration
% p0 = 0.00002;                               % reference pressure
% calpressure = p0*10^(callevel/20);          % pressure from calibrator level
% cal_rms = rms(caltone);                     % RMS of the cal. tone
% calfactor = calpressure/cal_rms;            % calibration factor
% 
% in = in.*calfactor;                         % scaling in signal to Pascal

%% filtering
clear infiltered


for h=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{h};
    infiltered(:,h) = oneThirdOctaveFilter(in);
end

%% time averaging
Leq_total = 10*log10(1/(length(in))*sum(in.^2/p0^2));
Leq_3rd = 10*log10(1/(length(infiltered))*sum(infiltered.^2/p0^2));

%% writing output
if ~(exist(logname, 'file') == 2)
    headline = {'FileDesignation','Ltotal','L20','L25','L32','L40','L50','L63','L80',...
        'L100','L125','L160','L200','L250','L315','L400','L500','L630','L800',...
        'L1k','L1k25','L1k6','L2k','L2k5','L3k15','L4k','L5k','L6k3','L8k',...
        'L10k','L12k5','L16k','L20k'};

    dlmcell(logname,headline);
end

outvec = round([Leq_total Leq_3rd],3);

outcell = num2cell(outvec);
outarray(k+1,:) = [linename, outcell];

dlmcell(logname,outarray(k+1,:),'-a');
end