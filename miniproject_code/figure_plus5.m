clear all
close all
%load('LOS_only_MSM_no_noise.mat')
%load('LOS_plus4comp_MSM_no_noise.mat')
load measDataTrack1Rp5TxPos1To50.mat
load fullresponse_plusfloorandceiling_MSM_no_noise.mat
load('CalibrationMatrix.mat')

f = 5.2e9;              % carrier frequency     [Hz]
c = 3e8;                % propagation speed    [m/s]
lambda = c/f;           % wavelength             [m]

AntPos = mirrorModelParam.RxAntPosRelative;
TF = mirrorModelParam.TransferFunction;
%TF = measData.TransferFunction;


ArrayRadius = 0.07518/2;
L = 8;                  % number of antennas
l = 1:L;

% Calculating Antenna Positions
AntPosCal(1,:) = ArrayRadius*(cos(2*pi*(l-1)/L));
AntPosCal(2,:) = ArrayRadius*(sin(2*pi*(l-1)/L));
AntPosCal(3,:) = zeros(1,L);


azrng = linspace(-pi,pi,360);   % azimuth search space
elrng = linspace(0,pi/2,180);   % coelevation search space


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
        %a(:,u,k) = C*a(:,u,k);
    end
end




% Generating some noise

Q = 28;                          % number of averaged measurements
start = 50-Q;

varn = 0.000000000;            % variance of noise
noise = sqrt(varn/2)*(randn(size(TF,2),Q)+1j*randn(size(TF,2),Q));
IR = ifft(TF);                            % computing Impulse Responses
IRmod = squeeze(sum(IR(1:4,:,1+start:Q+start),1));


% Calculating and printing SNR
SNR = 10*log10(mean(rms(IRmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))


IRmod = (IRmod + noise);        % adding noise and signal
Rhat = (1/size(IRmod,2)).*(IRmod*IRmod'); % generating spatial covariance matrix estimate
Rhat = (Rhat+Rhat')/2;                   % Removing imaginary components
[Vr,eigenvalue] = eig(Rhat);                      % Eigenvalue Decomposition for Music
eigenvalue = diag(eigenvalue);

for t=1:length(eigenvalue)-1
    if eigenvalue(9-t) > eigenvalue(9-t-1)*20
        M=t;
        break
    end
end
%%
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

%------------1Wave---------
DesiredAz = mean(rad2deg(mean(mirrorModelParam.thetaRxAzim(end,:,1+start:Q+start),2)),3);
DesiredEl = mean(rad2deg(mean(mirrorModelParam.phiRxElev(end,:,1+start:Q+start),2)),3);
DesiredZ = zeros(length(DesiredAz),1);


%------------5Wave---------
% DesiredAz = mean(rad2deg(mean(mirrorModelParam.thetaRxAzim(:,:,1:Q),2)),3);
% DesiredEl = mean(rad2deg(mean(mirrorModelParam.phiRxElev(:,:,1:Q),2)),3);
% DesiredZ = zeros(length(DesiredAz),1);
%% Peak finding

%-----music----------
% PksAz=[101.8,-13.6,-139.9,-121.8,-134.9];
% PksEl=[0,4.5,5.5,5.0,5.0];
PksAz=[-130.9];
PksEl=[6.5];
PksZ =zeros(1,5);

%-----capon---------
% PksAz=[-121.8,-140.9,-12.5,105.8,-129.9];
% PksEl=[7.5,4.0,-0.5,7.5,6.5];
PksAz=[-130.9];
PksEl=[6.0];
PksZ =zeros(1,5);

%%
close all
[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));
ELsurf = 90-EL;
EL = 90-EL;
figure()
surf(AZ',ELsurf',10*log10(abs(PCapon)))
title('Capon')
axis tight
xlabel('Azimuth [Deg]')
ylabel('Elevation [Deg]')
zlabel('Normed Power [dB]')
zlim([-50 0])
shading interp
set (gca,'Xdir','reverse')
view([210 50])
set(gca,'fontsize',14)

figure()
surf(AZ',ELsurf',10*log10(abs(PMusic)))
title('MUSIC')
axis tight
xlabel('Azimuth [Deg]')
ylabel('Elevation [Deg]')
zlabel('Normed Power [dB]')
shading interp
zlim([-50 0])
set (gca,'Xdir','reverse')
view([210 50])
set(gca,'fontsize',14)

bgFig = imread('rp5a.jpg') ;
figure;
image([180 -180],[90 -90],bgFig (:,:,1:3));
hold on;
surf(AZ',EL', 10*log10(abs(PMusic))-50,'FaceAlpha',0.3);
%plot3(DesiredAz,DesiredEl,DesiredZ,'rx','LineWidth',2)
%plot3(PksAz,PksEl,PksZ,'go')
maxPower = ceil(max(max(10*log10(abs(PMusic))))/5)*5 ;
caxis([maxPower-20-50 maxPower-3-50])
cmap = colormap(gca);
cmap(1,:) = [1,1,1] ;
set(gcf,'colormap',jet)
shading interp;
axis ('equal');
hold off
view (0, -90);
xlim([-180 180])
ylim([-90 90])
xlabel('Azimuth [Deg]')
ylabel('Elevation [Deg]')

%set(gcf,'colormap',jet)
%plot3(DesiredAz,90-DesiredEl,DesiredZ,'rx','LineWidth',2)


%plot3(PksAz,90-PksEl,PksZ,'go')
% 
% axis ('equal') ;
% hold off
% view (0, 90) ;
 legend('MUSIC Power','Given DOA','Estimated DOA','Location','south')
 set(gca,'fontsize',20)