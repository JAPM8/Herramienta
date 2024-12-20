%% Código realizado por: Javier Alejandro Pérez Marín (20183)
% Funcional 2024A-2024B
% CORRA ESTE CÓDIGO POR SECCIONES

%   Se recomienda leer sección relacionada a redes RNN y capítulo #

%   Este script utiliza el CORPUS tuh_eeg_seizure v2.0.3, el cual contiene
%   estudios EEG anotados con enfoque a detección de crisis epilépticas. 

%   En este, se plantean distintas estructuras de red RNN trabajadas, se
%   detalla las opciones de entrenamiento trabajadas, las métricas
%   empleadas y la validación de la red.

% Requiere los archivos: "MiniCorpusBalanceadoSEIZTUH.mat"

%% Carga de datos

% Contiene las rutas de acceso para el dataset reducido
%   Este dataset es equilibrado entre clases para el subconjunto de
%   entrenamiento, el subconjunto de validación solo cumple con ser de la
%   misma duración. El subconjunto de evaluación considera todos los casos.
load MiniCorpusBalanceadoSEIZTUH.mat

% Se obtienen las rutas de los subconjuntos específicos entrenamiento/validación
%   Note que el .mat contiene las rutas a los archivos EDF por ello se
%   manipulan para obtener las rutas de las etiquetas
rutasSgnTrain = set_train.Path;
rutasLblsTrain = cellfun(@(ruta) strrep(ruta,'.edf','_bi.csv'),rutasSgnTrain,UniformOutput = false);

rutasSgnDev = set_val.Path;
rutasLblsDev = cellfun(@(ruta) strrep(ruta,'.edf','_bi.csv'),rutasSgnDev,UniformOutput = false);

%% Lectura de datasets con Datastores

% Ruta de acceso a datos CORPUS TUH SEIZURE
%   Cambie la ruta a la de su computadora
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% Datastores de entrenamiento montaje AR
%   Funciones definidas al final de la sección
DS_sgn_train_ar = signalDatastore(rutasSgnTrain,"ReadFcn",@readTUHEDF);
DS_lbl_train_ar = fileDatastore(rutasLblsTrain,"ReadFcn",@read_lbl);

% Datastores de development/validación montaje AR
%   Funciones definidas al final de la sección
DS_sgn_dev_ar = signalDatastore(rutasSgnDev,"ReadFcn",@readTUHEDF);
DS_lbl_dev_ar = fileDatastore(rutasLblsDev,"ReadFcn",@read_lbl);

