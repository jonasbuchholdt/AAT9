


init = [48 50.7 52 46 49 51 50 53.3]
fam =  [49 50.7 48 50.7 45.7 52.7 49.7 49 52 47.3]
bier = [51 51 48 48 42 52 46 48.8 44.8 48.3]
x = [1:0.1:100]

figure(1)
mu = 50.00;
var = 5.34;
fi = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,fi)
hold on
histogram(init, 8,'Normalization','probability')
xlabel('mean []')
grid on
grid minor
legend('Initail','Location','northeast')
set(gca,'fontsize',12)

figure(2)
mu = 49.48;
var = 4.604;
ff = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,ff)
hold on
histogram(fam, 9,'Normalization','probability')
grid on
grid minor
legend('Familiarisation of BIER','Location','northeast')
set(gca,'fontsize',12)

figure(3)
mu = 47.99;
var = 9.44;
fb = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,fb)
hold on
histogram(bier, 8,'Normalization','probability')
grid on
grid minor
legend('BIER','Location','northeast')
set(gca,'fontsize',12)



