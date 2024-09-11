load("Stats_TUHSEIZ.mat")

train_wseiz = cell2table(train_wseiz,"VariableNames",["Path" "Fs" "n" "SEIZ" "BCKG" "N/A"]);
dev_wseiz = cell2table(dev_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);
eval_wseiz = cell2table(eval_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);
%% Estadísticas set de train
stats_train = grpstats(train_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de dev
stats_dev = grpstats(dev_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de eval
stats_eval = grpstats(eval_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");

%% Cantidad de etiquetas por estudio
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

%% Obtención pesos para cross-entropy

qty_seizLbl = sum(train_wseiz.Seiz);
qty_bckgLbl = sum(train_wseiz.BCKG);

qty_lbls = qty_seizLbl + qty_bckgLbl;

classWeights = [qty_lbls/(2*qty_bckgLbl), qty_lbls/(2*qty_seizLbl)];

%%

stats_trainweights = grpstats(train_wseiz,["Seiz", "BCKG"],"numel","DataVars","n");

for i = 1:2
    classFrequency(i) = stats_trainweights.GroupCount(i);
    classWeights(i) = sum(stats_trainweights.numel_n(:))/(2*classFrequency(i));
end