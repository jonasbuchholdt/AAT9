clear all
close all
%load('LOS_only_MSM_no_noise.mat')
load('LOS_plus4comp_MSM_no_noise.mat')
%load 'fullresponse_minusfloorandceiling_MSM_no_noise.mat'

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




azrng = linspace(-pi,pi,180);   % azimuth search space
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




% Generating some noise
Q = 15                          % number of averaged measurements

varn = 0.0000000001;            % variance of noise
noise = sqrt(varn/2)*(randn(size(TF,2),Q)+i*randn(size(TF,2),Q));
IR = ifft(TF);                            % computing Impulse Responses
IRmod = squeeze(sum(IR(1:5,:,1:Q),1));


% Calculating and printing SNR
SNR = 10*log10(mean(rms(IRmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))


IRmod = (IRmod + noise);                 % adding noise and signal
Rhat = (1/size(IRmod,2)).*(IRmod*IRmod'); % generating spatial covariance matrix estimate
Rhat = (Rhat+Rhat')/2;                   % Removing imaginary components
[Vr,~] = eig(Rhat);                      % Eigenvalue Decomposition for Music

M = 5;                                   % Number of Impinging waves
Umusic = Vr(:,1:end-M-1);                % selecting U matrix for Music

% smoothing 


sub = ceil(3/2*M);
x_p = [];
for d=1:L-sub+1
    x_p(:,:,d) = IRmod(d:d+sub-1,:);
    R_p(:,:,d) = x_p(:,:,d)*x_p(:,:,d)';
    aSmooth(:,:,:,d)=a(d:d+sub-1,:,:); 
end
Rf = (1/(L-sub+1))*sum(R_p,3);


J = flip(eye(sub));
R_fb = (1/2).*(Rf+J*conj(Rf)*J);


[VrSmooth,~] = eig(R_fb);                      % Eigenvalue Decomposition for Music

UmusicSmooth = VrSmooth(:,1:end-M-1);                % selecting U matrix for Music

fprintf('Rank of covariance matrix: %d \n',rank(Rhat))



PBartlett = ones(length(azrng),length(elrng));
PCapon = PBartlett;
PMusic = PBartlett;
PMusicSmooth =  PMusic;
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*Rhat*a(:,h,k))./(norm(a(:,h,k),2).^4);
    PCapon(h,k) = 1./(a(:,h,k)'*inv(Rhat)*a(:,h,k));
    PMusic(h,k) = 1./(a(:,h,k)'*Umusic*Umusic'*a(:,h,k));
    for t = 1:L-sub+1
        [VrSmooth,~] = eig(R_p(:,:,d));                      % Eigenvalue Decomposition for Music
        UmusicSmooth = VrSmooth(:,1:end-M-1);                % selecting U matrix for Music
        PMusicSmooth(h,k,d) = 1./(aSmooth(:,h,k,d)'*UmusicSmooth*UmusicSmooth'*aSmooth(:,h,k,d));
    end
end
end
PMusicSmooth = mean(PMusicSmooth,3);
% Finding Maxima of Spectra in search range to find DOA estimate
BartlettMax = max(PBartlett(:));
CaponMax = max(abs(PCapon(:)));
MusicMax = max(abs(PMusic(:)));
MusicSmoothMax = max(abs(PMusicSmooth(:)));
[rowb,colb] = find(PBartlett == BartlettMax);
[rowc,colc] = find(abs(PCapon) == CaponMax);
[rowm,colm] = find(abs(PMusic) == MusicMax);
PBartlett = abs(PBartlett)./abs(BartlettMax);
PCapon = abs(PCapon)./abs(CaponMax);
PMusic = abs(PMusic)./abs(MusicMax);
PMusicSmooth = abs(PMusicSmooth)./abs(MusicSmoothMax);

for k = 1:50
    VectorThing = -mirrorModelParam.RxPos(1:2)+mirrorModelParam.TxPos(1:2,k);
    MyAngle(k) = rad2deg(angle(VectorThing(1)+i*VectorThing(2)));
end
    

MaxAzB = mean(rad2deg(azrng(rowb)));
MaxElB = 90 -mean(rad2deg(elrng(colb)));
MaxAzC = mean(rad2deg(azrng(rowc)));
MaxElC = 90 -mean(rad2deg(elrng(colc)));
MaxAzM = mean(rad2deg(azrng(rowm)));
MaxElM = 90 -mean(rad2deg(elrng(colm)));
DesiredAz = rad2deg(mean(mirrorModelParam.thetaRxAzim(3,:,1:Q),'all'));
DesiredEl = rad2deg(mean(mirrorModelParam.phiRxElev(3,:,1:Q),'all'));
CalcAz = mean(MyAngle(1:Q));
fprintf('Given Az: %d Calc Az: %d Bartlett Az: %d Capon Az: %d Music Az: %d \n',round(DesiredAz), round(CalcAz), round(MaxAzB),round(MaxAzC),round(MaxAzM))
fprintf('Given El: %d Bartlett El: %d Capon El: %d Music El: %d \n',round(DesiredEl), round(MaxElB),round(MaxElC),round(MaxElM))

%%
close all
[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));
%[AZ,EL] = meshgrid((azrng),(elrng));
figure()
% surf(AZ',EL',10*log10(abs(PBartlett)))
% title('Bartlett')
% figure()
% surf(AZ',EL',10*log10(abs(PCapon)))
% title('Capon')
figure()
surf(AZ',EL',10*log10(abs(PMusic)))
title('MUSIC')
figure()
surf(AZ',EL',10*log10(abs(PMusicSmooth)))
title('MUSIC Smooth')
axis tight
xlabel('Azimuth [Deg]')
ylabel('Elevation [Deg]')