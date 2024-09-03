% Código realizado por: Javier Pérez
%% Se carga directorio de data y se cambian extensiones a .csv
% Esto se realiza pues el directorio originalmente trae las etiquetas
% biclase con la extensión .csv_bi

% Ruta de acceso a datos CORPUS TUH SEIZURE
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
    '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso no se esté en ese folder, se cambia el working directory a este
cd(folderPath);

% Se obtienen todas las direcciones de los archivos con extensión .csv_bi
    % Notar que "**/" permite revisar en todos los subfolders
archivos = dir('**/*.csv_bi');

% Ciclo for que permite cambiar la extensión .csv_bi a .csv
for i = 1:numel(archivos)
    oldName = fullfile(archivos(i).folder,archivos(i).name);
    newName = fullfile(archivos(i).folder,[erase(archivos(i).name, ...
              '.csv_bi'),'_bi','.csv']);
    movefile(oldName, newName);
end

%% Procesamiento de archivos y separación por montajes
 % Se analiza cada archivo para determinar si pertenece a train o eval
 % Luego, se analiza el tipo de montaje "ar" o "le"
clc

% Ruta de acceso a datos CORPUS TUH SEIZURE
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso no se esté en ese folder, se cambia el working directory a este
cd(folderPath);

% Directorio de entrenamiento y de pruebas de los archivos "_bi.csv"
    % Notar que "**/" permite revisar en todos los subfolders
dirLbl_train = dir('train/**/*_bi.csv');
dirLbl_dev = dir('dev/**/*_bi.csv');
dirLbl_eval = dir('eval/**/*_bi.csv');

% Filtrado según el tipo de montaje
fltr_train_ar_a = contains({dirLbl_train.folder},'_tcp_ar_a');
fltr_train_ar = contains({dirLbl_train.folder},'_tcp_ar') ~= fltr_train_ar_a;
fltr_train_le = contains({dirLbl_train.folder},'_tcp_le');

fltr_dev_ar_a = contains({dirLbl_dev.folder},'_tcp_ar_a');
fltr_dev_ar = contains({dirLbl_dev.folder},'_tcp_ar') ~= fltr_dev_ar_a;
fltr_dev_le = contains({dirLbl_dev.folder},'_tcp_le');

fltr_eval_ar_a = contains({dirLbl_eval.folder},'_tcp_ar_a');
fltr_eval_ar = contains({dirLbl_eval.folder},'_tcp_ar') ~= fltr_eval_ar_a;
fltr_eval_le = contains({dirLbl_eval.folder},'_tcp_le');

% Se separa el directorio según el tipo de filtrado
dirLbl_train_ar = dirLbl_train(fltr_train_ar);
dirLbl_train_ar_a = dirLbl_train(fltr_train_ar_a);
dirLbl_train_le = dirLbl_train(fltr_train_le);

dirLbl_dev_ar = dirLbl_dev(fltr_dev_ar);
dirLbl_dev_ar_a = dirLbl_dev(fltr_dev_ar_a);
dirLbl_dev_le = dirLbl_dev(fltr_dev_le);

dirLbl_eval_ar = dirLbl_eval(fltr_eval_ar);
dirLbl_eval_ar_a = dirLbl_eval(fltr_eval_ar_a);
dirLbl_eval_le = dirLbl_eval(fltr_eval_le); % OJO: No hay muestras en EVAL

%% Extracción de un estudio
% Prototipo para extracción de señales y sus etiquetas de un estudio
clc

chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
             "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
             "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
             "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
             "EEG FZ-REF","EEG CZ-REF","EEG PZ-REF","EEG A1-REF",...
             "EEG A2-REF"]';

randIndex = randi(numel(dirLbl_train_ar)); % Frec (250): 4392 / indx: 4501

relPath = dirLbl_train_ar(randIndex).folder;
relName = dirLbl_train_ar(randIndex).name;

edfName = [erase(relName,'_bi.csv'),'.edf'];

lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);
edf_hdr = edfinfo(fullfile(relPath,edfName));
edf_data = cell2mat(table2cell(edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list)));

edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));
edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));
% edf_t = ((0:(edf_samples-1))/edf_Fs)';

edf_montage = [edf_data(:,1) - edf_data(:,11),...   % FP1-F7
               edf_data(:,11) - edf_data(:,13),...  % F7-T3
               edf_data(:,13) - edf_data(:,15),...  % T3-T5
               edf_data(:,15) - edf_data(:,9),...   % T5-O1
               edf_data(:,2) - edf_data(:,12),...   % FP2-F8
               edf_data(:,12) - edf_data(:,14),...  % F8-T4
               edf_data(:,14) - edf_data(:,16),...  % T4-T6
               edf_data(:,16) - edf_data(:,10),...  % T6-O2
               edf_data(:,20) - edf_data(:,13),...  % A1-T3
               edf_data(:,13) - edf_data(:,5),...   % T3-C3
               edf_data(:,5) - edf_data(:,18),...   % C3-CZ
               edf_data(:,18) - edf_data(:,6),...   % CZ-C4
               edf_data(:,6) - edf_data(:,14),...   % C4-T4
               edf_data(:,14) - edf_data(:,21),...  % T4-A2
               edf_data(:,1) - edf_data(:,3),...    % FP1-F3
               edf_data(:,3) - edf_data(:,5),...    % F3-C3
               edf_data(:,5) - edf_data(:,7),...    % C3-P3
               edf_data(:,7) - edf_data(:,9),...    % P3-O1
               edf_data(:,2) - edf_data(:,4),...    % FP2-F4
               edf_data(:,4) - edf_data(:,6),...    % F4-C4
               edf_data(:,6) - edf_data(:,8),...    % C4-P4
               edf_data(:,8) - edf_data(:,10)];     % P4-O2

