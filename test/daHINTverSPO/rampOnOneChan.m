function y = rampOnOneChan(signal, rampDuration, sampleRate);
% rampDuration is given as zero amplitude

rampDurationPoints=floor(rampDuration * sampleRate);

rampOn          = cos(3* pi/2:pi/(2* rampDurationPoints): 2*pi-pi/(2* rampDurationPoints))';
rampOn          = rampOn.^2;
rampFunction    = [rampOn; ones(length(signal)-length(rampOn),1)];

if size(signal,1) > 1
    y               = signal .* rampFunction;
else
    y               = signal .* rampFunction';
end;





