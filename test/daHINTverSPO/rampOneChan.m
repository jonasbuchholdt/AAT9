function y = rampOneChan(signal, rampDuration, sampleRate);
% rampDuration is given as zero amplitude

y = rampOnOneChan(signal, rampDuration, sampleRate);
y = rampOffOneChan(y, rampDuration, sampleRate);