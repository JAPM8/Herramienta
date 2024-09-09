load("Stats_TUHSEIZ.mat")

train_wseiz = cell2table(train_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);
dev_wseiz = cell2table(dev_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);
eval_wseiz = cell2table(eval_wseiz,"VariableNames",["Path" "Fs" "n" "Seiz" "BCKG" "N/A"]);

%% Estadísticas set de train
stats_train = grpstats(train_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de dev
stats_dev = grpstats(dev_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");
%% Estadísticas set de eval
stats_eval = grpstats(eval_wseiz,["Fs","Seiz", "BCKG"],["min","max"],"DataVars","n");

%% Obtención pesos para cross-entropy

stats_trainweights = grpstats(train_wseiz,["Seiz", "BCKG"],"numel","DataVars","n");

for i = 1:2
    classFrequency(i) = stats_trainweights.GroupCount(i);
    classWeights(i) = sum(stats_trainweights.numel_n(:))/(2*classFrequency(i));
end