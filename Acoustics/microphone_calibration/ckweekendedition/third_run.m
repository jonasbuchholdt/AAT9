function [L_tF,L_tS,LgesF,LgesS]= third_run(input,oneThirdOctaveFilterBank,timefilter,timepar) 
%L_pF,L_pS,


p0 = 20*10^(-6);

output = zeros(length(input),31);
L_tF = zeros(1,31);
L_tS = L_tF;


output(:,1) = oneThirdOctaveFilterBank{1}(input); 
output(:,2) = oneThirdOctaveFilterBank{2}(input);
output(:,3) = oneThirdOctaveFilterBank{3}(input); 
output(:,4) = oneThirdOctaveFilterBank{4}(input);
output(:,5) = oneThirdOctaveFilterBank{5}(input); 
output(:,6) = oneThirdOctaveFilterBank{6}(input);
output(:,7) = oneThirdOctaveFilterBank{7}(input); 
output(:,8) = oneThirdOctaveFilterBank{8}(input);
output(:,9) = oneThirdOctaveFilterBank{9}(input); 
output(:,10) = oneThirdOctaveFilterBank{10}(input);
output(:,11) = oneThirdOctaveFilterBank{11}(input); 
output(:,12) = oneThirdOctaveFilterBank{12}(input);
output(:,13) = oneThirdOctaveFilterBank{13}(input); 
output(:,14) = oneThirdOctaveFilterBank{14}(input);
output(:,15) = oneThirdOctaveFilterBank{15}(input); 
output(:,16) = oneThirdOctaveFilterBank{16}(input);
output(:,17) = oneThirdOctaveFilterBank{17}(input); 
output(:,18) = oneThirdOctaveFilterBank{18}(input);
output(:,19) = oneThirdOctaveFilterBank{19}(input); 
output(:,20) = oneThirdOctaveFilterBank{20}(input);
output(:,21) = oneThirdOctaveFilterBank{21}(input); 
output(:,22) = oneThirdOctaveFilterBank{22}(input);
output(:,23) = oneThirdOctaveFilterBank{23}(input); 
output(:,24) = oneThirdOctaveFilterBank{24}(input);
output(:,25) = oneThirdOctaveFilterBank{25}(input); 
output(:,26) = oneThirdOctaveFilterBank{26}(input);
output(:,27) = oneThirdOctaveFilterBank{27}(input); 
output(:,28) = oneThirdOctaveFilterBank{28}(input);
output(:,29) = oneThirdOctaveFilterBank{29}(input); 
output(:,30) = oneThirdOctaveFilterBank{30}(input);
output(:,31) = oneThirdOctaveFilterBank{31}(input);



temp = 10*log10(abs(timefilter(input.^2,timepar.NumF,timepar.DenF))/p0^2);
LgesF = temp(end);
temp = 10*log10(abs(timefilter(input.^2,timepar.NumS,timepar.DenS))/p0^2);
LgesS = temp(end);
for k = 1:31
    temp = 10*log10((timefilter(output(:,k).^2,timepar.NumF,timepar.DenF))/p0^2);
    L_tF(k) = temp(end);
    temp = 10*log10((timefilter(output(:,k).^2,timepar.NumS,timepar.DenS))/p0^2);
    L_tS(k) = temp(end);
end