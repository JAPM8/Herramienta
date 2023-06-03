
function [Matriz_features,channel_ventana,c] = Features(edf,fs,canales,muestras,c,op)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con señal EEG a analizar
%canales: número de canales para encontrar features (1-4)
%muestras: número de muestras para realizar ventanas
%op=0 vector de opciones

%arreglar dimension
if size(edf,1)>size(edf,2)
    edf = edf';
end
ctot = size(edf,1);
eeg = zeros(length(edf),canales);
if c==0
%Definir canales a analizar
    canales = ctot;
    eeg = edf';
else
    for i=1:canales
        eeg(:,i)= edf(c(i),:)';
    end
end
%Preprocesamiento: FILTROS
Fs = fs;
fred_electrica = designfilt('bandstopiir','FilterOrder',2, ...
                'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
                'DesignMethod','butter','SampleRate',Fs);
fruido = designfilt('bandstopiir','FilterOrder',4, ...
                'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',60, ...
                'DesignMethod','butter','SampleRate',Fs);

channels = filtfilt(fred_electrica,eeg);  
channels = filtfilt(fruido,eeg);  %contenido espectral EEG 0.5-60Hz

%  for i=1:canales
%      %Normalizar señales
%      channels(:,i) = channels(:,i)/max(abs(channels(:,i)));
%  end
%Realizar ventana
k=1;        %recorrer canales
i=1;        %recorrer muestras
j=0;
flag=0;
size_c = length(channels);
channel_ventana = zeros(size_c,canales);
if mod(size_c/muestras,1)~=0 %si es decimal
    size_cint = round(size_c/muestras)-1;
else
   size_cint = size_c/muestras; 
end
z = zeros(length(eeg),canales);
zc = zeros(size_cint,canales);
mav = zeros(size_cint,canales);
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
            mav(flag,k) = mean(abs(channel_ventana((j*muestras)+1:i,k)));
            desviacion(flag,k) = std(channel_ventana(:,k));
            curtosis(flag,k) = kurtosis(channel_ventana(:,k));
            %picos = findpeaks(channel_ventana(:,k)');
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
            %fmax(flag,k)=max(picos);
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
%c = comb(x,i);
a=0;
b=0;

for i=1:canales
  totfeatures(:,i+a:((i+a)+3)) = [desviacion(:,i),curtosis(:,i),zc(:,i),mav(:,i)];
  a=a+3;
end
resta=1;
for j=1:canales
for i=1:4
   if op(i)==1 
       vfeatures(:,resta) = totfeatures(:,i); %eliminar columna no deseada
       resta=resta+1;  
   end
end

end
Matriz_features = vfeatures;
end

