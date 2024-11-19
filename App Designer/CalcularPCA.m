function X_pca = CalcularPCA(features)
    % Calcular la matriz de covarianza
    N = size(features, 1);
    Sdisp = (N - 1) * cov(features);

    % Descomposición en valores propios
    [Phi, Lambda] = eig(Sdisp);
    [~, indices] = sort(diag(Lambda), 'descend');
    Phi_ordenada = Phi(:, indices);

    % Transformar los datos a las componentes principales
    X_pca = (Phi_ordenada' * features')';
end