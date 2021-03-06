clear all
close all
load('LOS_only_MSM_no_noise.mat')
%load('LOS_plus4comp_MSM_no_noise.mat')


f = 5.2e9;              % carrier frequency     [Hz]
c = 3e8;                % propagation speed    [m/s]
lambda = c/f;           % wavelength             [m]

AntPos = mirrorModelParam.RxAntPosRelative;
TF = mirrorModelParam.TransferFunction;
%TF = measData.TransferFunction


ArrayRadius = 0.07518/2;
L = 8;                  % number of antennas
l = 1:L;

% Calculating Antenna Positions
AntPosCal(1,:) = ArrayRadius*(cos(2*pi*(l-1)/L));
AntPosCal(2,:) = ArrayRadius*(sin(2*pi*(l-1)/L));
AntPosCal(3,:) = zeros(1,L);


azrng = linspace(0,2*pi,180);   % azimuth search space
elrng = linspace(0,pi/2,90);   % coelevation search space


% preallocating matrices for e (impinging direction) and a (steering vectors)
erng = ones(3,length(azrng),length(elrng));
a = ones(L,length(azrng),length(elrng));

% Naive implementation for sanity checks
for u = 1:length(azrng)
    for k = 1:length(elrng)
        erng(1,u,k) = cos(azrng(u)).*sin(elrng(k));
        erng(2,u,k) = sin(azrng(u)).*sin(elrng(k));
        erng(3,u,k) = cos(elrng(k));
        for h = 1:L
            a(h,u,k) = exp(i*(2*pi/lambda)*dot(erng(:,u,k),AntPos(:,h)));
        end
    end
end



for u = 1
% Generating some noise
varn = 0.0000000001;            % variance of noise
noise = sqrt(varn/2)*(randn(size(TF,2),size(TF,1))+i*randn(size(TF,2),size(TF,1)));
TFmod = TF(:,:,u).'; %Picking one out of 50 TFs, arranging it so that rows
% correspond to sensors and columns to observation

% Calculating and printing SNR
SNR = 10*log10(mean(rms(TFmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))


TFmod = (TFmod + noise);        % adding noise and signal
Rhat = (1/size(TFmod,2)).*(TFmod*TFmod'); % generating spatial covariance matrix estimate
Rhat = (Rhat+Rhat')/2;                   % Removing imaginary components
[Vr,~] = eig(Rhat);                      % Eigenvalue Decomposition for Music

M = 1;                                   % Number of Impinging waves
Umusic = Vr(:,1:end-M-1);                % selecting U matrix for Music

fprintf('Rank of covariance matrix: %d \n',rank(Rhat))



PBartlett = ones(length(azrng),length(elrng));
PCapon = PBartlett;
PMusic = PBartlett;
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*Rhat*a(:,h,k))./(norm(a(:,h,k),2).^4);
    PCapon(h,k) = 1./(a(:,h,k)'*inv(Rhat)*a(:,h,k));
    PMusic(h,k) = 1./(a(:,h,k)'*Umusic*Umusic'*a(:,h,k));
end
end

% Finding Maxima of Spectra in search range to find DOA estimate
BartlettMax = max(PBartlett(:));
CaponMax = max(abs(PCapon(:)));
MusicMax = max(abs(PMusic(:)));
[rowb,colb] = find(PBartlett == BartlettMax);
[rowc,colc] = find(abs(PCapon) == CaponMax);
[rowm,colm] = find(abs(PMusic) == MusicMax);
PBartlett = abs(PBartlett)./abs(BartlettMax);
PCapon = abs(PCapon)./abs(CaponMax);
PMusic = abs(PMusic)./abs(MusicMax);

MaxAzB(u) = mean(rad2deg(azrng(rowb)));
MaxElB(u) = mean(rad2deg(elrng(colb)));
MaxAzC(u) = mean(rad2deg(azrng(rowc)));
MaxElC(u) = mean(rad2deg(elrng(colc)));
MaxAzM(u) = mean(rad2deg(azrng(rowm)));
MaxElM(u) = mean(rad2deg(elrng(colm)));
DesiredAz = rad2deg(mean(mirrorModelParam.thetaTxAzim(5,:,u)));
DesiredEl = rad2deg(mean(mirrorModelParam.phiRxElev(5,:,u)));
fprintf('True Az: %d Bartlett Az: %d Capon Az: %d Music Az: %d \n',round(DesiredAz),round(MaxAzB(u)),round(MaxAzC(u)),round(MaxAzM(u)))
fprintf('True El: %d Bartlett El: %d Capon El: %d Music El: %d \n',round(DesiredEl),round(MaxElB(u)),round(MaxElC(u)),round(MaxElM(u)))
end


[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));
figure()
surf(AZ',EL',10*log10(abs(PBartlett)))
title('Bartlett')
figure()
surf(AZ',EL',10*log10(abs(PCapon)))
title('Capon')
figure()
surf(AZ',EL',10*log10(abs(PMusic)))
title('MUSIC')