% if edf_Fs ~= 256
%     disp("Aplicando resampling")
%     figure(1);plot(edf_montage(:,1));hold on;
% 
%     [P,Q] = rat(256/edf_Fs);
%     edf_montage = resample(edf_montage,P,Q);
% 
%     edf_Fs = 256;
%     edf_samples = size(edf_montage,1);
% 
%     plot(edf_montage(:,1));hold off;
%     legend('edf original','edf resampling')
% end

etiquetas = repmat("bckg",edf_samples, 1);
nr = height(lbl_data);
for lbl_idx = 1:nr
    strt_lbl = lbl_data.start_time(lbl_idx);
    stop_lbl = lbl_data.stop_time(lbl_idx);
    lbl = lbl_data.label(lbl_idx);

    if strcmp(lbl,'seiz')
        % Convertir tiempo en segundos a índices de muestra
        strt_idx = max(1, ceil(strt_lbl * edf_Fs)+1);
        stop_idx = min(edf_samples, ceil(stop_lbl * edf_Fs)+1);
        
        % Asignar la etiqueta a las muestras correspondientes
        etiquetas(strt_idx:stop_idx,1) = "seiz";
    end

end
etiquetas = categorical(etiquetas);

prueba = {edf_montage,etiquetas,edf_Fs};
disp(prueba)
figure(2)
plotsigroi(signalMask(etiquetas),edf_montage(:,1))

%% Datasets para red neuronal (poco eficiente por uso de memoria)
% Prototipo para guardar en memoria cada señal con sus lbls, se concluye
% que no es funcional debido al tamaño final del cell. Tras varios intentos
% no es posible alcanzar el objetivo del prototipo.
clc

chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
             "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
             "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
             "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
             "EEG CZ-REF","EEG A1-REF","EEG A2-REF"]';

% Entrenamiento
m = matfile("dir_setsData.mat"); 
directorio = m.dirLbl_train_ar;

num_eval_sgn = length(directorio);
train_set = cell(num_eval_sgn,4);

for file_idx = 1:num_eval_sgn
    try
        relPath = dirLbl_train_ar(file_idx).folder;
        relName = dirLbl_train_ar(file_idx).name;
        
        edfName = [erase(relName,'_bi.csv'),'.edf'];
        
        lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);
        edf_hdr = edfinfo(fullfile(relPath,edfName));
        edf_data = cell2mat(table2cell(edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list)));
        
        edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));
        edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));
    
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
        
        etiquetas = repmat("bckg",edf_samples, 1);
        fw_seiz = false;
    
        nr = height(lbl_data);
        for lbl_idx = 1:nr
            strt_lbl = lbl_data.start_time(lbl_idx);
            stop_lbl = lbl_data.stop_time(lbl_idx);
            lbl = lbl_data.label(lbl_idx);
        
            if strcmp(lbl,'seiz')
                % Convertir tiempo en segundos a índices de muestra
                strt_idx = max(1, ceil(strt_lbl * edf_Fs)+1);
                stop_idx = min(edf_samples, ceil(stop_lbl * edf_Fs)+1);
                
                % Asignar la etiqueta a las muestras correspondientes
                etiquetas(strt_idx:stop_idx,1) = "seiz";
                fw_seiz = true;
            end
        
        end
        etiquetas = categorical(etiquetas);
        
        train_set(file_idx,:) = {edf_montage,etiquetas,edf_Fs,fw_seiz};
    catch ME
        disp(ME)
        disp(['Error en: ', num2str(file_idx)]);
    end
    
end

%% Alternativa Datastores
% Funcional

% Ruta de acceso a datos CORPUS TUH SEIZURE
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso no se esté en ese folder, se cambia el working directory a este
 cd(folderPath);

