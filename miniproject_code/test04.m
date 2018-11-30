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
            a(h,u,k) = exp(i*(2*pi/lambda))*dot(erng(:,u,k),AntPos(:,h));
        end
    end
end



for u = 50
varn = 0.000001;
noise = varn*(randn(size(TF,2),size(TF,1))+i*randn(size(TF,2),size(TF,1)));
TFmod = TF(:,:,u).';

SNR = 10*log10(mean(rms(TFmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))
TFmod = (TFmod + noise);
Rhat = (1/size(TFmod,1)).*(TFmod*TFmod');
%Rhat = (1/size(rcsig,1))*(rcsig*rcsig');
fprintf('Rank of covariance matrix: %d \n',rank(Rhat))



PBartlett = ones(length(azrng),length(elrng));
PCapon = PBartlett;
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*Rhat*a(:,h,k))./(norm(a(:,h,k),2).^4);
    PCapon(h,k) = 1./(a(:,h,k)'*inv(Rhat)*a(:,h,k));
end
end
%a = exp(i*(2*pi/lambda))*(erng(:,:,1).',AntPos(:,1));
Mmax = max(PBartlett(:));
CaponMax = max(PCapon(:));
[row,col] = find(PBartlett == Mmax);
PBartlett = abs(PBartlett)./abs(Mmax);
%nPCapon = abs(PCapon)./abs(CaponMax);


MaxAz(u) = mean(rad2deg(azrng(row)));
MaxEl(u) = mean(rad2deg(azrng(col)));
DesiredAz = rad2deg(mean(mirrorModelParam.thetaRxAzim(5,:,u)));
DesiredEl = rad2deg(mean(mirrorModelParam.phiRxElev(5,:,u)));
fprintf('True Az: %d Estimated Az: %d \n',round(DesiredAz),round(MaxAz(u)))
fprintf('True El: %d Estimated El: %d \n',round(DesiredEl),round(MaxEl(u)))
end


[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));
figure()
surf(AZ',EL',10*log10(abs(PBartlett)))
figure()
surf(AZ',EL',10*log10(abs(PCapon)))