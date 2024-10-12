%% Código realizado por: Javier Pérez
 % Funcional 2024A-2024B
 % CORRA ESTE CÓDIGO POR SECCIONES

%   Este script utiliza el CORPUS tuh_eeg_seizure v2.0.3, el cual contiene
%   estudios EEG anotados con enfoque a detección de crisis epilépticas. 

%   Acceda al CORPUS: https://isip.piconepress.com/projects/nedc/data/tuh_eeg/tuh_eeg_seizure/
%% Se carga directorio de data y se cambian extensiones a .csv
%   Esto se realiza pues el directorio originalmente trae las etiquetas
%   biclase (SEIZ/BCKG) con la extensión .csv_bi

% Ruta de acceso a datos CORPUS TUH SEIZURE
%   Cambie la ruta a la de su computadora
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
    '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso MATLAB no se esté en ese folder, se cambia el working directory a este
cd(folderPath);

% Se obtienen todas las direcciones de los archivos con extensión .csv_bi
%   Notar que "**/" permite revisar en todos los subfolders
archivos = dir('**/*.csv_bi');

% Ciclo for que permite cambiar la extensión .csv_bi a .csv
%   Para mantener diferencia entre etiquetas multiclase (ya en .csv) y 
%   biclase, se modifica el fin del nombre de las biclase a "_bi"
for i = 1:numel(archivos)
    oldName = fullfile(archivos(i).folder,archivos(i).name);
    newName = fullfile(archivos(i).folder,[erase(archivos(i).name, ...
              '.csv_bi'),'_bi','.csv']);
    movefile(oldName, newName);
end

%% Procesamiento de archivos y separación por montajes
%   Se analiza cada archivo para determinar si pertenece a train,dev o eval.
%   Luego, se analiza el tipo de montaje "ar" o "le".
clc

% Ruta de acceso a datos CORPUS TUH SEIZURE
%   Cambie la ruta a la de su computadora
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso MATLAB no se esté en ese folder, se cambia el working directory a este
cd(folderPath);

% Directorio de entrenamiento y de pruebas de los archivos "_bi.csv"
%   Notar que "**/" permite revisar en todos los subfolders
dirLbl_train = dir('train/**/*_bi.csv');
dirLbl_dev = dir('dev/**/*_bi.csv');
dirLbl_eval = dir('eval/**/*_bi.csv');

% Filtrado según el tipo de montaje (devuelve arreglo de index que cumplen
% con el criterio como 1), train se refiere a estudios de entrenamiento, 
% dev se refiere a development (≡ validación) y eval se refiera a evaluación
fltr_train_ar_a = contains({dirLbl_train.folder},'_tcp_ar_a');
fltr_train_ar = contains({dirLbl_train.folder},'_tcp_ar') ~= fltr_train_ar_a;
fltr_train_le = contains({dirLbl_train.folder},'_tcp_le');

fltr_dev_ar_a = contains({dirLbl_dev.folder},'_tcp_ar_a');
fltr_dev_ar = contains({dirLbl_dev.folder},'_tcp_ar') ~= fltr_dev_ar_a;
fltr_dev_le = contains({dirLbl_dev.folder},'_tcp_le');

fltr_eval_ar_a = contains({dirLbl_eval.folder},'_tcp_ar_a');
fltr_eval_ar = contains({dirLbl_eval.folder},'_tcp_ar') ~= fltr_eval_ar_a;
fltr_eval_le = contains({dirLbl_eval.folder},'_tcp_le');

% Se separan directorios con ayuda de los filtros
%   Se obtienen rutas por separado para cada tipo de montaje y objetivo
%   de data (entrenamiento, development y evaluación)
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
%   Prototipo para extracción de canales de un estudio y sus etiquetas

clc

% Canales disponibles para estudios con montaje tipo AR
%   Montajes LE o AR_A cambian los canales disponibles
chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
             "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
             "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
             "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
             "EEG FZ-REF","EEG CZ-REF","EEG PZ-REF","EEG A1-REF",...
             "EEG A2-REF"]';