% Datastores de evaluación montaje AR (secuencia más pequeña 4096 muestras)
%   Funciones definidas al final de la sección
DS_sgn_eval_ar = signalDatastore(fullfile(folderPath,"eval","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_eval_ar = fileDatastore(fullfile(folderPath,"eval","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

% Parámetro de longitud que se utiliza para dividir las señales en ventanas
w_ventana = 60*256; %1 minuto con Fs de 256 Hz

% Procesamiento de señales y etiquetas de entrenamiento, posteriormente se mezclan
DS_train_ar = combine(DS_sgn_train_ar, DS_lbl_train_ar);
DS_train_ar = transform(DS_train_ar,@(data) getlbls(data,w_ventana,3));
DS_train_ar = shuffle(DS_train_ar);

% Procesamiento de señales y etiquetas de validación, posteriormente se mezclan
DS_dev_ar = combine(DS_sgn_dev_ar, DS_lbl_dev_ar);
DS_dev_ar = transform(DS_dev_ar,@(data) getlbls(data,w_ventana,3));
DS_dev_ar = shuffle(DS_dev_ar);

% Procesamiento de señales y etiquetas de evaluación
DS_eval_ar = combine(DS_sgn_eval_ar, DS_lbl_eval_ar);
DS_eval_ar = transform(DS_eval_ar,@(data) getlbls(data,w_ventana,3));
% DS_eval_ar = shuffle(DS_eval_ar);

% Funciones de lectura de datastores
function edf_val = readTUHEDF(filename)
% Función de lectura para datastores de señales al hacer read de estos

    % Canales disponibles para estudios con montaje tipo AR
    %   Montajes LE o AR_A cambian los canales disponibles
    chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
                 "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
                 "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
                 "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
                 "EEG CZ-REF","EEG A1-REF","EEG A2-REF"]';
    
    % Se obtiene header del EEG, este contiene la información de registro 
    edf_hdr = edfinfo(filename);

    % Se lee canales seleccionados en "chnl_list" de EEG
    %   Note que la función devuelve una tabla que se convierte a cell (table2cell)
    %   y luego el cell se convierte a array (cell2mat)
    edf_data = cell2mat(table2cell(edfread(filename,"SelectedSignals",chnl_list)));

    % Se obtiene frecuencia de muestreo del estudio 
    edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));

    % Se obtiene cantidad de muestras del estudio
    edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));

    clear edf_hdr chnl_list % Limpieza de variables ya no útiles
    
    % Se obtiene montaje tipo AR, es decir, se restan los canales como indica
    % comentario al lado de cada fila
    edf_montage = [edf_data(:,1) - edf_data(:,11),...   % FP1-F7
                   edf_data(:,11) - edf_data(:,13),...  % F7-T3
                   edf_data(:,13) - edf_data(:,15),...  % T3-T5
                   edf_data(:,15) - edf_data(:,9),...   % T5-O1
                   edf_data(:,2) - edf_data(:,12),...   % FP2-F8
                   edf_data(:,12) - edf_data(:,14),...  % F8-T4
                   edf_data(:,14) - edf_data(:,16),...  % T4-T6
                   edf_data(:,16) - edf_data(:,10),...  % T6-O2
                   edf_data(:,18) - edf_data(:,13),...  % A1-T3
                   edf_data(:,13) - edf_data(:,5),...   % T3-C3
                   edf_data(:,5) - edf_data(:,17),...   % C3-CZ
                   edf_data(:,17) - edf_data(:,6),...   % CZ-C4
                   edf_data(:,6) - edf_data(:,14),...   % C4-T4
                   edf_data(:,14) - edf_data(:,19),...  % T4-A2
                   edf_data(:,1) - edf_data(:,3),...    % FP1-F3
                   edf_data(:,3) - edf_data(:,5),...    % F3-C3
                   edf_data(:,5) - edf_data(:,7),...    % C3-P3
                   edf_data(:,7) - edf_data(:,9),...    % P3-O1
                   edf_data(:,2) - edf_data(:,4),...    % FP2-F4
                   edf_data(:,4) - edf_data(:,6),...    % F4-C4
                   edf_data(:,6) - edf_data(:,8),...    % C4-P4
                   edf_data(:,8) - edf_data(:,10)];     % P4-O2
    
    clear edf_data % Limpieza de variables ya no útiles
    
    % Se trabaja resampling a 256 Hz porque es la Fs dominante en el dataset
    if edf_Fs ~= 256
        % Se obtiene fracción que permite la conversión entre Fs
        [P,Q] = rat(256/edf_Fs);

        % Se aplica resampling al EEG
        %  Verifique documentación de la función pues aplica filtro
        %  anti-aliasing, en este caso no se modifica el default
        edf_montage = resample(edf_montage,P,Q);

        % Se actualizan variables del estudio
        edf_Fs = 256;
        edf_samples = size(edf_montage,1);
    end
    
    % Se retornan valores de la función como cell
    edf_val = {edf_montage,edf_Fs,edf_samples};
end

function tbl_lbl = read_lbl(filename)
% Función de lectura para datastores de etiquetas al hacer read de estos

   % Detectar las opciones de importación, saltando las primeras 5 líneas y
   % usando las comas "," de separador de columna
    opts = detectImportOptions(filename,"Delimiter",",","NumHeaderLines", 5);
    
    % Seleccionar solo las columnas 2 a la 4
    %   Estas contienen tiempo inicio, tiempo fin y etiqueta respectivamente
    opts.SelectedVariableNames = opts.VariableNames(2:4);

    % Leer la tabla con las opciones especificadas
    tbl_lbl = readtable(filename, opts);   
end

