clearvars
%close all
%% loading stuff
airDir = 'logs/AC/GroupA/';
boneDir = 'logs/BC/GroupA/';
airFiles = dir(fullfile(airDir, '*.mat'));
boneFiles = dir(fullfile(boneDir,'*.mat'));
numfiles = length(airFiles);
frequencies = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 160000];
ocFreq = [31.5 63 125 250 500 1000 2000 4000 8000];

ASen = [];
ALvl = [];
AHit = [];

BSen = [];
BLvl = [];
BHit = [];


for k = 1:numfiles 
  tst = load(strcat(airDir,airFiles(k).name));
  ASen = [ASen; cell2mat(tst.sentScores(:,1))];
  ALvl = [ALvl; cell2mat(tst.sentScores(1:20,4))];
  AHit = [AHit; cell2mat(tst.sentScores(:,3))];
  clear tst
  tst = load(strcat(boneDir,boneFiles(k).name));
  BSen = [BSen; cell2mat(tst.sentScores(:,1))];
  BLvl = [BLvl; cell2mat(tst.sentScores(1:20,4))];
  BHit = [BHit; cell2mat(tst.sentScores(:,3))];
  clear tst
end

%% analysing SNR

ASNR  = [];
ASNRa = [];
BSNR  = [];
BSNRa = [];

for k = 1: length(ASen)
    [tmp,tmpa] = Sen2SNRoct(ASen(k),ALvl(k));
    ASNR(k,:) = tmp;
    ASNRa(k,:) = tmpa;
    [tmp,tmpa] = Sen2SNRoct(BSen(k),BLvl(k));
    BSNR(k,:) = tmp;
    BSNRa(k,:) = tmpa;
end
clear tmp tmpa

%% Counting stuff: a weighted sum levels
binCenters = [-21:3:60];
binBorders = [binCenters-1.5 binCenters(end)+1.5];
nBins = length(binCenters);

hitMiss = zeros(2,nBins,2);
% Dim1: 1 nHits; 2 nMiss
% Dim2: number of bin
% Dim3: 1 AC; 2 BC

for k = 1:nBins
    for h = 1:length(ASen)
        if ASNRa(h) <= binBorders(k+1) && ASNRa(h) > binBorders(k)
            if AHit(h) == 1
                hitMiss(1,k,1) = hitMiss(1,k,1)+1;
            elseif AHit(h) == 0
                hitMiss(2,k,1) = hitMiss(2,k,1)+1;
            end
        end
        if BSNRa(h) <= binBorders(k+1) && BSNRa(h) > binBorders(k)
            if BHit(h) == 1
                hitMiss(1,k,2) = hitMiss(1,k,2)+1;
            elseif BHit(h) == 0
                hitMiss(2,k,2) = hitMiss(2,k,2)+1;
            end
        end
    end
end

probSum(:,1) = hitMiss(1,:,1)./(hitMiss(1,:,1)+hitMiss(2,:,1));
probSum(:,2) = hitMiss(1,:,2)./(hitMiss(1,:,2)+hitMiss(2,:,2));
% Only for A weighted or total lvl

%% Counting stuff: third octave bands
for u = 1:length(ocFreq)
hitMiss = zeros(2,nBins,2);
% Dim1: 1 nHits; 2 nMiss
% Dim2: number of bin
% Dim3: 1 AC; 2 BC

for k = 1:nBins
    for h = 1:length(ASen)
        if ASNR(h,u) <= binBorders(k+1) && ASNR(h,u) > binBorders(k)
            if AHit(h) == 1
                hitMiss(1,k,1) = hitMiss(1,k,1)+1;
            elseif AHit(h) == 0
                hitMiss(2,k,1) = hitMiss(2,k,1)+1;
            end
        end
        if BSNR(h,u) <= binBorders(k+1) && BSNR(h,u) > binBorders(k)
            if BHit(h) == 1
                hitMiss(1,k,2) = hitMiss(1,k,2)+1;
            elseif BHit(h) == 0
                hitMiss(2,k,2) = hitMiss(2,k,2)+1;
            end
        end
    end
end

probF(:,u,1) = hitMiss(1,:,1)./(hitMiss(1,:,1)+hitMiss(2,:,1));
probF(:,u,2) = hitMiss(1,:,2)./(hitMiss(1,:,2)+hitMiss(2,:,2));
end

%% plotting stuff
% close all
% [SNR,Fc] = meshgrid(binCenters,ocFreq);
% surf(SNR',Fc',probF(:,:,1))
% set(gca, 'YScale', 'log');
% figure
% for k = 1:length(ocFreq)
%     plot(binCenters,probF(:,k,1))
%     hold on
% end
% legend('31.5', '63', '125', '250', '500', '1000', '2000', '4000', '8000')
% xlabel('SNR [dB]')
% ylabel('Hit Probability')
% title('Air')
% hold off
% figure
% for k = 1:length(ocFreq)
%     plot(binCenters,probF(:,k,2))
%     hold on
% end
% legend('31.5', '63', '125', '250', '500', '1000', '2000', '4000', '8000')
% xlabel('SNR [dB]')
% title('Bone')
% ylabel('Hit Probability')
% 
Air = probF(:,:,1);
Air(isnan(Air)) = 0;
Air = mean(Air,2);
Bone = probF(:,:,2);
Bone(isnan(Bone)) = 0;
Bone= mean(Bone,2);

figure()
plot(binCenters,Air)
hold on
plot(binCenters,Bone)
xlabel('SNR [dB]')
% plot(binCenters,probSum(:,1))
% plot(binCenters,probSum(:,2))
legend('Air f-avg','Bone f-avg');%,'Air A','Bone A')
ylim([0 1])
ylabel('Hit Probability')
title('Group A')