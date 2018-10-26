function play(SNR,level,gainAir,gainBone,file)
%%

            %Generate the signal
            %gainlevel = -20;
            %ts = 5;
            %fs = 44100;
            %t = 0:1/fs:ts - (1/fs);
            %signal = chirp(t,20,ts,22000,'logarithmic');
            %dataOut =  signal;    
            %audiowrite("sweep.wav",dataOut,fs)
            
            
            
%             fadeInTime = 0.08;
%             fadeInSamps = ceil(fadeInTime * fs); % number of samples over which to fade in/out
%             t1 = 0:1/fadeInSamps:1-(1/fadeInSamps);
%             fadeIn = sin(1/2*pi*t1);            
%             fadeOutTime = 0.01;
%             fadeOutSamps = ceil(fadeOutTime * fs); % number of samples over which to fade in/out
%             t2 = (1-(1/fadeOutSamps):-(1/fadeOutSamps):0);
%             fadeOut = sin(1/2*pi*t2);
%             x(1:fadeInSamps) = x(1:fadeInSamps) .* fadeIn;
%             x(end-fadeOutSamps+1:end) = x(end-fadeOutSamps+1:end) .* fadeOut;
%             startSilence = ceil(fs/10);
%             endSilence = 2*fs;
%             dataOut = [zeros(startSilence,1); x'; zeros(endSilence,1);zeros(506,1)];
%  
[signal fs] = audioread(file);
p0 = 20*10^(-6);

L_Aeq_signal = 10*log10(1/(length(signal))*trapz(signal.^2/p0^2))
levelcom = L_Aeq_signal-90;

signal_offset = level-levelcom;
signal_offset_air = signal_offset+gainAir
signal_offset_bone = signal_offset+gainBone


L_Aeq_noise = 10*log10(1/(length(signal))*trapz(signal.^2/p0^2))
levelcom = L_Aeq_noise-90;

noise_offset_pre = level-levelcom;
noise_offset = noise_offset_pre-SNR


            %play the signal

L = 1024;
fileReader = dsp.AudioFileReader(file,'SamplesPerFrame',L);
fs = fileReader.SampleRate;

            

  
                     
            

   aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.                 
                          'PlayerChannelMapping',[2 3 4],... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
  
   while ~isDone(fileReader) 
         aPR([fileReader()*db2mag(noise_offset)*0.5 fileReader()*db2mag(signal_offset_air)*0.5 fileReader()*db2mag(signal_offset_bone)*0.5]);                
   end
   release(aPR);
   release(fileReader);





