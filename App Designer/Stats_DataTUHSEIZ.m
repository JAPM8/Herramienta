%% Código realizado por: Javier Alejandro Pérez Marín (20183)
% Funcional 2024A-2024B
% CORRA ESTE CÓDIGO POR SECCIONES

%   Antes analice el script "Prototipo_Data_TUH.m"

%   Este script utiliza el CORPUS tuh_eeg_seizure v2.0.3, el cual contiene
%   estudios EEG anotados con enfoque a detección de crisis epilépticas. 

%   En este se extraen estadísticas de interés del corpus, también se
%   ejemplifica cómo sacar pesos para funciones de pérdida

% Requiere los archivos: "QtyEtiquetasTUHSEIZ.mat"

%% Carga archivo de resumen de cada estudio
%   Contiene 4 variables:
%       * "train_wseiz", "dev_wseiz" & "eval_wseiz": contienen la ruta de
%         acceso (path), Fs, cantidad de muestras (n) y banderas si
%         contiene o no las etiquetas "Seiz"/"BCKG" o ninguna "N/A" (no hay
%         algún caso detectado).
%       * "qty_labels": contiene la cantidad de etiquetas de todos los
%         estudios remuestreados a 256 Hz. Estas cantidades se expresan
%         como [cantidad "bckg", cantidad "seiz"].
%
%   El archivo debe de estar en el working directory

load("QtyEtiquetasTUHSEIZ.mat")

%% Generación de estadísticas 
%   Estas son de utilidad para resumir el corpus.

% Estadísticas set de train
%   Se agrupan por Fs y si presentan "seiz" o "bckg", se obtiene estudio
%   más corto al más largo
stats_train = grpstats(train_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");

% Estadísticas set de dev
%   Se agrupan por Fs y si presentan "seiz" o "bckg", se obtiene estudio
%   más corto al más largo
stats_dev = grpstats(dev_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");

% Estadísticas set de eval
%   Se agrupan por Fs y si presentan "seiz" o "bckg", se obtiene estudio
%   más corto al más largo
stats_eval = grpstats(eval_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");

%% Resampling y cantidad de etiquetas por cada clase - Ser entrenamiento
%   Teniendo en cuenta la Fs más común de 256 Hz, se actualizan
%   estadísticas aplicando el resampling a 256 Hz y se añade la cantidad de
%   etiquetas de cada clase.

% Se elimina columna de "N/A", pues no se presenta un caso
train_wseiz.("N/A") = [];

% Se añade cantidad de etiquetas de cada clase
qty_labels = vertcat(qty_labels{:});
train_wseiz.BCKG = qty_labels(:,1);
train_wseiz.Seiz = qty_labels(:,2);

% Ciclo que aplica resampling y actualiza cantidad de etiquetas por cada
% clase
for i = 1:height(train_wseiz)
    Fs = train_wseiz.Fs(i);

    if Fs ~= 256
        train_wseiz.n(i) = train_wseiz.n(i) * 256 / Fs;
        train_wseiz.Fs(i) = 256;
    end
    train_wseiz.BCKG(i) = train_wseiz.n(i) - train_wseiz.Seiz(i);
end

piechart([sum(train_wseiz.Seiz),sum(train_wseiz.BCKG)],{'Seiz', 'BCKG'})
title('Comparación entre clases');
%% Obtención pesos para resolución de clases imbalanceadas
%   Dado que el set completo tiene más etiquetas de la clase "BCKG" en
%   ocasiones ha demostrado ser útil obtener pesos para cada clase y así
%   darle mayor importancia a la clase menos abundante.
%
%   Se recomienda leer: https://www.mathworks.com/help/deeplearning/ug/sequence-classification-using-inverse-frequency-class-weights.html

% Totales de cada clase y total general
qty_seizLbl = sum(train_wseiz.Seiz);
qty_bckgLbl = sum(train_wseiz.BCKG);
qty_lbls = qty_seizLbl + qty_bckgLbl;

% Pesos de cada clase
classWeights = [qty_lbls/(2*qty_bckgLbl), qty_lbls/(2*qty_seizLbl)];

%% Alternativa dataset balanceado
%   Una alternativa para resolver la diferencia entre clases, es obtener un
%   subconjunto de los datos con características similares y que sea
%   balanceado. 
%
%   Esta sección detalla la obtención del subconjunto obtenido en el
%   archivo "MiniCorpusBalanceadoSEIZTUH.mat"

% Se seleccionan todos los estudios que contienen etiquetas de la clase "seiz"
eeg_train_wseiz = train_wseiz(train_wseiz.Fs == 256 & train_wseiz.Seiz > 0,:);

% Se obtiene la duración de cada estudio seleccionado
eeg_train_wseiz.Duration = seconds(eeg_train_wseiz.n./eeg_train_wseiz.Fs);

% Se obtiene frecuencia de duración de los estudios 
train_dur_resumen = groupcounts(eeg_train_wseiz,"Duration");

% Se obtiene duración con mayor frecuencia
[~, idx] = max(train_dur_resumen.GroupCount);
train_dur = seconds(train_dur_resumen.Duration(idx));

% Selección de estudios de entrenamientola con duración más común
set_train = eeg_train_wseiz(eeg_train_wseiz.n == train_dur*256,:);

% Se repite procedimiento con set de development/validación
eeg_val_wseiz = dev_wseiz(dev_wseiz.Fs == 256 & dev_wseiz.Seiz == 1,:);
eeg_val_wseiz.Duration = seconds(eeg_val_wseiz.n./eeg_val_wseiz.Fs);
val_dur_resumen = groupcounts(eeg_val_wseiz,"Duration");
[~, idx] = max(val_dur_resumen.GroupCount);
val_dur = seconds(val_dur_resumen.Duration(idx));
set_val = eeg_val_wseiz(eeg_val_wseiz.n == val_dur*256,:);