function edf_set = getlbls(data,ventana,modo)
% Función de lectura de datastore transformado, en esta se normalizan las
% señales en el rango de [-1 1] con centro en cero, también la tabla de
% etiquetas se convierte a vector de etiquetas con etiqueta para cada
% muestra. La función contiene 3 (todos los modos normalizan la señal):
%   modo = 1 -> Devuelve todos los fragmentos posibles de ancho = ventana de
%               las señales y sus etiquetas.
%   modo = 2 -> Devuelve una ventana aleatoria de ancho = ventana de las
%               señales y sus etiquetas. Prioriza fragmentos con etiqueta de
%               convulsión "seiz".
%   modo = 3 -> Devuelve las señales y etiquetas sin cortar.

    % División de parámetros de la función
    edf_montage = data{1,1};
    Fs = data{1,2};
    sizeSet = data{1,3};
    lbls = data{1,4};
    largo = ventana;
    
    % Se centran las señales en cero
    %   Se obtiene la media por cada canal (columna) y se le resta a c/u
    edf_montage = edf_montage - mean(edf_montage,2);

    % Se obtiene máximo y mínimo global de las señales
    Max = max(edf_montage,[],"all");
    Min = min(edf_montage,[],"all");
    
    % Se genera vector para etiquetas
    etiquetas = strings(sizeSet, 1);
    
    % ciclo que recorre todas las filas de la tabla de etiquetas
    nr = height(lbls);
    for lbl_idx = 1:nr
       
        % Se obtiene etiqueta de la fila
        lbl = lbls.label(lbl_idx);
        
        % Si la etiqueta es "seiz" -> Convulsión
        if strcmp(lbl,'seiz')

            % Se obtiene tiempo de inicio de etiqueta (en segundos)
            strt_lbl = lbls.start_time(lbl_idx);

            % Se obtiene tiempo de fin de etiqueta (en segundos)
            stop_lbl = lbls.stop_time(lbl_idx);

            % Convertir tiempo de inicio a índice del array
            strt_idx = ceil(strt_lbl * Fs) + 1;
            
            % Convertir tiempo de fin a índice del array
            %   Note que la función "min" garantiza que no se supere la
            %   cantidad de muestras del EEG con la operación
            stop_idx = min(sizeSet, ceil(stop_lbl * Fs)+1);

            % Asignar la etiqueta a las muestras correspondientes
            etiquetas(strt_idx:stop_idx,1) = "seiz";
        end
    end
    
    % Muestras sin etiquetas se asignan a la etiqueta no convulsión "bckg"
    etiquetas(etiquetas == "") = "bckg";

    % Etiquetas se codifican en formato one-hot
    %   Esto se realiza para tener una representación simple 
    etiquetas = onehotencode(etiquetas,2,"ClassNames",["bckg" "seiz"]);
    
    if (sizeSet >= largo) && (modo == 1)

        % Cantidad de ventanas posibles de ancho = largo
        numChunks = floor(sizeSet/largo);
        
        % Se limitan las señales y etiquetas a la cantidad de ventanas posibles
        edf_montage = edf_montage(1:(numChunks*largo),:);
        etiquetas = etiquetas(1:(numChunks*largo),:);
        
        % Se corta las señales y etiquetas en las ventanas posibles
        %   Note que repmat da la distribución de filas (largo de ventana)
        edf_montage = mat2cell(edf_montage,repmat(largo,1,numChunks));
        etiquetas = mat2cell(etiquetas,repmat(largo,1,numChunks));

    elseif (sizeSet >= largo) && (modo == 2)

        % Si no existe etiqueta "seiz" en estudio
        if ~ismember('seiz',etiquetas)
            % Se obtiene índice inicial aleatorio para ventana
            i_indx = randperm(max(sizeSet-largo,1),1);
        else

            % Se obtiene primer índice de etiqueta "seiz"
            l_inf = find(etiquetas == 'seiz',1,"first");

            % Se obtiene último índice de etiqueta "seiz"
            l_sup = find(etiquetas == 'seiz',1,"last");

            % Índice inicial de ventana a partir de lím. superior
            rng = l_sup - largo;
            
            % Si la primer etiqueta de "seiz" está antes que índice inicial
            if l_inf < rng
                
                % Se obtiene índice inicial aleatorio entre primer etiqueta
                % y el índice inicial obtenido anteriormente
                i_indx = randi([l_inf, rng],1);
            
            else
                
                % Índice inicial máximo entre primer muestra e índice inicial obtenido anteriormente
                i_indx = max(rng,1);

            end

        end
        
        % Índice final a partir del inicial más el largo de ventana
        e_indx = i_indx + largo - 1;

        % Se obtiene ventana aleatoria de señales y etiquetas
        edf_montage = {edf_montage(i_indx:e_indx,:)};
        etiquetas = {etiquetas(i_indx:e_indx,:)};
    else
        % Cuando modo = 3 o la longitud de las señales es menor al ancho de la ventana
        % Se devuelve señales y etiquetas sin cortar
        edf_montage = {edf_montage};
        etiquetas = {etiquetas};

    end  
    
    % Reescalamiento de cada canal de la señal en el rango de [-1 1] con mínimo y máximo global
    edf_montage = cellfun(@(x) rescale(x,-1,1,"InputMin",Min,"InputMax",Max),edf_montage,'UniformOutput',false);
    
    % Se devuelven señales y etiquetas procesadas
    edf_set = [edf_montage,etiquetas];

end

clearvars -except DS_train_ar DS_dev_ar DS_eval_ar w_ventana

%% Lectura mediante tall arrays y función gather datasets
tallTrainSet = tall(DS_train_ar);
tallDevSet = tall(DS_dev_ar);
tallEvalSet = tall(DS_eval_ar);

