function [L_pF,L_pS]= OneThirdOctaveAnalyser(timeF,timeS,input,oneThirdOctaveFilterBank,Nfc,fs) 


tauF = timeF*fs;
tauS = timeS*fs;
p0 = 20*10^(-6);

for i=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
    output(:,i) = oneThirdOctaveFilter(input);   
    p_eF(i) = ((1/tauF)*trapz(output(:,i).^2.*exp(([1:length(output(:,i))]-length(output(:,i)))/tauF)'))^(1/2);
    p_eS(i) = ((1/tauS)*trapz(output(:,i).^2.*exp(([1:length(output(:,i))]-length(output(:,i)))/tauS)'))^(1/2);
    L_pF(i) = 20*log10((p_eF(i)/p0));
    L_pS(i) = 20*log10((p_eS(i)/p0));
end