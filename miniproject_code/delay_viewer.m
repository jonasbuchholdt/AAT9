%
% Script computes power delay profile for all parts of the supplied dataset
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars
close all

%% Line of Sight Simulation
load('LOS_only_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(abs(IR).^2,2);                    % averaged and squared IR

LOSonly = real(squeeze(avgIR));

IRshortened = IR(1:200,:,:);
truncTF = fft(IRshortened);

save('shortIRtest.mat','truncTF')

%% Line of Sight and Primary Reflections Simulation
clear TF IR avgIR
load('LOS_plus4comp_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(abs(IR).^2,2);                    % averaged and squared IR

LOS4comp = real(squeeze(avgIR));

%% Without Floor and Ceiling Simulation

clear TF IR avgIR
load('fullresponse_minusfloorandceiling_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(abs(IR).^2,2);                    % averaged and squared IR

minusfloor = real(squeeze(avgIR));

%% Full Simulation

clear TF IR avgIR
load('fullresponse_plusfloorandceiling_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(abs(IR).^2,2);                    % averaged and squared IR

fullsim = real(squeeze(avgIR));

%% Measurement

clear TF IR avgIR
load('measDataTrack1Rp5TxPos1To50.mat')
TF = measData.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(abs(IR).^2,2);                    % averaged and squared IR

meas = real(squeeze(avgIR));

% Mean

LOSonlyM = mean(LOSonly,2);
LOS4compM = mean(LOS4comp,2);
minusfloorM = mean(minusfloor,2);
fullsimM = mean(fullsim,2);
measM = mean(meas,2);

%% Plots
N = 1;
figure()
loglog(LOSonlyM(:,N))
hold on
loglog(LOS4compM(:,N))
loglog(minusfloorM(:,N))
loglog(fullsimM(:,N))
loglog(measM(:,N))
hold off
legend('Sim: LOS','Sim: primary','Sim: w/o floor/ceil','Sim: full','Measurement')
xlabel('Samples [1]')
ylabel('Average Magnitude Squared Impulse Response [1]')
    set(gca,'fontsize',14)
    grid on
    grid minor