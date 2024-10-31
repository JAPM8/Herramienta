%% Código realizado por: Javier Alejandro Pérez Marín (20183)
% Funcional 2024A-2024B
% CORRA ESTE CÓDIGO POR SECCIONES

%% Lectura de datasets con Datastores

% Ruta de acceso a datos CORPUS TUH SEIZURE
%   Cambie la ruta a la de su computadora
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% Datastores de development/validación montaje AR
%   Funciones definidas al final de la sección
ds_sgn = signalDatastore(fullfile(folderPath,"train","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
ds_lbls = fileDatastore(fullfile(folderPath,"train","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

% Parámetro de longitud que se utiliza para dividir las señales en ventanas
w_ventana = 20*60*256; %20 minutos con Fs de 256 Hz

ds_train = combine(ds_sgn, ds_lbls);
ds_train = transform(ds_train,@(data) getlbls(data,w_ventana,3));
ds_train = shuffle(ds_train);

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
    
    des_Fs = 256;
    % Se trabaja resampling a des_Fs Hz
    if edf_Fs ~= des_Fs
        % Se obtiene fracción que permite la conversión entre Fs
        [P,Q] = rat(des_Fs/edf_Fs);

        % Se aplica resampling al EEG
        %  Verifique documentación de la función pues aplica filtro
        %  anti-aliasing, en este caso no se modifica el default
        edf_montage = resample(edf_montage,P,Q);

        % Se actualizan variables del estudio
        edf_Fs = des_Fs;
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
    desvesta = std(edf_montage,0,2);
    desvesta(desvesta == 0) = 1;
    edf_montage = normalize(edf_montage,2,"center","mean")./desvesta;

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

clearvars -except ds_train w_ventana

%% Lectura en memoria

sgns = cell(100,1);
lbls = cell(100,1);
i = 0;

while hasdata(ds_train) && (i <= 100)
    set = read(ds_train);
    setS = set{1,1};
    setL = set{1,2};

    samples = length(setS);
    seizSamples = sum(setL(:,2));

    if (samples <= w_ventana) && (seizSamples >= 0.3*samples) && (seizSamples <= 0.8*samples)
        sgns{i+1} = setS;
        lbls{i+1} = setL;
        i = i + 1;
        disp(i);
    end
end

sgns(any(cellfun(@isempty, sgns), 2), :) = [];
lbls(any(cellfun(@isempty, lbls), 2), :) = [];

%% Separando en subsets

load("MiniCorpusSEIZ3080P_menos20mins_zscore_TUH.mat");

[trainInd,valInd,testInd] = dividerand(length(lbls),0.7,0.2,0.1);

trainSgns = sgns(trainInd);
trainSgns = cellfun(@(x) dlarray(x,'TCB'),trainSgns,'UniformOutput',false);
trainLbls = lbls(trainInd);

lbls_j = cell2mat(trainLbls(:));
weights = length(lbls_j)./(2*sum(lbls_j));

valSgns = sgns(valInd);
valSgns = cellfun(@(x) dlarray(x,'TCB'),valSgns,'UniformOutput',false);
valLbls = lbls(valInd);

evalSgns = sgns(testInd);
evalSgns = cellfun(@(x) dlarray(x,'TCB'),evalSgns,'UniformOutput',false);
evalLbls = lbls(testInd);

clearvars -except trainSgns trainLbls valSgns valLbls evalSgns evalLbls weights

%% Creación de red neuronal TCN
numFeatures = 22;
numClasses = 2;

numFilters = 100;
filterSize = 10;
dropoutFactor = 0.15;
numBlocks = 16;

net = dlnetwork;

layer = sequenceInputLayer(numFeatures,Name="input");

net = addLayers(net,layer);

outputName = layer.Name;

for i = 1:numBlocks
    dilationFactor = 2^(i-1);
    
    layers = [
        convolution1dLayer(filterSize,numFilters,DilationFactor=dilationFactor,Padding="causal",Name="conv1_"+i,WeightsInitializer="he")
        layerNormalizationLayer
        spatialDropoutLayer(Probability=dropoutFactor)
        convolution1dLayer(filterSize,numFilters,DilationFactor=dilationFactor,Padding="causal",WeightsInitializer="he")
        layerNormalizationLayer
        reluLayer
        spatialDropoutLayer(Probability=dropoutFactor)
        additionLayer(2,Name="add_"+i)];

    % Add and connect layers.
    net = addLayers(net,layers);
    net = connectLayers(net,outputName,"conv1_"+i);

    % Skip connection.
    if i == 1
        % Include convolution in first skip connection.
        layer = convolution1dLayer(1,numFilters,Name="convSkip",WeightsInitializer="he");

        net = addLayers(net,layer);
        net = connectLayers(net,outputName,"convSkip");
        net = connectLayers(net,"convSkip","add_" + i + "/in2");
    else
        net = connectLayers(net,outputName,"add_" + i + "/in2");
    end
    
    % Update layer output name.
    outputName = "add_" + i;
end

layers = [
    fullyConnectedLayer(numClasses,Name="fc",WeightsInitializer="he")
    softmaxLayer];

net = addLayers(net,layers);
net = connectLayers(net,outputName,"fc");

TCN_eegnet = net;

clearvars -except trainSgns trainLbls valSgns valLbls evalSgns evalLbls TCN_eegnet weights
% selfAttentionLayer(8,256,"AttentionMask","causal",Name="sa")
%% Opciones entrenamiento TCN_eegnet
options = trainingOptions("sgdm", ...
                          Plots = "training-progress", ...
                          Metrics = "accuracy", ...
                          MiniBatchSize = 1, ...  
                          ValidationData = {valSgns,valLbls}, ...
                          Shuffle = "every-epoch", ...
                          ValidationFrequency = 2, ...
                          Verbose = true, ...
                          MaxEpochs = 10, ... 
                          InitialLearnRate = 1e-4, ... 
                          OutputNetwork = "last-iteration", ...
                          ExecutionEnvironment = "gpu");  

lossFcn = @(Y,T) crossentropy(Y,T, ...
                              Weights = weights, ...
                              NormalizationFactor = "all-elements", ...
                              WeightsFormat = "UC");

[TCN_eegnet, infoTCN] = trainnet(trainSgns,trainLbls,TCN_eegnet,lossFcn,options);

%                         

%% Puesta a prueba de red
sgnsEval = evalSgns; %valSgns; %
lblsEval = evalLbls; %valLbls; %

% Metricas
statsTCN_eegnet = testnet(TCN_eegnet,sgnsEval,lblsEval,{"accuracy","crossentropy"},"MiniBatchSize",1);

% Realizar predicciones sobre las señales
yhat = minibatchpredict(TCN_eegnet,sgnsEval,"MiniBatchSize",1,"UniformOutput",false);
yhat = cellfun(@(x) scores2label(reshape(extractdata(x),[],2),["bckg","seiz"],2),yhat,UniformOutput=false);
y = lblsEval;
y = cellfun(@(x) onehotdecode(x,["bckg","seiz"],2),y,UniformOutput=false);

f = figure(1);
cm = confusionchart(f,vertcat(y{:}),vertcat(yhat{:}),"Normalization","column-normalized");
cm.XLabel = 'Clase predicha';
cm.YLabel = 'Clase real';

%% MISC

% ind = randperm(numel(ds_sgn.Files),10);
% trainInd = ind(1:7);
% valInd = ind(8:9);
% testInd = ind(end);
% 
% ds_sgn_train = subset(ds_sgn,trainInd);
% ds_lbls_train = subset(ds_lbls,trainInd);
% 
% ds_sgn_val = subset(ds_sgn,valInd);
% ds_lbls_val = subset(ds_lbls,valInd);
% 
% ds_sgn_test = subset(ds_sgn,testInd);
% ds_lbls_test = subset(ds_lbls,testInd);

% dtrain = readall(ds_train);
% dval = readall(ds_val);
% dtest = readall(ds_test);
% 
% trainSgns = cellfun(@(x) dlarray(x,'TCB'),dtrain(:,1),'UniformOutput',false);
% trainLbls = dtrain(:,2);
% 
% valSgns = cellfun(@(x) dlarray(x,'TCB'),dval(:,1),'UniformOutput',false);
% valLbls = dval(:,2);
% 
% evalSgns = cellfun(@(x) dlarray(x,'TCB'),dtest(:,1),'UniformOutput',false);
% evalLbls = dtest(:,2);
% 
% clearvars -except trainSgns trainLbls valSgns valLbls evalSgns evalLbls

load("MiniCorpusSEIZ3080P_menos20mins_TUH.mat");
sgns_j = cell2mat(sgns(:));
lbls_j = cell2mat(lbls(:));
lbls_j = onehotdecode(lbls_j,{'bckg','seiz'},2);


for i = 1:22
    figure(i)
    plotsigroi(signalMask(lbls_j),sgns_j(:,i))
    title(['Canal ', num2str(i)]);    
end
