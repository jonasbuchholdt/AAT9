
%%
clear all
flex_result = csvread('flex_group.csv',1,0);
single_result = csvread('B3_107.csv',1,0);
%%
A_w = [-50.5 -44.7 -39.4 -34.6 -30.2 -26.2 -22.5 -19.1 -16.1 -13.4 -10.9 -8.6 -6.6 -4.8 -3.2 -1.9 -0.8 0 0.6 1.0 1.2 1.3 1.2 1.0 0.5 -0.1 -1.1 -2.5 -4.3 -6.6 -9.3] 
C_w = [-6.2 -4.4 -3.0 -2.0 -1.3 -0.8 -0.5 -0.3 -0.2 -0.1 0 0 0 0 0 0 0 0 0 -0.1 -0.2 -0.3 -0.5 -0.8 -1.3 -2.0 -3.0 -4.4 -6.2 -8.5 -11.2]
x = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000]
xs = categorical({'20','25','31.5','40','50','63','80','100','125','160','200','250','315','400','500','630','800','1k','1k25','1k6','2k0','2k5','3k15','4k0','5k0','6k3','8k0','10k0','12k5','16k0','20k0'});
xsa = ["20","25","31.5","40","50","63","80","100","125","160","200","250","315","400","500","630","800","1k","1k25","1k6","2k","2k5","3k15","4k","5k","6k3","8k","10k","12k5","16k","20k"];
flex_slow = flex_result(2.46*10^4-24000:1.428*10^5-24000,35:65);
single_slow = single_result(2.46*10^4:1.428*10^5,35:65);

Leq_flex = 10*log10(1/length(flex_slow)*sum(10.^(flex_slow/10),1));
Leq_single = 10*log10(1/length(single_slow)*sum(10.^(single_slow/10),1));

LAeq_flex = Leq_flex+A_w;
LAeq_single = Leq_single+A_w;
LCeq_flex = Leq_flex+C_w;
LCeq_single = Leq_single+C_w;
LAeq = [LAeq_flex;LAeq_single];
LCeq = [LCeq_flex;LCeq_single];

figure(1)
b = bar(LAeq',1.2)
bl = b.BaseLine;
%c = bl.Color;
bl.BaseValue = -10;
xticks(1:1:31);
xticklabels(xsa);
ylabel('Level [dBA]')
xlabel('Frequency [Hz]')

lgd = legend('Flex room','B3-107');
title(lgd,'A-weighted level');
set(gca,'fontsize',14)


figure(2)
b = bar(LCeq',1.2)
bl = b.BaseLine;
%c = bl.Color;
bl.BaseValue = -10;
xticks(1:1:31);
xticklabels(xsa);
ylabel('Level [dBC]')
xlabel('Frequency [Hz]')

lgd = legend('Flex room','B3-107');
title(lgd,'C-weighted level');
set(gca,'fontsize',14)
