%Función para obtener la primera versión de características de morfología. 
%En cada ventana de tiempo, se obtiene el espectro de frecuencias, se
%obtiene la magnitud de cada banda (delta, theta, alpha y beta), se obtiene
%la media de las 4 magnitudes y se cuantifica qué tanto está alejada la
%magnitud de la banda respecto de la media obtenida. Si la banda es mayor,
%el valor será >1, si es menor, será <1.
function [Matriz_FMorfologia] = FeaturesMorf(edf,fs,canales,muestras)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con señal EEG a analizar
%canales: número de canales para encontrar features
%muestras: número de muestras para realizar ventanas
%c: canales a encontrar las características
%Se arreglan las dimensiones para que se tengan vectores fila en caso
%la señal venga en vectores columna.

%Arreglamos el vector para que sea vector columna
if size(edf,1)>size(edf,2)
    edf = edf';
end
%Encontramos el número de canales a analizar, si es 0 se analizan todos:
if (canales(1)==0)
    no_canales = min(size(edf)); %El # de canales total es la dimensión más pequeña del EDF
    canales = 1:1:no_canales;
else
    no_canales = length(canales);
end
%Encontramos el número entero de ventanas posibles
if(((length(edf)/muestras)-round(length(edf)/muestras))<0)
    size_cint = round(length(edf)/muestras)-1;
else
    size_cint = round(length(edf)/muestras);
end
%Se genera la matriz de salida, llena de ceros
Matriz_FMorfologia = zeros(4*no_canales,size_cint);
[~,MMC] = size(Matriz_FMorfologia); %Se obtienen la cantidad de datos de
% las filas y columnas
wliminf = 1; %índice inferior de la primera ventana
wlimsup = muestras; %índice superior de la primera ventana
mliminf = 1;%índice inferior para colocar en la matriz
mlimsup = 4;%índice superior para colocar en la matriz
for i=1:MMC
    for j=1:no_canales
        %j
        ventana_interes = edf(canales(j),wliminf:wlimsup);        
        %Cálculo de las características de morfología
        WS = fft(ventana_interes);
        WSn = abs(WS/muestras);
        WS1_1=WSn(1:muestras/2+1);
        WS1_1(2:end-1) = 2*WS1_1(2:end-1);
        WS1_1 = (WS1_1).^2; %Espectro de potencia
        
        delta = sum(WS1_1(1,1:5));
        theta = sum(WS1_1(1,6:9));
        alpha = sum(WS1_1(1,10:13));
        beta = sum(WS1_1(1,14:31));
        DeltaMatrix = [(delta/delta)>=1.3,(delta/theta)>=1.3,(delta/alpha)>=1.3,(delta/beta)>=1.3];
        ThetaMatrix = [(theta/delta)>=1.3,(theta/theta)>=1.3,(theta/alpha)>=1.3,(theta/beta)>=1.3];
        AlphaMatrix = [(alpha/delta)>=1.3,(alpha/theta)>=1.3,(alpha/alpha)>=1.3,(alpha/beta)>=1.3];
        BetaMatrix = [(beta/delta)>=1.3,(beta/theta)>=1.3,(beta/alpha)>=1.3,(beta/beta)>=1.3];
        %Matrix30 = [DeltaMatrix;ThetaMatrix;AlphaMatrix;BetaMatrix];
        Matriz_FMorfologia(mliminf:mlimsup,i) = [sum(DeltaMatrix), sum(ThetaMatrix),...
                                                sum(AlphaMatrix), sum(BetaMatrix)]'; 
        %Nos desplazamos al siguiente canal
        mliminf = mlimsup+1;
        mlimsup = mliminf+3;
    end
    wliminf = wlimsup+1;
    wlimsup = wliminf+muestras-1;
    mliminf = 1;
    mlimsup = 4;
end
end