% Aleatoriamente se obtiene número de estudio (EEG) a extraer
randIndex = randi(numel(dirLbl_train_ar));

% Dado que los directorios contienen las rutas a las etiquetas, no a los
% EEG, se extrae el folder y el nombre del estudio seleccionado
relPath = dirLbl_train_ar(randIndex).folder;
relName = dirLbl_train_ar(randIndex).name;

% Se formatea el nombre del archivo de las etiquetas para acceder al EEG
edfName = [erase(relName,'_bi.csv'),'.edf'];

% Se lee archivo de etiquetas (.csv), inicia a leer hasta la fila 5 y
% las comas "," las traduce a cambio de columna
lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);

% Se obtiene header del EEG, este contiene la información de registro
edf_hdr = edfinfo(fullfile(relPath,edfName));

% Se lee canales seleccionados en "chnl_list" de EEG
%   Note que la función devuelve una tabla que se convierte a cell (table2cell)
%   y luego el cell se convierte a array (cell2mat)
edf_data = cell2mat(table2cell(edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list)));

% Se obtiene frecuencia de muestreo del estudio 
edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));

% Se obtiene cantidad de muestras del estudio
edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));

% Se obtiene vector de tiempo del estudio
edf_t = ((0:(edf_samples-1))/edf_Fs)';

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

% Descomente el siguiente fragmento si desea aplicar resampling al EEG

% Fs_new = 256;
% if edf_Fs ~= Fs_new
%     % Se obtiene fracción que permite la conversión entre Fs
%     [P,Q] = rat(Fs_new/edf_Fs);
%
%     % Se aplica resampling al EEG
%       % Verifique documentación de la función pues aplica filtro
%       % anti-aliasing, en este caso no se modifica el default
%     edf_montage = resample(edf_montage,P,Q);
%     
%     % Se actualizan variables del estudio
%     edf_Fs = Fs_new;
%     edf_samples = size(edf_montage,1);
% end

% Se genera vector de etiquetas lleno inicialmente de etiqueta "bckg" -> no convulsión
etiquetas = repmat("bckg",edf_samples, 1);

% ciclo que recorre todas las filas de la tabla de etiquetas
nr = height(lbl_data);
for lbl_idx = 1:nr

    % Se obtiene etiqueta de la fila
    lbl = lbl_data.label(lbl_idx);
    
    % Si la etiqueta es "seiz" -> Convulsión
    if strcmp(lbl,'seiz')

        % Se obtiene tiempo de inicio de etiqueta (en segundos)
        strt_lbl = lbl_data.start_time(lbl_idx);

        % Se obtiene tiempo de fin de etiqueta (en segundos)
        stop_lbl = lbl_data.stop_time(lbl_idx);

        % Convertir tiempo de inicio a índice del array
        strt_idx = ceil(strt_lbl * edf_Fs)+1;

        % Convertir tiempo de fin a índice del array
            % Note que la función "min" garantiza que no se supere la
            % cantidad de muestras del EEG con la operación
        stop_idx = min(edf_samples, ceil(stop_lbl * edf_Fs)+1);
        
        % Asignar la etiqueta a las muestras correspondientes
        etiquetas(strt_idx:stop_idx,1) = "seiz";
    end

end

% Vector de etiquetas se convierte a vector categórico
etiquetas = categorical(etiquetas);

% Gráfico de un canal (chnl) con sus etiquetas
%   Si se selecciona un canal que no existe, trabaja con el último canal
chnl = 1;
if chnl > height(edf_montage)
    warning(['El canal que ingreso supera la cantidad de canales disponibles.', ...
             'Ingrese una cantidad menor o igual a ', num2str(height(edf_montage)), ...
             '. Trabajando con canal ', num2str(height(edf_montage)), '.']);
    chnl = height(edf_montage);
