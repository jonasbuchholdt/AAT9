clear all
close all
%load('LOS_only_MSM_no_noise.mat')
load('LOS_plus4comp_MSM_no_noise.mat')


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


azrng = linspace(-pi,pi,360);   % azimuth search space
elrng = linspace(0,pi,180);   % coelevation search space


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
IRmod = squeeze(sum(IR(1:200,:,end+1-Q:end),1));


% Calculating and printing SNR
SNR = 10*log10(mean(rms(IRmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))


IRmod = (IRmod + noise);        % adding noise and signal
Rhat = (1/size(IRmod,2)).*(IRmod*IRmod'); % generating spatial covariance matrix estimate
Rhat = (Rhat+Rhat')/2;                   % Removing imaginary components
[Vr,~] = eig(Rhat);                      % Eigenvalue Decomposition for Music

M = 5;                                   % Number of Impinging waves
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
DesiredAz = rad2deg(mean(mirrorModelParam.thetaRxAzim(3,:,end+1-Q:end),'all'));
DesiredEl = rad2deg(mean(mirrorModelParam.phiRxElev(3,:,end+1-Q:end),'all'));
CalcAz = mean(MyAngle(end+1-Q:end));
fprintf('True Az: %d Calc Az: %d Bartlett Az: %d Capon Az: %d Music Az: %d \n',round(DesiredAz), round(CalcAz), round(MaxAzB),round(MaxAzC),round(MaxAzM))
fprintf('True El: %d Bartlett El: %d Capon El: %d Music El: %d \n',round(DesiredEl), round(MaxElB),round(MaxElC),round(MaxElM))

%%
close all
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
axis tight
xlabel('Azimuth [Deg]')
ylabel('Elevation [Deg]')