clear all
close all

data_small = csvread('B2_107.csv',1,0);
data_big = csvread('flex_group.csv',1,0);
data_big_mod = [zeros(24000,65); data_big; zeros((size(data_small,1)-24000-size(data_big,1)),65)];
%%
timestr = datetime('08/14/2017 08:40:00.00000', 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSSSS')+ seconds((0:length(data_small)-1)./8);

A_w = [-50.5 -44.7 -39.4 -34.6 -30.2 -26.2 -22.5 -19.1 -16.1 -13.4 -10.9 -8.6 -6.6 -4.8 -3.2 -1.9 -0.8 0 0.6 1.0 1.2 1.3 1.2 1.0 0.5 -0.1 -1.1 -2.5 -4.3 -6.6 -9.3]; 
C_w = [-6.2 -4.4 -3.0 -2.0 -1.3 -0.8 -0.5 -0.3 -0.2 -0.1 0 0 0 0 0 0 0 0 0 -0.1 -0.2 -0.3 -0.5 -0.8 -1.3 -2.0 -3.0 -4.4 -6.2 -8.5 -11.2];

smallroomA = 10*log10(sum(10.^(((data_small(:,4:34))+A_w)/10),2));
smallroomC = 10*log10(sum(10.^(((data_small(:,4:34))+C_w)/10),2));
smallroomZ = 10*log10(sum(10.^(((data_small(:,4:34)))/10),2));
smallroomAslow = 10*log10(sum(10.^(((data_small(:,35:65))+A_w)/10),2));

bigroomA = 10*log10(sum(10.^(((data_big_mod(:,4:34))+A_w)/10),2));
bigroomC = 10*log10(sum(10.^(((data_big_mod(:,4:34))+C_w)/10),2));
bigroomZ = 10*log10(sum(10.^(((data_big_mod(:,4:34)))/10),2));

st_s=2.46e4;
end_s=1.428e5;
p10_b=[zeros(st_s-1,1); ones(end_s-st_s,1); zeros((size(data_small,1)-end_s+1),1)];
p50_b=p10_b;
p90_b=p10_b;
p10_s=p10_b;
p50_s=p10_b;
p90_s=p10_b;

p10_b=p10_b*prctile(bigroomA((st_s:end_s),1) ,10);
p50_b=p50_b*prctile(bigroomA((st_s:end_s),1) ,50);
p90_b=p90_b*prctile(bigroomA((st_s:end_s),1) ,90);

p10_s=p10_s*prctile(smallroomA((st_s:end_s),1) ,10);
p50_s=p50_s*prctile(smallroomA((st_s:end_s),1) ,50);
p90_s=p90_s*prctile(smallroomA((st_s:end_s),1) ,90);

LZEQ_flex = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((bigroomZ(2.46*10^4:1.428*10^5)./10))))
LAEQ_flex = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((bigroomA(2.46*10^4:1.428*10^5)./10))))
LCEQ_flex = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((bigroomC(2.46*10^4:1.428*10^5)./10))))

LZEQ_small = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((smallroomZ(2.46*10^4:1.428*10^5)./10))))
LAEQ_small = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((smallroomA(2.46*10^4:1.428*10^5)./10))))
LCEQ_small = 10*log10((1/length(bigroomZ(2.46*10^4:1.428*10^5)))*sum(10.^((smallroomC(2.46*10^4:1.428*10^5)./10))))

figure(1)
plot(timestr,smallroomA)
hold on
plot(timestr,bigroomA)
hold off
datetick('x', 'HH:MM')
grid minor
axis tight
ylim ([30 110])

figure(2)
plot(timestr,bigroomA)
hold on
plot(timestr,p10_b,'k','LineWidth',2)
plot(timestr,p50_b,'r','LineWidth',2)
plot(timestr,p90_b,'g','LineWidth',2)
hold off
datetick('x', 'HH:MM')
grid minor
ylim([35 87])
xlim([timestr(st_s+100) timestr(end_s-100)])
lgd = legend({'Level over time','P10','P50','P90'})
title(lgd,'Flex room');
xlabel('Time [HH:MM]')
ylabel('Level [dBA]')
set(gca,'fontsize',14)

figure(3)
plot(timestr,smallroomA)
hold on
plot(timestr,p10_s,'k','LineWidth',2)
plot(timestr,p50_s,'r','LineWidth',2)
plot(timestr,p90_s,'g','LineWidth',2)
hold off
datetick('x', 'HH:MM')
grid minor
ylim([35 87])
xlim([timestr(st_s+100) timestr(end_s-100)])
lgd = legend({'Level over time','P10','P50','P90'})
title(lgd,'B3-107');

xlabel('Time [HH:MM]')
ylabel('Level [dBA]')
set(gca,'fontsize',14)

figure(4)
plot(timestr(80000:80480),smallroomA(80000:80480))
hold on
plot(timestr(80000:80480),smallroomAslow(80000:80480))
hold off
datetick('x', 'HH:MM:SS')
grid minor
axis tight
ylim ([35 75])
legend('Fast','Slow')
xlabel('Time [HH:MM:SS]')
ylabel('Level [dB]')
set(gca,'FontSize',14)
error = data_big_mod(80000:81200,2) - bigroomZ(80000:81200,1);