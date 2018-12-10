
x = [1:0.1:100]

mu = 50.00;
var = 5.34;
fi = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,fi)
hold on
mu = 49.48;
var = 4.604;
ff = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,ff)

mu = 47.99;
var = 9.44;
fb = (1/sqrt(2*pi*var^2))*exp(-(((x-mu).^2)/(2*var^2)));
plot(x,fb)

grid on
grid minor
legend('Initail','Familiarisation of BIER','BIER','Location','northeast')
set(gca,'fontsize',12)