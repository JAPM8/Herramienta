function [zc] = ZC(eeg, umbral)
signo = 1;
zc=[];
mav=[];
totZC=0;
for i = 1:length(eeg)
    signo = sign(eeg(i))+signo;
   
    %Si es positivo
    if signo == 2;
        signo = 1;
        zc(i)=0;
    elseif signo == 0;
        zc(i)=1;
        totZC=totZC+1;
    elseif signo == -2;
        signo = -1;
        zc(i)=0;
    else
        zc(i)=0;
    end 
    i = i+1;
    
end
end



