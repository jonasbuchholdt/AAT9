clearvars
close all

sentence_nr = 51;

sentence_gain = 60;

noise_playback = 65;

frequencies = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 160000];
noise_measured = [33.3 32.9 32.7 32.3 38.0 30.6 33.0 45.6 53.4 49.6 52.6 54.8 52.4 53.6 49.5 56.9 49.6 51.4 51.4 41.7 45.3 47.2 46.7 40.9 38.9 36.0 38.1 34.1 26.5 26.8];

A_weighting = [-50.5	-44.7	-39.4	-34.6	-30.2	-26.2	-22.5	-19.1	-16.1	-13.4	-10.9	-8.6	-6.6	-4.8	-3.2	-1.9	-0.8	0.0	0.6	1.0	1.2	1.3	1.2	1.0	0.5	-0.1	-1.1	-2.5	-4.3	-6.6];

noise = noise_measured;
measurement_digifile_relator = -26.01-63.87;
a_corrector = -3.98;

noise_lvl = noise_measured+a_corrector+measurement_digifile_relator+noise_playback;

sentence_lvl = csvread('12_10_sentence_levels_komma.csv',sentence_nr,2,[sentence_nr,2,sentence_nr,31]);

sentence_lvl = sentence_lvl+sentence_gain;

SNR = sentence_lvl-noise_lvl;

sentence_a = sentence_lvl+A_weighting;
noise_a = noise_lvl+A_weighting;

sen_a = 20*log10(sum(10.^(sentence_a/20)));
noi_a = 20*log10(sum(10.^(noise_a/20)));

SNRa = sen_a-noi_a;