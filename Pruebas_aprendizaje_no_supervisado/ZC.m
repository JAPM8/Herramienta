%% Zero Crossing (ZC) counter
%  Author: Luis Alberto Rivera

%  This function counts how many times the sign of a particular signal changes.
%  Assuming that the signal is continuous in time, the calculated number
%  is a lower bound to the number of zero crossings of the signal.
%  This function sets to zero all signal points with absolute value below the
%  specified threshold. Then, it counts how many times the compensated
%  signal changes sign.
%  The function is not otpimized in the Matlab sense (matrix and vector
%  operations), because it is to be translated into a C function.
%  Inputs:   y - the signal to be analyzed.
%          thr - threshold, to compensate ZC due to noise
%  Outputs: estimated number of zero crossings. 
function zc = ZC(y, thr)

L = length(y);
y_fixed = y;
zc = 0;     % initialize counter
pivot = 0;
pivotsign = 0;

for l = 1:L
    if(((y(l) > 0) && (y(l) <= thr)) || ((y(l) < 0) && (y(l) >= -thr)))
        y_fixed(l) = 0;
    else
        y_fixed(l) = y(l);  % only necessary in the C version, since y_fixed
                            % would not be initialized.
    end
    
    % determine where the first nonzero value is
    if(pivotsign == 0)
        if(y_fixed(l) > 0)
            pivot = l;
            pivotsign = 1;
        elseif(y_fixed(l) < 0)
            pivot = l;
            pivotsign = -1;
        end
    end
end

% Count how many sign changes there are. A zero is considered the same sign
% as the previous one.
for j = (pivot+1):L
   if((y_fixed(j) > 0) && (pivotsign == -1))
       zc = zc + 1;
       pivotsign = 1;
   elseif((y_fixed(j) < 0) && (pivotsign == 1))
       zc = zc + 1;
       pivotsign = -1;
   end
end

end

% function [zc] = ZC(eeg, umbral)
% signo = 1;
% zc=zeros(1,length(eeg)); %(CP)
% %mav=[];    %(CP)
% totZC=0;
% for i = 1:length(eeg)
%     signo = sign(eeg(i))+signo;
% 
%     %Si es positivo %(CP) ;
%     if signo == 2
%         signo = 1;
%         zc(i)=0;
% 
%     elseif signo == 0
%         totZC=totZC+1;
%         zc(i)=1;
% 
%     elseif signo == -2
%         signo = -1;
%         zc(i)=0;
% 
%     else
%         zc(i)=0;
%     end 
%     % i = i+1; %(CP)
% 
% end
% end



