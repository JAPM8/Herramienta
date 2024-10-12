%% Info
% Se realiza este nuevo código, pues trabajar con todo el conjunto de datos
% resultó en sesgos importantes a BCKG en la clasificación. Este nuevo
% acercamiento prioriza un dataset con mayor cantidad de casos SEIZ,
% buscando que le sea más fácil de reconocer al modelo.
clear; clc
%% Carga de datos

% Contiene las rutas de acceso para el dataset reducido
load MiniCorpusBalanceadoSEIZTUH.mat

% Extracción de rutas para cada set
rutasSgnTrain = set_train.Path;
rutasLblsTrain = cellfun(@(ruta) strrep(ruta,'.edf','_bi.csv'),rutasSgnTrain,UniformOutput = false);

rutasSgnDev = set_val.Path;
rutasLblsDev = cellfun(@(ruta) strrep(ruta,'.edf','_bi.csv'),rutasSgnDev,UniformOutput = false);

%% Se crean Datastores
% Ruta de acceso a datos CORPUS TUH SEIZURE
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

DS_sgn_train_ar = signalDatastore(rutasSgnTrain,"ReadFcn",@readTUHEDF);
DS_lbl_train_ar = fileDatastore(rutasLblsTrain,"ReadFcn",@read_lbl);

DS_sgn_dev_ar = signalDatastore(rutasSgnDev,"ReadFcn",@readTUHEDF);
DS_lbl_dev_ar = fileDatastore(rutasLblsDev,"ReadFcn",@read_lbl);

% Secuencia más pequeña 4096
DS_sgn_eval_ar = signalDatastore(fullfile(folderPath,"eval","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_eval_ar = fileDatastore(fullfile(folderPath,"eval","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

w_ventana = 256*60; % 60 segundos

DS_train_ar = combine(DS_sgn_train_ar, DS_lbl_train_ar);
DS_train_ar = transform(DS_train_ar,@(data) getlbls(data,w_ventana,1));
DS_train_ar = shuffle(DS_train_ar);

DS_dev_ar = combine(DS_sgn_dev_ar, DS_lbl_dev_ar);
DS_dev_ar = transform(DS_dev_ar,@(data) getlbls(data,w_ventana,1));
DS_dev_ar = shuffle(DS_dev_ar);

DS_eval_ar = combine(DS_sgn_eval_ar, DS_lbl_eval_ar);
DS_eval_ar = transform(DS_eval_ar,@(data) getlbls(data,w_ventana,3));
% DS_eval_ar = shuffle(DS_eval_ar);

function edf_val = readTUHEDF(filename)
    chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
                 "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
                 "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
                 "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
                 "EEG CZ-REF","EEG A1-REF","EEG A2-REF"]';

    edf_hdr = edfinfo(filename);
    edf_data = cell2mat(table2cell(edfread(filename,"SelectedSignals",chnl_list)));

    edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));
    edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));
    clear edf_hdr chnl_list
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
    clear edf_data
    
    if edf_Fs ~= 256
        [P,Q] = rat(256/edf_Fs);
        edf_montage = resample(edf_montage,P,Q);
        edf_Fs = 256;
        edf_samples = size(edf_montage,1);
    end

    edf_val = {edf_montage,edf_Fs,edf_samples};
end

function tbl_lbl = read_lbl(filename)
   % Detectar las opciones de importación, saltando las primeras 5 líneas
    opts = detectImportOptions(filename,"Delimiter",",","NumHeaderLines", 5);
    
    % Seleccionar solo las columnas 2 a la 4
    opts.SelectedVariableNames = opts.VariableNames(2:4);

    % Leer la tabla con las opciones especificadas
    tbl_lbl = readtable(filename, opts);   
end

function edf_set = getlbls(data,ventana,modo)

