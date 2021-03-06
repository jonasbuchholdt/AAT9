clearvars
%close all
%% loading stuff
% user input, where files for AC and BC are situated (should be folders)
airDir = 'logs/AC/'; 
boneDir = 'logs/BC/';
subjects = [7169829 9823032 5800904 5814465 8627107 8907521 4842965 7690291 1208596 6259598];
S.S7169829 = mean([3.1 2.4; 1.4 0.094],2);
S.S9823032 = mean([2.8 -0.75; 4 -0.75],2);
S.S5800904 = mean([-1.8 -2.7;  2.9 -0.61],2);
S.S5814465 = mean([-2.6 -5.1; -7.8 -6.6],2);
S.S8627107 = mean([-7.3 -6.9; -2.9 0.33],2);
S.S8907521 = mean([-2.5 -1.9; -1.3 0.094],2);
S.S4842965 = mean([10 13; 21 22],2);
S.S7690291 = mean([1.2 -0.47; 9.7 13],2);
S.S1208596 = mean([11 11; 11 8.4],2);
S.S6259598 = mean([4.3 5.2; 18 17],2);

data = [S.S7169829 S.S9823032 S.S5800904 S.S5814465 S.S8627107 S.S8907521 S.S4842965 S.S7690291 S.S1208596 S.S6259598];

for u=1:length(subjects)
airFiles = dir(fullfile(airDir, strcat(int2str(subjects(u)),'*.mat')));
boneFiles = dir(fullfile(boneDir,strcat(int2str(subjects(u)),'*.mat')));
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

ASNR(:,u)  = ALvl-NoiseLvl;

BSNR(:,u)  = BLvl-NoiseLvl;





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

probSum(:,1,u) = (hitMiss(1,:,1)./(hitMiss(1,:,1)+hitMiss(2,:,1)));
probSum(:,2,u) = (hitMiss(1,:,2)./(hitMiss(1,:,2)+hitMiss(2,:,2)));
end


%% plotting stuff
close all
figure()
%median(ASNR(:,u))
for u = 1:length(subjects)
scatter(binCenters-data(1,u),probSum(:,1,u),'MarkerEdgeColor',[0 0 1],...
              'MarkerFaceColor',[0 0 1])
%plot(binCenters-data(1,u),probSum(:,1,u))
              hold on
scatter(binCenters-data(2,u),probSum(:,2,u),'MarkerEdgeColor',[1 0 0],...
              'MarkerFaceColor',[1 0 0])
%plot(binCenters-data(2,u),probSum(:,2,u))
end
legend('Air','Bone')
xlabel('SNR')
ylabel('Hit Probability')