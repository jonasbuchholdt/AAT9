clearvars
close all


S7169829 = mean([3.1 2.4; 1.4 0.094],2);
S9823032 = mean([2.8 -0.75; 4 -0.75],2);
S5800904 = mean([-1.8 -2.7;  2.9 -0.61],2);
S5814465 = mean([-2.6 -5.1; -7.8 -6.6],2);
S8627107 = mean([-7.3 -6.9; -2.9 0.33],2);
S8907521 = mean([-2.5 -1.9; -1.3 0.094],2);
S4842965 = mean([10 13; 21 22],2);
S7690291 = mean([1.2 -0.47; 9.7 13],2);
S1208596 = mean([11 11; 11 8.4],2);
S6259598 = mean([4.3 5.2; 18 17],2);

data = [S7169829 S9823032 S5800904 S5814465 S8627107 S8907521 S4842965 S7690291 S1208596 S6259598];

dif = data(1,:)-data(2,:);
boxplot(data')
% figure()
% normplot(data(1,:))
% hold on
%  %figure
% normplot(data(2,:))
% %figure()
%normplot(dif)
[ht, pt, cit, statst] = ttest(data(1,:),data(2,:),'Alpha',0.05)
[hl, pl, kstat, critval] = lillietest(dif)