% Modo: 
% 1 -> Parte la señal en todas las ventanas posibles de ancho largo
% 2 -> Obtiene una ventana aleatoria de ancho largo de la señal
% 3 -> Señal completa

    edf_montage = data{1,1};
    Fs = data{1,2};
    sizeSet = data{1,3};
    lbls = data{1,4};
    largo = ventana;
    
    % Normalización
    edf_montage = edf_montage - mean(edf_montage,2); % Centrada en cero
    Max = max(edf_montage,[],"all");
    Min = min(edf_montage,[],"all");

    etiquetas = strings(sizeSet, 1);

    nr = height(lbls);
    for lbl_idx = 1:nr
        strt_lbl = lbls.start_time(lbl_idx);
        stop_lbl = lbls.stop_time(lbl_idx);
        lbl = lbls.label(lbl_idx);

        if strcmp(lbl,'seiz')
            % Convertir tiempo en segundos a índices de muestra
            strt_idx = ceil(strt_lbl * Fs)+1;
            stop_idx = min(sizeSet, ceil(stop_lbl * Fs)+1);

            % Asignar la etiqueta a las muestras correspondientes
            etiquetas(strt_idx:stop_idx,1) = "seiz";
        end
    end
            
    % etiquetas(etiquetas == "") = "n/a";
    % catg = {'n/a' 'bckg' 'seiz'};
    etiquetas(etiquetas == "") = "bckg";
    etiquetas = onehotencode(etiquetas,2,"ClassNames",["bckg" "seiz"]); % Se realiza pues es más rápido el entrenamiento
    
    if (sizeSet >= largo) && (modo == 1)
        numChunks = floor(sizeSet/largo);
        
        edf_montage = edf_montage(1:(numChunks*largo),:);
        etiquetas = etiquetas(1:(numChunks*largo),:);

        edf_montage = mat2cell(edf_montage,repmat(largo,1,numChunks));
        etiquetas = mat2cell(etiquetas,repmat(largo,1,numChunks));
    elseif (sizeSet >= largo) && (modo == 2)
        if ~ismember('seiz',etiquetas)
            i_indx = randperm(max(sizeSet-largo,1),1);
        else
            l_inf = find(etiquetas == 'seiz',1,"first");
            l_sup = find(etiquetas == 'seiz',1,"last");
            rng = l_sup - largo;
            
            if l_inf < rng
                i_indx = randi([l_inf, rng],1);
            else
                i_indx = max(rng,1);
            end
        end
        
        e_indx = i_indx + largo - 1;
        edf_montage = {edf_montage(i_indx:e_indx,:)};
        etiquetas = {etiquetas(i_indx:e_indx,:)};
    else
        edf_montage = {edf_montage};
        etiquetas = {etiquetas};
    end  
    
    edf_montage = cellfun(@(x) rescale(x,-1,1,"InputMin",Min,"InputMax",Max),edf_montage,'UniformOutput',false);
    edf_set = [edf_montage,etiquetas];
end

clearvars -except DS_train_ar DS_dev_ar DS_eval_ar w_ventana

%% Prueba lectura datastores
tallTrainSet = tall(DS_train_ar);
tallDevSet = tall(DS_dev_ar);

trainData = gather(tallTrainSet);
trainSgns = cellfun(@(x) dlarray(x,'TCB'),trainData(:,1),'UniformOutput',false);
trainLbls = trainData(:,2);

devData = gather(tallDevSet);
devSgns = cellfun(@(x) dlarray(x,'TCB'),devData(:,1),'UniformOutput',false);
devLbls = devData(:,2);

clearvars -except DS_eval_ar trainSgns trainLbls devSgns devLbls w_ventana

%% Verificación de labels
etiquetas = trainLbls;
etiquetas = vertcat(etiquetas{:});
% stas_etiquetas = countlabels(etiquetas)
stas_etiquetas1 = groupcounts(etiquetas);

etiquetas = devLbls;
etiquetas = vertcat(etiquetas{:});
stas_etiquetas2 = groupcounts(etiquetas);

%% Creación de red neuronal LSTM

LSTM_eegnet = dlnetwork;

layers = [sequenceInputLayer(22)
          cwtLayer("SignalLength",w_ventana,"Wavelet","amor","VoicesPerOctave",12,"TransformMode","squaremag")
          flattenLayer()
          lstmLayer(256,'OutputMode','sequence')
          lstmLayer(128,'OutputMode','sequence')
          fullyConnectedLayer(2)
          dropoutLayer(0.1)
          softmaxLayer];

LSTM_eegnet = addLayers(LSTM_eegnet,layers);
% modwtLayer("Wavelet","sym2","Level",3,"IncludeLowpass",false)
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

% Metricas
statsLSTM_eegnet = testnet(LSTM_eegnet,devSgns,devLbls,{"accuracy",lossFcn},"MiniBatchSize",5);

% Realizar predicciones sobre las señales
yhat = minibatchpredict(LSTM_eegnet,devSgns,"MiniBatchSize",3,"UniformOutput",false);
yhat2 = cellfun(@(x) reshape(extractdata(x),[],2),yhat,UniformOutput=false);
y = devLbls;

plotconfusion(cell2mat(y(:))',cell2mat(yhat2(:))');


%% Prueba de todos
i = 1000;
sgns = devSgns{i,1};
lbls = devLbls{i,1};
lbls = onehotdecode(lbls,{'bckg' 'seiz'},2);

score = predict(LSTM_eegnet,sgns,"InputDataFormats","TCB");
Ypred = scores2label(score,{'bckg' 'seiz'});

figure(2)
confusionchart([lbls(:)],[Ypred(:)],'Normalization','row-normalized');
%%
tall_eval = tall(DS_eval_ar);

% Realizar predicciones sobre las señales
YPred = minibatchpredict(LSTM_eegnet, DS_eval_ar,MiniBatchSize = 1,UniformOutput=false);

% Extraer las etiquetas verdaderas (segunda columna)
YTrue = tall_eval(:, 2);

% Reunir resultados con gather
YTrue_gathered = gather(YTrue);
YTrue_f = onehotdecode(cell2mat(YTrue_gathered),{'bckg' 'seiz'},2,"categorical");

YPred_f = scores2label(cell2mat(YPred),{'bckg' 'seiz'});

figure(2)
confusionchart([YTrue_f(:)],[YPred_f(:)],'Normalization','total-normalized');