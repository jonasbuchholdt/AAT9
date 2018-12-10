
clear all

init = [48 50.7 52 46 49 51 50 53.3];
fam =  [49 50.7 48 50.7 45.7 52.7 49.7 49 52 47.3];
bier = [51 51 48 48 42 52 46 48.8 44.8 48.3];
total = [init fam bier];
B = unique(total);

x = [1:0.1:101-0.1];

figure(1)
mu = mean(init);
vari = var(init);
fi = (1/sqrt(2*pi*vari^2))*exp(-(((x-mu).^2)/(2*vari^2)));
plot(x,fi)
hold on
histogram(init, 8,'Normalization','probability')
xlabel('mean [\mu]')
grid on
legend('Initail','Location','northeast')
set(gca,'fontsize',12)

figure(2)
mu = mean(fam);
vari = var(fam);
ff = (1/sqrt(2*pi*vari^2))*exp(-(((x-mu).^2)/(2*vari^2)));
plot(x,ff)
hold on
histogram(fam, 9,'Normalization','probability')
xlabel('mean [\mu]')
ylabel('Probability')
grid on
legend('Familiarisation of BIER','Location','northeast')
set(gca,'fontsize',12)

figure(3)
mu = mean(bier);
vari = var(bier);
fb = (1/sqrt(2*pi*vari^2))*exp(-(((x-mu).^2)/(2*vari^2)));
plot(x,fb)
hold on
histogram(bier, 8,'Normalization','probability')
xlabel('mean [\mu]')
ylabel('Probability')
grid on
legend('BIER','Location','northeast')
set(gca,'fontsize',12)

figure(4)
mu = mean(total);
vari = var(total);
fb = (1/sqrt(2*pi*vari^2))*exp(-(((x-mu).^2)/(2*vari^2)));
 plot(x,fb)
 hold on
histogram(total, length(B),'Normalization','probability');
 xlabel('mean [\mu]')
 ylabel('Probability')
 grid on
 legend('BIER','Location','northeast')
 set(gca,'fontsize',12)

 

 %%
 corr = fb/10;
 init = [48 50.7 52 46 49 51 50 53.3]*10;
fam =  [49 50.7 48 50.7 45.7 52.7 49.7 49 52 47.3]*10;
bier = [51 51 48 48 42 52 46 48.8 44.8 48.3]*10;
total = [init fam bier];

 
y = zeros(1,1000)
for h =1:1000
    for g=1:length(total)
        if h == totalr(g)
          y(h) = y(h)+(1/length(total));
        end
    end
end
 
plot(y)
hold on
plot(corr)
sum(y)
sum(corr)

err = immse(y,corr)
