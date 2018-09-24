function [out] = quickcal(filename)
audio = audioread(filename);    % importing audio file containing only calibration tone
rmsvalue = rms(audio);          % calculating rms value. expecting 94 dB = 1 Pa rms
out = 1/(rmsvalue);               % calculating factor that norms audio to digital number equals pressure in Pa