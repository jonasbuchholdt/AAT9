function y = rampOffOneChan(signal, rampDuration, sampleRate);
% rampDuration is given as zero amplitude

rampDurationPoints	= floor(rampDuration * sampleRate);
rampOff             = cos(pi/(2* rampDurationPoints):pi/(2* rampDurationPoints): pi/2)';
rampOff             = rampOff.^2;
rampFunction		= [ones(length(signal)-length(rampOff),1); rampOff];

if size(signal,1) > 1
    y               = signal .* rampFunction;
else
    y               = signal .* rampFunction';
end;




