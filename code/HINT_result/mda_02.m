clearvars
%close all
%% loading stuff
% user input, where files for AC and BC are situated (should be folders)
airDir = 'logs/test/AC/'; 
boneDir = 'logs/test/BC/';


airFiles = dir(fullfile(airDir, '*.mat'));
boneFiles = dir(fullfile(boneDir,'*.mat'));
numfiles = length(airFiles);


ASen = [];          % AC sentence numbers
ALvl = [];          % AC playback levels
AHit = [];          % AC correct y/n (1 is y)


BSen = [];          % same for BC
BLvl = [];
BHit = [];

% loop pulls parameters out of the log files
for k = 1:numfiles
  tst = load(strcat(airDir,airFiles(k).name));
  ASen = [ASen; cell2mat(tst.sentScores(:,1))];
  ALvl = [ALvl; cell2mat(tst.sentScores(1:20,4))];      % hardcoded because of bug in data storage
  AHit = [AHit; cell2mat(tst.sentScores(:,3))];
  clear tst
  tst = load(strcat(boneDir,boneFiles(k).name));
  BSen = [BSen; cell2mat(tst.sentScores(:,1))];
  BLvl = [BLvl; cell2mat(tst.sentScores(1:20,4))];
  BHit = [BHit; cell2mat(tst.sentScores(:,3))];
  clear tst
end

%% determining SNR

NoiseLvl = 65;      % noise playback level assumed by HINT routine

ASNR  = ALvl-NoiseLvl;

BSNR  = BLvl-NoiseLvl;





%% Counting stuff: a weighted sum levels
binCenters = [-15:1:15];
binBorders = [binCenters-0.5 binCenters(end)+0.5];
nBins = length(binCenters);

hitMiss = zeros(2,nBins,2);
% Dim1: 1 nHits; 2 nMiss
% Dim2: number of bin
% Dim3: 1 AC; 2 BC

for k = 1:nBins
    for h = 1:length(ASen)
        if ASNR(h) <= binBorders(k+1) && ASNR(h) > binBorders(k)
            if AHit(h) == 1
                hitMiss(1,k,1) = hitMiss(1,k,1)+1;
            elseif AHit(h) == 0
                hitMiss(2,k,1) = hitMiss(2,k,1)+1;
            end
        end
        if BSNR(h) <= binBorders(k+1) && BSNR(h) > binBorders(k)
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



%% plotting stuff
close all

figure()
plot(binCenters,probSum(:,1))
hold on
plot(binCenters,probSum(:,2))