% Se crean Datastores
DS_sgn_train_ar = signalDatastore(fullfile(folderPath,"train","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_train_ar = fileDatastore(fullfile(folderPath,"train","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

DS_sgn_dev_ar = signalDatastore(fullfile(folderPath,"dev","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_dev_ar = fileDatastore(fullfile(folderPath,"dev","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

DS_sgn_eval_ar = signalDatastore(fullfile(folderPath,"eval","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_eval_ar = fileDatastore(fullfile(folderPath,"eval","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);
    
DS_train_ar = combine(DS_sgn_train_ar, DS_lbl_train_ar);
DS_train_ar = transform(DS_train_ar,@(data) getlbls(data));
DS_train_ar = shuffle(DS_train_ar);

DS_dev_ar = combine(DS_sgn_dev_ar, DS_lbl_dev_ar);
DS_dev_ar = transform(DS_dev_ar,@(data) getlbls(data));
DS_dev_ar = shuffle(DS_dev_ar);

DS_eval_ar = combine(DS_sgn_eval_ar, DS_lbl_eval_ar);
DS_eval_ar = transform(DS_eval_ar,@(data) getlbls(data));
DS_eval_ar = shuffle(DS_eval_ar);

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
% Partir en fragmentos de 1024
function edf_set = getlbls(data)
    edf_montage = data{1,1};
    Fs = data{1,2};
    n = data{1,3};
    lbls = data{1,4};

    etiquetas = strings(n, 1);
    
    nr = height(lbls);
    for lbl_idx = 1:nr
        strt_lbl = lbls.start_time(lbl_idx);
        stop_lbl = lbls.stop_time(lbl_idx);
        lbl = lbls.label(lbl_idx);

        if strcmp(lbl,'seiz')
            % Convertir tiempo en segundos a índices de muestra
            strt_idx = max(1, ceil(strt_lbl * Fs)+1);
            stop_idx = min(n, ceil(stop_lbl * Fs)+1);

            % Asignar la etiqueta a las muestras correspondientes
            etiquetas(strt_idx:stop_idx,1) = "seiz";
        elseif strcmp(lbl,'bckg')
            % Convertir tiempo en segundos a índices de muestra
            strt_idx = max(1, ceil(strt_lbl * Fs)+1);
            stop_idx = min(n, ceil(stop_lbl * Fs)+1);

            % Asignar la etiqueta a las muestras correspondientes
            etiquetas(strt_idx:stop_idx,1) = "bckg";
        end

    end
    etiquetas(etiquetas == "") = "n/a";
    catg = {'n/a' 'bckg' 'seiz'};
    etiquetas = categorical(etiquetas,catg);
    etiquetas = onehotencode(etiquetas,2,ClassNames=catg);

    targetLength = 1024;
    sizeSet = size(edf_montage,1);
    inRandIdx = ceil(((sizeSet-1024)-1).*rand(1,1) + 1);
    endRandidx =  inRandIdx + targetLength - 1;   
    edf_set = {edf_montage(inRandIdx:endRandidx,:)',etiquetas(inRandIdx:endRandidx,:)'};
end

%% Prueba lectura datastore
i = 1;
eeg_prueba = cell(20,2);

while i <= 20
    eeg_prueba(i,:) = read(DS_train_ar);
    i = i + 1;
end

% eeg_set = readall(DS_train_ar);
% %% Generación de Minibatches
% 
% mbatch_train = minibatchqueue(DS_train_ar,2);

%% Creación de red neuronal LSTM
BILSTM_eegnet = dlnetwork;

layers = [sequenceInputLayer(22)
          bilstmLayer(200,'OutputMode','sequence')
          fullyConnectedLayer(3)
          softmaxLayer];

BILSTM_eegnet = addLayers(BILSTM_eegnet,layers);

options = trainingOptions(  "adam", ...
                            Plots = "training-progress", ...
                            Shuffle = "never", ...
                            InputDataFormats = "CTB", ...
                            TargetDataFormats = "CTB", ...
                            MiniBatchSize = 50, ...
                            MaxEpochs = 10, ...
                            LearnRateSchedule = "piecewise", ...
                            LearnRateDropPeriod = 1, ...
                            InitialLearnRate = 0.01, ...
                            ExecutionEnvironment = "gpu",...
                            Verbose = 0);                    

[BILSTM_eegnet, info] = trainnet(DS_train_ar,BILSTM_eegnet,"crossentropy",options);

%% Validación de red

% scores = minibatchpredict(BILSTM_eegnet,DS_eval_ar);
    
score = predict(BILSTM_eegnet,table2array(ac));
[lbl,puntos] = scores2label(score,["bckg","seiz"]);
%%
% FP1	F7
% F7	T3
% T3	T5
% T5	O1
% FP2	F8
% F8	T4
% T4	T6
% T6	O2
% A1	T3
% T3	C3
% C3	CZ
% CZ	C4
% C4	T4
% T4	A2
% FP1	F3
% F3	C3
% C3	P3
% P3	O1
% FP2	F4
% F4	C4
% C4	P4
% P4	O2
prueba = edfread(fullfile(relPath,edfName),"DataRecordOutputType","timetable","SelectedSignals",chnl_list);

                            % shuffle = "once",...    %
                            % InputDataFormats = "BCT", ...
                            % TargetDataFormats = "BC", ...
                            % MaxEpochs = 53, ...
                            % MiniBatchSize = 64, ...
                            % LearnRateSchedule = "piecewise", ...
                            % GradientThreshold = 1, ...
                            % SequencePaddingDirection = "right", ... %
                            % SequenceLength = "longest", ...
                            % ExecutionEnvironment = "parallel-auto",...
                            % ValidationData = DS_dev_ar, ...
