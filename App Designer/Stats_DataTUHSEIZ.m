load("Stats_TUHSEIZ.mat")

train_wseiz = cell2table(train_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);
dev_wseiz = cell2table(dev_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);
eval_wseiz = cell2table(eval_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);
%% Estadísticas set de train
stats_train = grpstats(train_wseiz,["Fs","SEIZ", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de dev
stats_dev = grpstats(dev_wseiz,["Fs","SEIZ", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de eval
stats_eval = grpstats(eval_wseiz,["Fs","SEIZ", "BCKG"],["min","max"],"DataVars","n");

%% Cantidad de etiquetas por estudio
load("QtyEtiquetasTUHSEIZ.mat")
train_wseiz.("N/A") = [];

qty_labels = vertcat(qty_labels{:});
train_wseiz.BCKG = qty_labels(:,1);
train_wseiz.Seiz = qty_labels(:,2);
blocks = zeros(height(train_wseiz),1);
for i = 1:height(train_wseiz)
    Fs = train_wseiz.Fs(i);

    if Fs ~= 256
        train_wseiz.n(i) = train_wseiz.n(i) * 256 / Fs;
        train_wseiz.Fs(i) = 256;
    end
    blocks(i,1) =  floor(train_wseiz.n(i) / 1280); 
    train_wseiz.BCKG(i) = train_wseiz.n(i) - train_wseiz.Seiz(i);
end

%% Obtención pesos para cross-entropy

qty_seizLbl = sum(train_wseiz.Seiz);
qty_bckgLbl = sum(train_wseiz.BCKG);

qty_lbls = qty_seizLbl + qty_bckgLbl;

classWeights = [qty_lbls/(2*qty_bckgLbl), qty_lbls/(2*qty_seizLbl)];

%% Obtención de índices para data set balanceado (no alcanzado)
rng("twister")
load("Stats_TUHSEIZ.mat")

train_wseiz = cell2table(train_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);
dev_wseiz = cell2table(dev_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);
eval_wseiz = cell2table(eval_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);

eeg_train_wseiz = train_wseiz(train_wseiz.Fs == 256 & train_wseiz.Seiz == 0,:);
eeg_train_wbckg = train_wseiz(train_wseiz.Fs == 256 & train_wseiz.BCKG == 0,:);

eeg_dev_wseiz = dev_wseiz(dev_wseiz.Fs == 256 & dev_wseiz.Seiz == 1,:);
eeg_dev_wbckg = dev_wseiz(dev_wseiz.Fs == 256 & dev_wseiz.BCKG == 1,:);

% Usar para train 406 wseiz y 16 wbckg (8%), dev 102 wseiz y 26 wbckg (25%)
rnd_idx_trainbckg = randperm(height(eeg_train_wbckg),33)';
rnd_idx_devseiz = randperm(height(eeg_dev_wseiz),height(eeg_dev_wseiz))';
rnd_idx_devbckg = randperm(height(eeg_dev_wbckg),26)';

eeg_dtrain_wseiz = eeg_dev_wseiz(rnd_idx_devseiz(1:107,:),:);
eeg_train = vertcat(eeg_train_wseiz,eeg_dtrain_wseiz,eeg_train_wbckg(rnd_idx_trainbckg,:));

eeg_dev_seiz = eeg_dev_wseiz(rnd_idx_devseiz(108:end,:),:);
eeg_dev = vertcat(eeg_dev_seiz,eeg_dev_wbckg(rnd_idx_devbckg,:));

%% Obteniendo dataset balanceado

load("QtyEtiquetasTUHSEIZ.mat")
train_wseiz.("N/A") = [];
qty_labels = vertcat(qty_labels{:});
train_wseiz.BCKG = qty_labels(:,1);
train_wseiz.Seiz = qty_labels(:,2);

for i = 1:height(train_wseiz)
    Fs = train_wseiz.Fs(i);
    if Fs ~= 256
        train_wseiz.n(i) = train_wseiz.n(i) * 256 / Fs;
        train_wseiz.Fs(i) = 256;
    end
    train_wseiz.BCKG(i) = train_wseiz.n(i) - train_wseiz.Seiz(i);
end

eeg_train_wseiz = train_wseiz(train_wseiz.Fs == 256 & train_wseiz.Seiz > 0,:);
eeg_train_wseiz.Duration = seconds(eeg_train_wseiz.n./eeg_train_wseiz.Fs);
train_dur_resumen = groupcounts(eeg_train_wseiz,"Duration");
set_train = eeg_train_wseiz(eeg_train_wseiz.n == 153856,:);

eeg_val_wseiz = dev_wseiz(dev_wseiz.Fs == 256 & dev_wseiz.Seiz == 1,:);
eeg_val_wseiz.Duration = seconds(eeg_val_wseiz.n./eeg_val_wseiz.Fs);
val_dur_resumen = groupcounts(eeg_val_wseiz,"Duration");
set_val = eeg_val_wseiz(eeg_val_wseiz.n == 153856,:);