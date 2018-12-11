clear all
close all

%% user inputs
inname = 'audio/bg_A.wav';               % path for investigated audio
calname = 'audio/cal_A.wav';              % path of calibration tone
logname = '11_09_transmission_loss.csv';                    % name for logfile
linename = 'Bkg_A';                       % name for the line in log

callevel = 94;                              % level of the calibrator


%% loading stuff
[in, fs] = audioread(inname);
caltone = audioread(calname);

%% calibration
p0 = 0.00002;                               % reference pressure
calpressure = p0*10^(callevel/20);          % pressure from calibrator level
cal_rms = rms(caltone);                     % RMS of the cal. tone
calfactor = calpressure/cal_rms;            % calibration factor

in = in.*calfactor;                         % scaling in signal to Pascal

%% filtering
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
    infiltered(:,k) = oneThirdOctaveFilter(in);
end

%% time averaging
Leq_total = 10*log10(1/(length(in))*trapz(in.^2/p0^2));
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

outarray = num2cell(outvec);
outarray = [linename, outarray];

dlmcell(logname,outarray,'-a');