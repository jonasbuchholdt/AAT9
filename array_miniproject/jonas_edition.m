%%

clear all
clc

%--------initi------------------
%load LOS_only_MSM_no_noise.mat
load LOS_plus4comp_MSM_no_noise.mat
%load measDataTrack1Rp5TxPos1To50
posAng = (-2*pi*(0:7)/8)-pi; %posAng = -2*pi*(0:7)/8;
radius = 75.18e-3/2;
Lambda = 3e8/5.2e9;
z_pos = 1.1;
M = 5;

%---------impunseResponseR--------
start = 40
stop = 50                          % number of averaged measurements
varn = 0.000000000;            % variance of noise
noise = sqrt(varn/2)*(randn(size(mirrorModelParam.TransferFunction,2),stop-start+1)+1j*randn(size(mirrorModelParam.TransferFunction,2),stop-start+1));
IR = ifft(mirrorModelParam.TransferFunction);                            % computing Impulse Responses
IRmod = squeeze(sum(IR(1:200,:,start:stop),1));
% Calculating and printing SNR
SNR = 10*log10(mean(rms(IRmod))/mean(rms(noise)));
fprintf('SNR: %d \n',round(SNR))
IRmod = (IRmod + noise);                 % adding noise and signal
R = (1/size(IRmod,2)).*(IRmod*IRmod'); % generating spatial covariance matrix estimate
R = (R+R')/2;                   % Removing imaginary components


%-----------TransferFunctionR-----
% H = mirrorModelParam.TransferFunction;
% [Nc,Nr,Nt]=size(H);
% B = measData.Bandwidth;
% delayAxis = 0:1/B:(Nc-1)/B;
% D = squeeze(H(:,:,50));
% D = D+1e-16*(randn(size(D))+1j*randn(size(D)));
%R = D'*D/Nc;


%--------smoothing-------------
% p = size(IRmod,1);   
% sub = round(3/2*M);
% x_p = [];
% for d=1:p-sub+1
%     x_p(:,:,d) =  IRmod(d:d+sub-1,:);
%     R_p(:,:,d) = x_p(:,:,d)*x_p(:,:,d)';
% end
% % x_p = x_p';
% % R_p = x_p*x_p';
% R_F = (1/(p-sub+1))*sum(R_p,3);
% J = flip(eye(sub));
% R_FB = (1/2).*(R_F+J.*R_F'.*J);
% R = R_FB;

%------------angleDomain-------
ThetaS = linspace(-pi,pi,360*2);
PhiS = linspace(0,pi,180*2);

%------------carpon------------
%PCarpon(h,k) = 1/(a(:,h,k)'*R_inv*a(:,h,k));
R_inv = inv(R);
for ii=1:length(ThetaS)
    for jj=1:length(PhiS)
        an = exp(1j*2*pi/Lambda*radius*(cos(ThetaS(ii)-posAng)*sin(PhiS(jj))+z_pos*cos(PhiS(jj))));
        Pcarpon(ii,jj)=1./abs(an*R_inv*an');
    end
end

%------------EVD---------------
[W,B] = eig(R);
[DD,S] = sort(diag(B),'descend');
Es = W(:,S(1:M));
En = W(:,S(M+1:end));

%------------MUSIC-------------
for ii=1:length(ThetaS)
    for jj=1:length(PhiS)
        an = exp(1j*2*pi/Lambda*radius*(cos(ThetaS(ii)-posAng)*sin(PhiS(jj))+z_pos*cos(PhiS(jj))));
        Pmusic(ii,jj)=1./abs(an*En*En'*an');
    end
end

%----------plot----------------
figure(1)
surf(PhiS,ThetaS,10*log10(Pmusic/max(max(Pmusic))))
shading interp




%%
clear all
%plot(abs(measData.TransferFunction(:,1,2)))
load('LOS_only_MSM_no_noise.mat')
f0 = 5.2*10^(9);
c = 3*10^8;
lambda = c/f0;
M = 1;
ArrayRadius = 0.07518;


L = 8;
l = 1:L;
azrng = linspace(-pi,pi,360);
elrng = linspace(1/180,pi,179);
AntPos = mirrorModelParam.RxAntPosRelative;
[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));





for i =1:1
x = ifft(mirrorModelParam.TransferFunction(:,:,i)');
N = length(mirrorModelParam.TransferFunction(:,1,1));

%R = (1/size(x,1))*(x*(x'));
R = (1/N)*x*x';



real(eig(R))
end

%%
e = ones(3,length(azrng),length(elrng));
a = e;
for k = 1:length(elrng)
   e(1,:,k) = cos(azrng).*sin(elrng(k));
   e(2,:,k) = sin(azrng).*sin(elrng(k));
   e(3,:,k) = cos(azrng);
   for h = 1:L
       a(h,:,k) = exp(1j*(2*pi/lambda))*(e(:,:,k).'*AntPos(:,h))';
   end
end

PBartlett = ones(length(azrng),length(elrng));
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*R*a(:,h,k))/(norm(a(:,h,k),2).^4);
end
end
%%
R_inv = inv(R);

PCarpon = ones(length(azrng),length(elrng));
for h = 1:length(azrng)
for k = 1:length(elrng)
    PCarpon(h,k) = 1/(a(:,h,k)'*R_inv*a(:,h,k));
end
end

Mmax = max(PCarpon(:));
[row,col] = find(PCarpon == Mmax);
PCarpon_abs = abs(PCarpon)./abs(Mmax);
figure()
surf(AZ',EL',10*log10((PCarpon_abs)))
%%
% e = ones(3,length(azrng),length(elrng));
% a = e;
% 
% for k = 1:length(elrng)
% for b = 1:length(azrng)   
%     e = [cos(azrng(b)).*sin(elrng(k)) sin(azrng(b)).*sin(elrng(k)) cos(azrng(b))]';
%    for h = 1:L
%        a(h,b,k) = exp(1j*(2*pi/lambda))*(e'*AntPos(:,L))';
%    end
% end
% end


for b = 1:length(azrng)   
    e = [cos(azrng(b)) sin(azrng(b))]';
   for h = 1:L
       a(h,1) = exp(1j*(2*pi/lambda))*(e'*AntPos(1:2,h-length(h)+1))';      
   end
   PBartlett(b) = (a'*R*a)/norm(a,2).^4;
   
end

% carpon
R_inv = inv(R);

for b = 1:length(azrng)   
    e = [cos(azrng(b)) sin(azrng(b))]';
   for h = 1:L
       a(h,1) = exp(1j*(2*pi/lambda))*(e'*AntPos(1:2,h))';      
   end
   p_c(b) = 1/(a'*R_inv*a);
   
end

% MUSIC

[V,D] = eig(R);
U_n = V(:,length(M)+1:end);

for b = 1:length(azrng)   
    e = [cos(azrng(b)) sin(azrng(b))]';
   for h = 1:L
       a(h,1) = exp(1j*(2*pi/lambda))*(e'*AntPos(1:2,h))';      
   end
p_M(b) = 1/(a'*U_n*U_n'*a);
end

% PBartlett = ones(length(azrng),length(elrng));
% for h = 1:length(azrng)
% for k = 1:length(elrng)
%     PBartlett(h,k) = (a(:,h,k)'*R*a(:,h,k))/(norm(a(:,h,k),2).^4);
% end
% end



%%
bgFig=imread ('rp5a.jpg'); 
figure;
image([180 -180] ,...
        [0 180] ,...
bgFig (:,:,1:3)) 
hold on;
surf(ThetaS./pi.*180,PhiS(1:length(PhiS)/2)./pi.*180,10*log10(abs(Pmusic(:,1:length(PhiS)/2,:)).'),'FaceAlpha',0.3);
%maxPower=ceil(max(max(10*log10(abs(pBartletC(:,:,iDelay)))))/5)*5; 
maxPower = ceil(max(max(10*log10(abs(Pmusic))))/5)*5 ;
caxis([maxPower-50 maxPower+50]);
cmap=colormap(gca);
cmap(1,:) = [1,1,1];
set(gcf,'colormap',cmap); 
shading interp;
axis('equal');
hold off
view (0,90);

%%
DesiredAz = mean(rad2deg(mean(mirrorModelParam.thetaRxAzim(:,:,start:stop),2)),3);
DesiredEl = mean(rad2deg(mean(mirrorModelParam.phiRxElev(:,:,start:stop),2)),3);
DesiredZ = zeros(length(DesiredAz),1);
[AZ,EL] = meshgrid(rad2deg(ThetaS),rad2deg(PhiS-pi/2));
bgFig = imread('rp5a.jpg') ;
figure;
image([180 -180],[90 -90],bgFig (:,:,1:3));
hold on;
surf(AZ',EL', 10*log10(abs(Pmusic))-50,'FaceAlpha',0.3);
plot3(DesiredAz,DesiredEl,DesiredZ,'rx','LineWidth',2)
maxPower = ceil(max(max(10*log10(abs(Pmusic))))/5)*5 ;
caxis([maxPower-60-50 maxPower-3-50])
cmap = colormap(gca);
cmap(1,:) = [1,1,1] ;
set(gcf,'colormap',jet)
shading interp;
axis ('equal');
hold off
view (0, -90);
xlim([-180 180])
ylim([-90 90])

%%
step = pi/(360*10);
theta = [-pi:step:pi-step];


%bartlet
for k=1:length(theta)
a = g*exp(1j*2*pi*L*((lambda/2)/lambda)*cos(theta(k)));
p_b(k) = (a'*R*a)/norm(a,2).^4;
end