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
dirLbl_train = [dir('train/**/*_bi.csv');dir('dev/**/*_bi.csv')];
dirLbl_eval = dir('eval/**/*_bi.csv');

% Filtrado según el tipo de montaje
fltr_train_ar_a = contains({dirLbl_train.folder},'_tcp_ar_a');
fltr_train_ar = contains({dirLbl_train.folder},'_tcp_ar') ~= fltr_train_ar_a;
fltr_train_le = contains({dirLbl_train.folder},'_tcp_le');
fltr_eval_ar_a = contains({dirLbl_eval.folder},'_tcp_ar_a');
fltr_eval_ar = contains({dirLbl_eval.folder},'_tcp_ar') ~= fltr_eval_ar_a;
fltr_eval_le = contains({dirLbl_eval.folder},'_tcp_le');

% Se separa el directorio según el tipo de filtrado
dirLbl_train_ar = dirLbl_train(fltr_train_ar);
dirLbl_train_ar_a = dirLbl_train(fltr_train_ar_a);
dirLbl_train_le = dirLbl_train(fltr_train_le);
dirLbl_eval_ar = dirLbl_eval(fltr_eval_ar);
dirLbl_eval_ar_a = dirLbl_eval(fltr_eval_ar_a);
dirLbl_eval_le = dirLbl_eval(fltr_eval_le); % OJO: No hay muestras en EVAL

%% Etiquetado de una señal
clc

chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
             "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
             "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
             "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
             "EEG FZ-REF","EEG CZ-REF","EEG PZ-REF","EEG A1-REF",...
             "EEG A2-REF"]';

randIndex = randi(numel(dirLbl_train));

relPath = dirLbl_train(randIndex).folder;
relName = dirLbl_train(randIndex).name;

edfName = [erase(relName,'_bi.csv'),'.edf'];

lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);
edf_hdr = edfinfo(fullfile(relPath,edfName));
edf_data = cell2mat(table2cell(edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list)));

edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));
edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));
edf_t = ((0:(edf_samples-1))/edf_Fs)';

etiquetas = zeros(edf_samples,1);

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
        etiquetas(strt_idx:stop_idx) = 1;
    end

end

edf_montage = [edf_t, ...
               edf_data(:,1) - edf_data(:,11),...   % FP1-F7
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
               edf_data(:,8) - edf_data(:,10),...   % P4-O2
               etiquetas];

%% Etiquetado de señales
clc
chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
             "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
             "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
             "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
             "EEG FZ-REF","EEG CZ-REF","EEG PZ-REF","EEG A1-REF",...
             "EEG A2-REF"]';

% Entrenamiento
directorio = dirLbl_train_ar;

num_eval_sgn = length(directorio);
eval_sgn = cell(num_eval_sgn,1);

for file_idx = 1:num_eval_sgn
    relPath = directorio(file_idx).folder;
    relName = directorio(file_idx).name;
    edfName = [erase(relName,'_bi.csv'),'.edf'];
    
    edf_hdr = edfinfo(fullfile(relPath,edfName));
    edf_data = edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list);
    edf_fs = unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration));
    

    lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);
    
    nr = height(lbl_data);
    for lbl_idx = 1:nr
        strt_lbl = lbl_data.start_time(lbl_idx);
        stop_lbl = lbl_data.stop_time(lbl_idx);
        lbl = lbl_data.label(lbl_idx);      
    end
    
end

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