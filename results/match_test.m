clear all

S1208596f = [48 48 51];
S4842965f = [50 51 51];
S5800904f = [45 48 51];
S5814465f = [51 51 50];
S6259598f = [45 47 45];
S7169829f = [52 53 53];
S7690291f = [49 48 49];
S8907521f = [50 49 28];
S8627107f = [45 55 56];
S9823032f = [45 50 47];

S1208596 = [50 52 50 52];
S4842965 = [51 51];
S5800904 = [45 50 47 47 49 50];
S5814465 = [45 50 47 50];
S6259598 = [43 42 40 43];
S7169829 = [52 53 51 52];
S7690291 = [46 48 45 45];
S8907521 = [50 48 50 47];
S8627107 = [45 47 40 47];
S9823032 = [50 47 47 47 51 48];

meansf = round([mean(S1208596f) mean(S4842965f) mean(S5800904f) mean(S5814465f)...
    mean(S6259598f) mean(S7169829f) mean(S7690291f) mean(S8907521f)...
    mean(S8627107f) mean(S9823032f)]);


%meansfc = round([mean(S1208596) mean(S4842965) mean(S5800904) mean(S5814465(2:end))...
 %   mean([S6259598(1:2) S6259598(4)]) mean(S7169829) mean(S7690291) mean(S8907521)...
  %  mean([S8627107(1:2) S8627107(4)]) mean(S9823032)]);


meansrc = round([mean(S1208596) mean(S4842965) mean(S5800904) mean(S5814465)...
    mean(S6259598) mean(S7169829) mean(S7690291) mean(S8907521)...
    mean([S8627107(1:2) S8627107(4)]) mean(S9823032)]);

meansnc = round([mean(S1208596) mean(S4842965) mean(S5800904) mean(S5814465)...
    mean(S6259598) mean(S7169829) mean(S7690291) mean(S8907521)...
    mean(S8627107) mean(S9823032)]);

meansd = meansrc-meansf;

means_used = [48 48 48 48 48 48 48 48 48 48];
means_used = [51 51 48 48 43 52 46 49 46 48];


S1208596srt = [mean([11 8.4])+means_used(1)-48 11];
S4842965srt = [mean([21 22])+means_used(2)-48 mean([13 10])];
S5800904srt = [mean([2.9 -0.61])+means_used(3)-48 mean([-2.7 -1.8])];
S5814465srt = [mean([-7.8 -6.6])+means_used(4)-48 mean([-2.6 -5.1])];
S6259598srt = [mean([18 17])+means_used(5)-48 mean([4.3 5.2])];
S7169829srt = [mean([1.4 0.094])+means_used(6)-48 mean([3.1 2.4])];
S7690291srt = [mean([9.7 13])+means_used(7)-48 mean([1.2 -0.47])];
S8907521srt = [mean([-1.3 0.094])+means_used(8)-48 mean([-1.5 -2.5])];
S8627107srt = [mean([-2.5 0.33])+means_used(9)-48 mean([-7.3 -6.9])];
S9823032srt = [mean([4 -0.75])+means_used(10)-48 mean([2.8 -0.75])];

%bone
match(1,:) = [S1208596srt(1) S4842965srt(1) S5800904srt(1) S5814465srt(1) S6259598srt(1)...
    S7169829srt(1) S7690291srt(1) S8907521srt(1) S8627107srt(1) S9823032srt(1)];

%air
match(2,:) = [S1208596srt(2) S4842965srt(2) S5800904srt(2) S5814465srt(2) S6259598srt(2)...
    S7169829srt(2) S7690291srt(2) S8907521srt(2) S8627107srt(2) S9823032srt(2)];

mean(match,2)
std(match')'
%%

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
ci = cdf('Normal',x,mu,sqrt(vari));
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
cf = cdf('Normal',x,mu,sqrt(vari));
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
cb = cdf('Normal',x,mu,sqrt(vari));
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
ct = cdf('Normal',x,mu,sqrt(vari));
 plot(x,fb)
 hold on
histogram(total, length(B),'Normalization','probability');
 xlabel('mean [\mu]')
 ylabel('Probability')
 grid on
 legend('BIER','Location','northeast')
 set(gca,'fontsize',12)

 %%
 figure(5)
boxplot(total, 'orientation', 'horizontal')
 xlabel('mean [\mu]')
 %ylabel('Probability')
 grid on
 grid minor
 %legend('BIER','Location','northeast')
 set(gca,'fontsize',12)
 

 %%
 corr = ct/10;
 init = [48 50.7 52 46 49 51 50 53.3]*10;
fam =  [49 50.7 48 50.7 45.7 52.7 49.7 49 52 47.3]*10;
bier = [51 51 48 48 42 52 46 48.8 44.8 48.3]*10;
total = [init fam bier];

 
y = zeros(1,1000);
for h =1:1000
    for g=1:length(total)
        if h == total(g)
          y(h) = y(h)+(1/length(total));
        end
    end
end
 
plot(y)
hold on
plot(corr);
sum(y)
sum(corr)

err = immse(y,corr)
