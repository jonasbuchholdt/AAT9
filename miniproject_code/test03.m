clear all
close all
load('LOS_only_MSM_no_noise.mat')
%load('LOS_plus4comp_MSM_no_noise.mat')
%load('shortIRtest.mat')

%G = ones(8,1);                  % antenna directionality omnidirectional

f = 5.2e9;
c = 3e8;
lambda = c/f;

AntPos = mirrorModelParam.RxAntPosRelative;
TF = mirrorModelParam.TransferFunction;
%TF = measData.TransferFunction
%TF = truncTF;

ArrayRadius = 0.07518;



L = 8;
l = 1:L;
azrng = linspace(-pi,pi,180);
elrng = linspace(0,pi/2,180);

[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));

erng = ones(3,length(azrng),length(elrng));
a = erng;
for k = 1:length(elrng)
   erng(1,:,k) = cos(azrng).*sin(elrng(k));
   erng(2,:,k) = sin(azrng).*sin(elrng(k));
   erng(3,:,k) = cos(elrng);
   for h = 1:L
       a(h,:,k) = exp(i*(2*pi/lambda))*(erng(:,:,k).'*AntPos(:,h))';
   end
end


% N = 1537;
% angles = (rand(L,N)-0.5)*2*pi;
% s = sqrt(10)*exp(1j*angles);
% S = fft(s).';
% RcSig = S.*TF(:,:,1);
% rcsig = ifft(RcSig)';


for u = 50
varn = 0.000001;
noise = varn*(randn(size(TF,2),size(TF,1))+i*randn(size(TF,2),size(TF,1)));
TFmod = TF(:,:,u).';

SNR = 10*log10(mean(rms(TFmod))/mean(rms(noise)))
TFmod = (TFmod + noise);
Rhat = (1/size(TFmod,1))*(TFmod*TFmod');
%Rhat = (1/size(rcsig,1))*(rcsig*rcsig');
disp(strcat('Rank of covariance matrix:_',int2str(rank(Rhat))))



PBartlett = ones(length(azrng),length(elrng));
PCapon = PBartlett;
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*Rhat*a(:,h,k))/(norm(a(:,h,k),2).^4);
    PCapon(h,k) = 1./(a(:,h,k)'*inv(Rhat)*a(:,h,k));
end
end
%a = exp(i*(2*pi/lambda))*(erng(:,:,1).',AntPos(:,1));
Mmax = max(PBartlett(:));
CaponMax = max(PCapon(:));
[row,col] = find(PBartlett == Mmax);
PBartlett = abs(PBartlett)./abs(Mmax);
%nPCapon = abs(PCapon)./abs(CaponMax);


MaxAz(u) = mean(rad2deg(azrng(row)))
MaxEl(u) = mean(rad2deg(azrng(col)))
end
figure()
plot(MaxAz)
hold on
plot(MaxEl)
hold off
figure()
surf(AZ',EL',10*log10(abs(PCapon)))


%%
%AntPosCalc = ArrayRadius.*(cos(2*pi*(l-1)/L).*sin(2*pi*(l-1)/L)).';

%steering_vec = 