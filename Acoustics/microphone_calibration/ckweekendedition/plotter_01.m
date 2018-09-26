clear all
close all

data_small = csvread('B2_107.csv',1,0);
data_big = csvread('flex_group.csv',1,0);
data_big_mod = [zeros(24000,65); data_big; zeros((size(data_small,1)-24000-size(data_big,1)),65)];
%%
timestr = datetime('08/14/2017 08:40:00.00000', 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSSSS')+ seconds((0:length(data_small)-1)./8);

plot(timestr,data_small(:,2))
hold on
plot(timestr,data_big_mod(:,2))
datetick('x', 'HH:MM')
grid minor
axis tight
ylim ([30 110])
