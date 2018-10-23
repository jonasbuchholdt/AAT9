function [f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange)


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
        ts= 1;                                  % length of sweep                        [s]                    [s]
        playgain=gain;                            % gain for sweep playback               [dB]
        incal=0.1;                          
        outcal=0.1;                             
        player=SynchronizedPlaybackAcquirer;    % initializing I-O via soundcard
        [fs,impulse_response,irtime,tf,faxis]=IRmeas_fft_womics(ts,frequencyRange,playgain,player,offset);
        t_axis = irtime;
        t_result = impulse_response;
        f_axis = faxis;
        f_result = tf;
       
    case 'transfer'
        ts= 20;                                  % length of sweep                        [s] 
        [fs,impulse_response,irtime]=IRmeas_fft(ts,frequencyRange,gain,offset,inputChannel);
        f_axis = 0;
        f_result = 0;
        t_axis = irtime;
        t_result = impulse_response;
end