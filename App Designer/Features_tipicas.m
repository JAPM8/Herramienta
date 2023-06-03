
function [Matriz_features,c] = Features_tipicas(edf,fs,canales,muestras,c,op)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con señal EEG a analizar
%canales: número de canales para encontrar features (1-4)
%muestras: número de muestras para realizar ventanas
%op=0 vector de opciones [111111] Media , mav, zc, Amax, std, crutosis
%arreglar dimension

eeg(:,1)= edf';


%Preprocesamiento: FILTROS
Fs = fs;
fred_electrica = designfilt('bandstopiir','FilterOrder',2, ...
                'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
                'DesignMethod','butter','SampleRate',Fs);
fruido = designfilt('bandstopiir','FilterOrder',4, ...
                'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',60, ...
                'DesignMethod','butter','SampleRate',Fs);

channels = filtfilt(fred_electrica,eeg);  
%channels = filtfilt(fruido,eeg);  %contenido espectral EEG 0.5-60Hz

%  for i=1:canales
%      %Normalizar señales
%      channels(:,i) = channels(:,i)/max(abs(channels(:,i)));
%  end
%Realizar ventana
k=1;        %recorrer canales
i=1;        %recorrer muestras
j=0;
j1=0;
flag=0;
size_c = length(channels);
channel_ventana = zeros(size_c,canales);
if mod(size_c/muestras,1)~=0 %si es decimal
    size_cint = round(size_c/muestras);
    if size_cint>(size_c/muestras)
        size_cint= size_cint-1;
    end       
else
   size_cint = size_c/muestras; 
end
media = zeros(size_cint,canales);
mav = zeros(size_cint,canales);
z = zeros(length(eeg),canales);
zc = zeros(size_cint,canales);
fmax = zeros(size_cint,canales);
desviacion = zeros(size_cint,canales);
curtosis = zeros(size_cint,canales);
%zero crossing index function
max_amplitud = max(abs(channels))*0.02; % 2% de la amplitud de la señal 
umbral = max(max_amplitud);
for i=1:canales
   z(:,i) =  ZC(channels(:,i),umbral)'; %Calcular todos los ZC de la señal
end
while(1)
     
     channel_ventana(i,k) = channels(i,k); 
     i = i+1;
        if(mod(i,(muestras))==0)      %Calcular caracteristicas de cada ventana
            flag = flag+1;
            if op(1)==1
                media(flag,k) = mean(channel_ventana((j1*muestras)+1:i,k));
            elseif op(2) ==1
                mav(flag,k) = mean(abs(channel_ventana((j1*muestras)+1:i,k)));
            elseif op(4)==1
                picos = findpeaks(channel_ventana((j1*muestras)+1:i,k)');
                fmax(flag,k)=max(abs(picos)); 
            elseif op(5)==1
                desviacion(flag,k) = std(channel_ventana((j1*muestras)+1:i,k));    
            elseif op(6)==1
                 curtosis(flag,k) = kurtosis(channel_ventana((j1*muestras)+1:i,k));
            elseif op(3)==1
            if(j>0) %contar ZC por cada ventana
                for o=1:canales
                    zc(flag,o) = sum(z(j*muestras:i,o) == 1);
                end  
            else
                for o=1:canales
                     zc(flag,o) = sum(z(1:(i-1),o) == 1);
                end 
            end
            j= j+1;
            end 
            j1=j1+1; 
        end
         
     if (i==size_c) 
            k=k+1;
            flag=0;
            i=1; 
            j=0;   
     end  
     if(k>canales)
            break;
     end
   
end
%Concatenar vector de características
a=0;
b=0;

totfeatures(:,1:6) = [media(:,i),mav(:,i),zc(:,i),fmax(:,i), desviacion(:,i),curtosis(:,i)];



for i=1:6
   if op(i)==1 
       vfeatures(:,1) = totfeatures(:,i); 
   end
end
Matriz_features = vfeatures;
end

