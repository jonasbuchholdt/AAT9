clear all
close all

filenamel = 'data/Jonas_L';
filenamer = 'data/Ch_right';


calleft = 'Calibration/Levels_left'
calright = 'Calibration/Levels_right'

CalValL = cell2mat(struct2cell(load(calleft)));
CalValR = cell2mat(struct2cell(load(calright)));

Ldata = load(filenamel);
Rdata = load(filenamer);
Ldata = cell2mat(struct2cell(Ldata));
Rdata = cell2mat(struct2cell(Rdata));


CalFreqs = [125 250 500 750 1000 1500 2000 3000 4000 6000 8000];
TestFreqs = [1000 2000 3000 4000 750 500];
RefThres = [30.5 18 11 6 5.5 5.5 4.5 2.5 9.5 17 17.5];


for k = 1:length(TestFreqs)
    Lbuffer = Ldata(:,1,k);
    Rbuffer = Rdata(:,1,k);
    AttLvl(1,k) = Lbuffer(find(Lbuffer,1,'last'));
    AttLvl(2,k) = Rbuffer(find(Rbuffer,1,'last'));
end

AttLvl(1,:) = CalValL([5 7 8 9 4 3])-AttLvl(1,:);
AttLvl(2,:) = CalValR([5 7 8 9 4 3])-AttLvl(2,:)

figure()
stem(TestFreqs,AttLvl(1,:))
hold on
stem(TestFreqs,AttLvl(2,:))
legend('JB','CK')