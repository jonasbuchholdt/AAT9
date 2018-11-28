clear all
close all
%load('LOS_only_MSM_no_noise.mat')
load('LOS_plus4comp_MSM_no_noise.mat')

%G = ones(8,1);                  % antenna directionality omnidirectional

f = 5.2e9;
c = 3e8;
lambda = c/f;

AntPos = mirrorModelParam.RxAntPosRelative;
TF = mirrorModelParam.TransferFunction;
%TF = measData.TransferFunction

ArrayRadius = 0.07518;


L = 8;
l = 1:L;
azrng = linspace(-pi,pi,180);
elrng = linspace(-pi/2,pi/2,90);

[AZ,EL] = meshgrid(rad2deg(azrng),rad2deg(elrng));

erng = ones(3,length(azrng),length(elrng));
a = erng;
for k = 1:length(elrng)
   erng(1,:,k) = cos(azrng).*sin(elrng(k));
   erng(2,:,k) = sin(azrng).*sin(elrng(k));
   erng(3,:,k) = cos(azrng);
   for h = 1:L
       a(h,:,k) = exp(i*(2*pi/lambda))*(erng(:,:,k).'*AntPos(:,L))';
   end
end

for u = 5 %1:size(TF,3)
varn = 0.0001;
%noise = varn*(randn(size(TF,2),size(TF,1))+i*randn(size(TF,2),size(TF,1)));
noise = varn*(randn(size(TF,2),20)+i*randn(size(TF,2),20));
TFmod = squeeze(TF(1000,:,1:20));

SNR = 10*log10(mean(rms(TFmod))/mean(rms(noise)))
TFmod = TFmod + noise;
Rhat = (1/size(TFmod,1))*(TFmod*(TFmod'));

disp(strcat('Rank of covariance matrix:_',int2str(rank(Rhat))))



PBartlett = ones(length(azrng),length(elrng));
for h = 1:length(azrng)
for k = 1:length(elrng)
    PBartlett(h,k) = (a(:,h,k)'*Rhat*a(:,h,k))/(norm(a(:,h,k),2).^4);
end
end
    %a = exp(i*(2*pi/lambda))*(erng(:,:,1).',AntPos(:,1));
Mmax = max(PBartlett(:));
[row,col] = find(PBartlett == Mmax);
    PBartlett = abs(PBartlett)./abs(Mmax);



MaxAz(u) = mean(rad2deg(azrng(row)))
MaxEl(u) = mean(rad2deg(azrng(col)))
end
figure()
plot(MaxAz)
hold on
plot(MaxEl)
hold off
figure()
surf(AZ',EL',10*log10((PBartlett)))


%%
%AntPosCalc = ArrayRadius.*(cos(2*pi*(l-1)/L).*sin(2*pi*(l-1)/L)).';

%steering_vec = 