trainData = gather(tallTrainSet);
trainSgns = cellfun(@(x) dlarray(x,'TCB'),trainData(:,1),'UniformOutput',false);
trainLbls = trainData(:,2);

devData = gather(tallDevSet);
devSgns = cellfun(@(x) dlarray(x,'TCB'),devData(:,1),'UniformOutput',false);
devLbls = devData(:,2);

tallData = gather(tallEvalSet);
evalSgns = tallData(:,1);
evalLbls = tallData(:,2);

clearvars -except trainSgns trainLbls devSgns devLbls evalSgns evalLbls w_ventana

%% Verificación de labels
etiquetas = trainLbls;
etiquetas = vertcat(etiquetas{:});
stas_etiquetas1 = groupcounts(etiquetas);

etiquetas = devLbls;
etiquetas = vertcat(etiquetas{:});
stas_etiquetas2 = groupcounts(etiquetas);

%% Creación de red neuronal BILSTM
% BILSTM_eegnet = dlnetwork;
% 
% layers = [sequenceInputLayer(22,"Normalization","zscore","NormalizationDimension","channel")
%           bilstmLayer(200,'OutputMode','sequence')
%           dropoutLayer(0.2)
%           bilstmLayer(150,'OutputMode','sequence')
%           dropoutLayer(0.2)
%           fullyConnectedLayer(2)
%           softmaxLayer];
% 
% BILSTM_eegnet = addLayers(BILSTM_eegnet,layers);

%% Creación de red neuronal LSTM

% LSTM_eegnet = dlnetwork;
% 
% layers = [sequenceInputLayer(22)
%           lstmLayer(100,'OutputMode','sequence')
%           dropoutLayer(0.2)
%           lstmLayer(75,'OutputMode','sequence')
%           dropoutLayer(0.2)
%           fullyConnectedLayer(2)
%           softmaxLayer];
% 
% LSTM_eegnet = addLayers(LSTM_eegnet,layers);
% LSTM_eegnet = initialize(LSTM_eegnet);
%% Creación de red neuronal LSTM

LSTM_eegnet = dlnetwork;

layers = [sequenceInputLayer(22)
          modwtLayer("Wavelet","sym2","Level",3,"IncludeLowpass",false)
          flattenLayer()
          lstmLayer(256,'OutputMode','sequence')
          lstmLayer(128,'OutputMode','sequence')
          fullyConnectedLayer(2)
          dropoutLayer(0.1)
          softmaxLayer];

LSTM_eegnet = addLayers(LSTM_eegnet,layers);
% cwtLayer("SignalLength",w_ventana,"Wavelet","amor","VoicesPerOctave",12,"TransformMode","squaremag")
%% Opciones entrenamiento LSTM
options = trainingOptions("sgdm", ...
                          Plots = "training-progress", ...
                          Metrics = "accuracy", ...
                          Shuffle = "every-epoch", ...
                          MiniBatchSize = 10, ...  
                          ValidationData = {devSgns,devLbls}, ...
                          ValidationFrequency = 10, ...
                          Verbose = true, ....
                          MaxEpochs = 80, ... 
                          InitialLearnRate = 1e-4, ... 
                          GradientThreshold = 1, ...
                          OutputNetwork = "last-iteration", ...
                          ExecutionEnvironment = "auto");  

lossFcn = @(Y,T) crossentropy(Y,T, ...
                              Weights = [0.1, 0.9], ...
                              NormalizationFactor = "all-elements", ...
                              WeightsFormat = "UC");

[LSTM_eegnet, infoLSTM] = trainnet(trainSgns,trainLbls,LSTM_eegnet,lossFcn,options);

% GradientThreshold = 1, ...
% ObjectiveMetricName = "accuracy", ...
% Shuffle = "every-epoch", ...
% ValidationData = {devData(:,1),devData(:,2)}, ...
% ValidationFrequency = 26, ...
% InputDataFormats = "TCB", ...

%% Puesta a prueba de red
validacionComp = false;

if validacionComp
    yhat = minibatchpredict(LSTM_eegnet,evalSgns,"MiniBatchSize",4,"UniformOutput",false);
    y = evalLbls;
else
    % Metricas
    statsLSTM_eegnet = testnet(LSTM_eegnet,devSgns,devLbls,{"accuracy",lossFcn},"MiniBatchSize",5);
    
    % Realizar predicciones sobre las señales
    yhat = minibatchpredict(LSTM_eegnet,devSgns,"MiniBatchSize",4,"UniformOutput",false);
    yhat = cellfun(@(x) reshape(extractdata(x),[],2),yhat,UniformOutput=false);
    y = devLbls;
end

figure(1)
plotconfusion(cell2mat(y(:))',cell2mat(yhat(:))');
