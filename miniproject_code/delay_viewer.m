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
avgIR = mean(IR.^2,2);                    % averaged and squared IR

LOSonly = real(squeeze(avgIR));

%% Line of Sight and Primary Reflections Simulation
clear TF IR avgIR
load('LOS_plus4comp_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(IR.^2,2);                    % averaged and squared IR

LOS4comp = real(squeeze(avgIR));

%% Without Floor and Ceiling Simulation

clear TF IR avgIR
load('fullresponse_minusfloorandceiling_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(IR.^2,2);                    % averaged and squared IR

minusfloor = real(squeeze(avgIR));

%% Full Simulation

clear TF IR avgIR
load('fullresponse_plusfloorandceiling_MSM_no_noise.mat')
TF = mirrorModelParam.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(IR.^2,2);                    % averaged and squared IR

fullsim = real(squeeze(avgIR));

%% Measurement

clear TF IR avgIR
load('measDataTrack1Rp5TxPos1To50.mat')
TF = measData.TransferFunction;

IR = ifft(TF);                            % computing Impulse Responses
avgIR = mean(IR.^2,2);                    % averaged and squared IR

meas = real(squeeze(avgIR));

%% Plots
N = 1;
figure()
semilogx(LOSonly(:,N))
hold on
semilogx(LOS4comp(:,N))
semilogx(minusfloor(:,N))
semilogx(fullsim(:,N))
semilogx(meas(:,N))
hold off
legend('Sim: LOS','Sim: primary','Sim: w/o floor/ceil','Sim: full','Measurement')

figure()
hold on
for k = 1:50
    plot(LOSonly(1:20,k))
end