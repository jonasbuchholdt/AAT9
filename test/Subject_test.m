%% bone and air match, -100 is mute 

clear all

diffrence = 0;
noise = -100


gainAir = -100
gainBone = -20-diffrence/2
play(noise,gainAir,gainBone,'test_folder/sweep1.wav')

gainAir = -20+diffrence/2
gainBone = -100
play(SNR,level,noise,gainAir,gainBone,'test_folder/sweep1.wav')

%% play speech on air, -100 is mute, 0 is on. 

SNR = 0;
level = -20
diffrence = 0;

gainAir = 0
gainBone = -100

gainAir = gainAir+diffrence;


speech_number = ceil(2*rand);
speech = ['test_folder/HINTsentence',num2str(speech_number),'.wav']
play(SNR,level,gainAir,gainBone,speech)

%% play speech on bone, -100 is mute 

SNR = 12;
level = -20

gainAir = -100
gainBone = level
noise = level-SNR

gainAir = gainAir+diffrence;

speech_number = ceil(7*rand);
speech = ['test_folder/sweep',num2str(speech_number),'.wav']
play(SNR,level,noise,gainAir,gainBone,speech)

%% combined test, -100 is mute 



gainAir = -20
gainBone = -20
noise = -20

gainAir = gainAir+diffrence;

speech_number = ceil(7*rand);
speech = ['test_folder/sweep',num2str(speech_number),'.wav']
play(SNR,level,noise,gainAir,gainBone,speech)