end
plotsigroi(signalMask(etiquetas),edf_montage(:,chnl))

%% Lectura datasets (NO CORRA ESTA SECCIÖN, LEA ANTES LOS COMENTARIOS)
%   Prototipo para guardar en memoria cada estudio con sus etiquetas.
%   El código es funcional, pero debido al tamaño de memoria que ocupa la
%   lectura NO es posible completarse con 32 Gb de RAM.
    
%   El código es el mismo de la sección anterior, pero con un ciclo for
%   que recorre todos los estudios. Es decir, que repite por cada estudio

%   Se probó alocar memoria, aumentar el límite de memoría de MATLAB y
%   optimizar el código. Conclusión: pase a la siguiente sección para la solución 

% Si desea probar, descomente el código debajo.

% clc
% 
% chnl_list = ["EEG FP1-REF","EEG FP2-REF","EEG F3-REF","EEG F4-REF",...
%              "EEG C3-REF","EEG C4-REF","EEG P3-REF","EEG P4-REF",...
%              "EEG O1-REF","EEG O2-REF","EEG F7-REF","EEG F8-REF",...
%              "EEG T3-REF","EEG T4-REF","EEG T5-REF","EEG T6-REF",...
%              "EEG CZ-REF","EEG A1-REF","EEG A2-REF"]';
% 
% % Entrenamiento
% m = matfile("dir_setsData.mat"); 
% directorio = m.dirLbl_train_ar;
% 
% num_eval_sgn = length(directorio);
% train_set = cell(num_eval_sgn,4);
% 
% for file_idx = 1:num_eval_sgn
%     try
%         relPath = dirLbl_train_ar(file_idx).folder;
%         relName = dirLbl_train_ar(file_idx).name;
% 
%         edfName = [erase(relName,'_bi.csv'),'.edf'];
% 
%         lbl_data = readtable(fullfile(relPath,relName),"Delimiter",",","NumHeaderLines",5);
%         edf_hdr = edfinfo(fullfile(relPath,edfName));
%         edf_data = cell2mat(table2cell(edfread(fullfile(relPath,edfName),"SelectedSignals",chnl_list)));
% 
%         edf_Fs = max(unique(edf_hdr.NumSamples/seconds(edf_hdr.DataRecordDuration)));
%         edf_samples = (edf_hdr.NumDataRecords*max(edf_hdr.NumSamples));
% 
%         edf_montage = [edf_data(:,1) - edf_data(:,11),...   % FP1-F7
%                        edf_data(:,11) - edf_data(:,13),...  % F7-T3
%                        edf_data(:,13) - edf_data(:,15),...  % T3-T5
%                        edf_data(:,15) - edf_data(:,9),...   % T5-O1
%                        edf_data(:,2) - edf_data(:,12),...   % FP2-F8
%                        edf_data(:,12) - edf_data(:,14),...  % F8-T4
%                        edf_data(:,14) - edf_data(:,16),...  % T4-T6
%                        edf_data(:,16) - edf_data(:,10),...  % T6-O2
%                        edf_data(:,18) - edf_data(:,13),...  % A1-T3
%                        edf_data(:,13) - edf_data(:,5),...   % T3-C3
%                        edf_data(:,5) - edf_data(:,17),...   % C3-CZ
%                        edf_data(:,17) - edf_data(:,6),...   % CZ-C4
%                        edf_data(:,6) - edf_data(:,14),...   % C4-T4
%                        edf_data(:,14) - edf_data(:,19),...  % T4-A2
%                        edf_data(:,1) - edf_data(:,3),...    % FP1-F3
%                        edf_data(:,3) - edf_data(:,5),...    % F3-C3
%                        edf_data(:,5) - edf_data(:,7),...    % C3-P3
%                        edf_data(:,7) - edf_data(:,9),...    % P3-O1
%                        edf_data(:,2) - edf_data(:,4),...    % FP2-F4
%                        edf_data(:,4) - edf_data(:,6),...    % F4-C4
%                        edf_data(:,6) - edf_data(:,8),...    % C4-P4
%                        edf_data(:,8) - edf_data(:,10)];     % P4-O2
% 
%         etiquetas = repmat("bckg",edf_samples, 1);
%         fw_seiz = false;
% 
%         nr = height(lbl_data);
%         for lbl_idx = 1:nr
%             strt_lbl = lbl_data.start_time(lbl_idx);
%             stop_lbl = lbl_data.stop_time(lbl_idx);
%             lbl = lbl_data.label(lbl_idx);
% 
%             if strcmp(lbl,'seiz')
%                 % Convertir tiempo en segundos a índices de muestra
%                 strt_idx = max(1, ceil(strt_lbl * edf_Fs)+1);
%                 stop_idx = min(edf_samples, ceil(stop_lbl * edf_Fs)+1);
% 
%                 % Asignar la etiqueta a las muestras correspondientes
%                 etiquetas(strt_idx:stop_idx,1) = "seiz";
%                 fw_seiz = true;
%             end
% 
%         end
%         etiquetas = categorical(etiquetas);
% 
%         train_set(file_idx,:) = {edf_montage,etiquetas,edf_Fs,fw_seiz};
%     catch ME
%         disp(ME)
%         disp(['Error en: ', num2str(file_idx)]);
%     end
% 
% end

