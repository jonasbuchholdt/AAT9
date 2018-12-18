function [Nfc,oneThirdOctaveFilterBank,timefilter,timepar]= third_init(fs) 

tauF = 0.125*fs;
tauS = 1*fs;
BW = '1/3 octave'; 
N = 8;
F0 = 1000;

oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);
for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs);
end
alphaF = exp(-1/(tauF));
alphaS = exp(-1/tauS);
timepar.NumF = [1-alphaF;0;0];
timepar.DenF = [-alphaF;0];
timepar.NumS = [1-alphaS;0;0];
timepar.DenS = [-alphaS;0];
timefilter = dsp.BiquadFilter('SOSMatrixSource',...
                                'Input port','ScaleValuesInputPort',false);

end










