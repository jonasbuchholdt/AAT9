function [f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime)


switch cmd
    case 'cali_soundcard'
        calibrate(gain,offset,frequencyRange)  
     
    case 'cali_mic'
        [fs,y]=irmeas_fft_mic();            
        add = rms(y)*sqrt(2);            
        load('calibration.mat')
        %calibration.mic_sensitivity = add;
        calibration.mic_sensitivity = 0.15; 
        save('calibration.mat','calibration','-append');        

     
     case 'test'                             
        player=SynchronizedPlaybackAcquirer;    % initializing I-O via soundcard
        [fs,impulse_response,irtime,tf,faxis]=IRmeas_fft_womics(sweepTime,frequencyRange,gain,player,offset);
        t_axis = irtime;
        t_result = impulse_response;
        f_axis = faxis;
        f_result = tf;
       
    case 'transfer'                                                
        [fs,impulse_response,irtime]=IRmeas_fft(sweepTime,frequencyRange,gain,offset,inputChannel);
        f_axis = 0;
        f_result = 0;
        t_axis = irtime;
        t_result = impulse_response;
end