%% Lectura de datasets con Datastores
clc;

% Ruta de acceso a datos CORPUS TUH SEIZURE
%    Cambie la ruta a la de su computadora
folderPath = ['C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway' ...
               '\Tesis\Data\Datos_TUH\v2.0.3\edf'];

% En caso MATLAB no se esté en ese folder, se cambia el working directory a este
cd(folderPath);

% Se crean Datastores
%   Sigue la misma idea de los directorios, donde se da el path relativo
%   y este devuelve las rutas de acceso a los archivos que cumplen con
%   este. La ventaja es que permiten definir funciones de lectura,
%   combinarlos y leer uno o todos a la vez.
%
%   Se aconseja leer la documentación de datastores: https://www.mathworks.com/help/matlab/datastore.html

% Datastores de entrenamiento montaje AR (secuencia más pequeña 1280 muestras)
%   Funciones definidas al final de la sección
DS_sgn_train_ar = signalDatastore(fullfile(folderPath,"train","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_train_ar = fileDatastore(fullfile(folderPath,"train","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

% Datastores de development/validación montaje AR (secuencia más pequeña 256 muestras)
%   Funciones definidas al final de la sección
DS_sgn_dev_ar = signalDatastore(fullfile(folderPath,"dev","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_dev_ar = fileDatastore(fullfile(folderPath,"dev","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

% Datastores de evaluación montaje AR (secuencia más pequeña 4096 muestras)
%   Funciones definidas al final de la sección
DS_sgn_eval_ar = signalDatastore(fullfile(folderPath,"eval","**","*_ar"),"ReadFcn",@readTUHEDF,"FileExtensions",".edf");
DS_lbl_eval_ar = fileDatastore(fullfile(folderPath,"eval","**","*_ar","*_bi.csv"),"ReadFcn",@read_lbl);

% Parámetro de longitud que se utiliza para dividir las señales en ventanas
w_ventana = 60*256; %1 minuto con Fs de 256 Hz

% Se combina datastores entrenamiento de EEG y etiquetas, de esta manera al leer el
% datastore se obtienen las señales y las etiquetas (ambas sin procesar)
DS_train_ar = combine(DS_sgn_train_ar, DS_lbl_train_ar);

% Se transforma el datastore, con esto se procesan las señales y etiquetas
%   Función definida al final de la sección
DS_train_ar = transform(DS_train_ar,@(data) getlbls(data,w_ventana,2));

% Se mezcla el datastore (mantiene la relación señal-etiqueta)
%   Esto se hace para ayudar a que en el entrenamiento no se tenga
%   alguna relación de aprendizaje entre pacientes
DS_train_ar = shuffle(DS_train_ar);

% Se combina, transforma y mezcla datastores de development/validación
%   Función definida al final de la sección
DS_dev_ar = combine(DS_sgn_dev_ar, DS_lbl_dev_ar);
DS_dev_ar = transform(DS_dev_ar,@(data) getlbls(data,w_ventana,2));
DS_dev_ar = shuffle(DS_dev_ar);

% Se combina, transforma y mezcla datastores de evaluación
%    Función definida al final de la sección
DS_eval_ar = combine(DS_sgn_eval_ar, DS_lbl_eval_ar);
DS_eval_ar = transform(DS_eval_ar,@(data) getlbls(data,w_ventana,3));
% DS_eval_ar = shuffle(DS_eval_ar);

function edf_val = readTUHEDF(filename)
% 
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
    edf_montage = data{1,1};
    Fs = data{1,2};
    sizeSet = data{1,3};
    lbls = data{1,4};
    largo = ventana;
    Max = max(edf_montage,[],"all");
    Min = min(edf_montage,[],"all");

    if modo ~= 3
        etiquetas = strings(max(sizeSet,largo), 1);
    else
        etiquetas = strings(sizeSet, 1);
    end
    

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
        elseif strcmp(lbl,'bckg')
            % Convertir tiempo en segundos a índices de muestra
            strt_idx = ceil(strt_lbl * Fs)+1;
            stop_idx = min(sizeSet, ceil(stop_lbl * Fs)+1);

            % Asignar la etiqueta a las muestras correspondientes
            etiquetas(strt_idx:stop_idx,1) = "bckg";
        end
    end
            
    % etiquetas(etiquetas == "") = "n/a";
    % catg = {'n/a' 'bckg' 'seiz'};
    etiquetas(etiquetas == "") = "bckg";
    etiquetas = categorical(etiquetas,{'bckg' 'seiz'});
    
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
    elseif modo == 3
        edf_montage = {edf_montage};
        etiquetas = {etiquetas};
    elseif (sizeSet < largo) && (modo ~= 3) 
        edf_montage(largo,:) = 0;
        edf_montage = {edf_montage};

        etiquetas = {etiquetas};
    end  
    
    edf_montage = cellfun(@(x) rescale(x,-1,1,"InputMin",Min,"InputMax",Max),edf_montage,'UniformOutput',false);
    edf_set = [edf_montage,etiquetas];
end

%% Prueba lectura datastore
i = 1;
eeg_prueba = cell(100,2);

while i <= 100
    eeg_prueba(i,:) = read(DS_train_ar);
    i = i + 1;
end

% eeg_set = readall(DS_train_ar);

%% Generación de Minibatches

mbatch_train = minibatchqueue(DS_train_ar, ...
                              MiniBatchSize = 1, ...
                              PartialMiniBatch = "discard", ...
                              OutputAsDlarray=[1 0], ...
                              MiniBatchFormat=["TCB" ""], ...
                              OutputEnvironment=["gpu" "cpu"]);

[X,Y] = next(mbatch_train);

%% Prueba de lectura en memoria
tallTrainSet = tall(DS_train_ar);
tallDevSet = tall(DS_dev_ar);

trainData = gather(tallTrainSet);
devData = gather(tallDevSet);

%% Creación de red neuronal BILSTM
BILSTM_eegnet = dlnetwork;

layers = [sequenceInputLayer(22,"Normalization","zscore","NormalizationDimension","channel")
          bilstmLayer(200,'OutputMode','sequence')
          dropoutLayer(0.2)
          bilstmLayer(150,'OutputMode','sequence')
          dropoutLayer(0.2)
          fullyConnectedLayer(2)
          softmaxLayer];

BILSTM_eegnet = addLayers(BILSTM_eegnet,layers);

%% Opciones entrenamiento BILSTM
options = trainingOptions("adam", ...
                          Plots = "training-progress", ...
                          InputDataFormats = "TCB", ...
                          MiniBatchSize = 62, ...  
                          ObjectiveMetricName = "loss", ...
                          Verbose = false, ....
                          MaxEpochs = 26, ... 
                          Shuffle = "every-epoch", ...
                          InitialLearnRate = 0.001, ... 
                          ValidationData = {devData(:,1),devData(:,2)}, ...
                          ValidationFrequency = 26, ...
                          LearnRateSchedule = "piecewise", ...
                          LearnRateDropPeriod = 13, ...
                          GradientThreshold = 2, ...
                          OutputNetwork = "best-validation", ...
                          ExecutionEnvironment = "gpu");                    

lossFcn = @(Y,T) crossentropy(Y,T, ...
                              Weights = [639/1222, 1084/95], ...
                              NormalizationFactor = "all-elements", ...
                              WeightsFormat = "UC");

[BILSTM_eegnet, infoBILSTM] = trainnet(trainData(:,1),trainData(:,2),BILSTM_eegnet,lossFcn,options);

%% Creación de red neuronal LSTM

LSTM_eegnet = dlnetwork;

layers = [sequenceInputLayer(22)
          lstmLayer(100,'OutputMode','sequence')
          dropoutLayer(0.2)
          lstmLayer(75,'OutputMode','sequence')
          dropoutLayer(0.2)
          fullyConnectedLayer(2)
          softmaxLayer];

LSTM_eegnet = addLayers(LSTM_eegnet,layers);
LSTM_eegnet = initialize(LSTM_eegnet);
%% Opciones entrenamiento LSTM
options = trainingOptions("adam", ...
                          Plots = "training-progress", ...
                          InputDataFormats = "TCB", ...
                          MiniBatchSize = 34, ...  
                          Metrics = "fscore", ...
                          ObjectiveMetricName = "fscore", ...
                          Verbose = false, ....
                          MaxEpochs = 30, ... 
                          Shuffle = "every-epoch", ...
                          InitialLearnRate = 0.001, ... 
                          ValidationData = DS_dev_ar, ...
                          ValidationFrequency = 51, ...
                          LearnRateSchedule = "piecewise", ...
                          LearnRateDropPeriod = 15, ...
                          GradientThreshold = 1, ...
                          OutputNetwork = "best-validation", ...
                          ExecutionEnvironment = "gpu", ...
                          PreprocessingEnvironment = "parallel");                    

lossFcn = @(Y,T) crossentropy(Y,T, ...
                              Weights = [639/1222, 1084/95], ...
                              NormalizationFactor = "all-elements", ...
                              WeightsFormat = "UC");

[LSTM_eegnet, infoLSTM2] = trainnet(DS_train_ar,LSTM_eegnet,lossFcn,options);

%% Prueba de un estudio

sgn = read(DS_eval_ar);
sgns = sgn{:,1};
lbls = sgn{:,2};

score = predict(LSTM_eegnet,sgns,"InputDataFormats","TCB");
Ypred = scores2label(score,{'bckg' 'seiz'});

figure(1)
confusionchart([lbls(:)],[Ypred(:)],'Normalization','row-normalized');
%% Validación de red

sgns = readall(DS_eval_ar);
sgn = sgns(:,1);
lbls = sgns(:,2);
scores = minibatchpredict(BILSTM_eegnet,sgn,"MiniBatchSize",10,"InputDataFormats","TCB","ExecutionEnvironment","cpu","Acceleration","auto");
YPred = scores2label(scores,{'bckg' 'seiz'});
%%
Ypred = reshape(YPred,28963,[]);
lbls_s = vertcat(lbls{:});

confusionchart([lbls_s(:)],[Ypred(:)],'Normalization','row-normalized');

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
