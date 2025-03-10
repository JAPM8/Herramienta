% Dylan Ixcayau 18486
% Esta prueba permite extraer características de señales EEG. La función carga archivos .edf 
% de alguna carpeta seleccionada por el usuario, procesa los datos en ventanas de 30 segundos 
% y extrae características estadísticas, descomposición en wavelets y ratios de potencia en bandas de frecuencia.
% Luego, aplica PCA para reducción de dimensionalidad y realiza clustering utilizando K-means y clustering 
% jerárquico. Finalmente, muestra las características y las componentes principales en gráficos para análisis visual.
%% 

% Seleccionar el archivo .edf desde una carpeta
[file, path] = uigetfile('*.edf', 'Selecciona un archivo .edf');
if isequal(file, 0)
    disp('No se seleccionó ningún archivo.');
    return;
end

% Obtener la ruta completa del archivo seleccionado
fullFilePath = fullfile(path, file);

% Cargar señal EEG desde el archivo .edf
[hdr, record] = EDF_read(fullFilePath);

% Obtener la frecuencia de muestreo, número de canales y número de muestras
fs = hdr.frequency(1); % Frecuencia de muestreo (asumimos la misma para todos los canales)
num_channels = size(record, 1); % Número de canales en la señal
num_samples = size(record, 2); % Número de muestras en la señal

% Definir la ventana de tiempo en segundos
window_size = 30; % Tamaño de la ventana de tiempo en segundos

% Calcular el número de muestras por ventana y el número de ventanas
samples_per_window = window_size * fs;
num_windows = floor(num_samples / samples_per_window);

% Inicializar matrices para almacenar características en cada ventana y canal
std_features = zeros(length(num_channels), num_windows);
mav_features = zeros(length(num_channels), num_windows);
zc_features = zeros(length(num_channels), num_windows);
kurtosis_features = zeros(length(num_channels), num_windows);
theta_alpha_ratio = zeros(length(num_channels), num_windows);
beta_alpha_ratio = zeros(length(num_channels), num_windows);
theta_beta_ratio = zeros(length(num_channels), num_windows);
theta_alpha_beta_ratio = zeros(length(num_channels), num_windows);
theta_alpha_alpha_beta_ratio = zeros(length(num_channels), num_windows);
asimetria = zeros(length(num_channels), num_windows);

% Extraer características por cada ventana y canal
for ch = 1:length(num_channels)
    for w = 1:num_windows
        % Calcular índices de inicio y fin de la ventana actual
        start_index = (w-1) * samples_per_window + 1;
        end_index = min(w * samples_per_window, num_samples);
        window_data = record(ch, start_index:end_index); % Extraer datos de la ventana

        % Calcular características estadísticas
        std_features(ch, w) = std(window_data); % Desviación estándar
        mav_features(ch, w) = mean(abs(window_data)); % Valor absoluto medio
        zc_features(ch, w) = ZC(window_data, 0); % Cruces por cero
        kurtosis_features(ch, w) = kurtosis(window_data); % Curtosis

        % Calcular PSD (Densidad Espectral de Potencia) y ratios de bandas de frecuencia
        [pxx, f] = pwelch(window_data, [], [], [], fs);
        delta_power = bandpower(pxx, f, [0.5 4], 'psd'); % Potencia en banda delta
        theta_power = bandpower(pxx, f, [4 8], 'psd'); % Potencia en banda theta
        alpha_power = bandpower(pxx, f, [8 13], 'psd'); % Potencia en banda alpha
        beta_power = bandpower(pxx, f, [13 30], 'psd'); % Potencia en banda beta

        % Calcular ratios entre bandas de frecuencia
        theta_alpha_ratio(ch, w) = theta_power / alpha_power;
        beta_alpha_ratio(ch, w) = beta_power / alpha_power;
        theta_beta_ratio(ch, w) = theta_power / beta_power;
        theta_alpha_beta_ratio(ch, w) = (theta_power + alpha_power) / beta_power;
        theta_alpha_alpha_beta_ratio(ch, w) = (theta_power + alpha_power) / (alpha_power + beta_power);
        asimetria(ch, w) = skewness(window_data);  % Medida de asimetría
    end
end

% Concatenar todas las características en una sola matriz
features = [std_features; mav_features; zc_features; kurtosis_features; ...
            theta_alpha_ratio; beta_alpha_ratio; theta_beta_ratio; ...
            theta_alpha_beta_ratio; theta_alpha_alpha_beta_ratio; asimetria]';

% Preprocesamiento de características: eliminar NaN y columnas de ceros
% Eliminar columnas con más del 10% de NaN
threshold_nan = 0.1 * size(features, 1);
columns_to_keep = sum(isnan(features)) <= threshold_nan;
features = features(:, columns_to_keep);

% Reemplazar NaN con ceros en las columnas restantes
features(isnan(features)) = 0;

% Eliminar columnas con todos los valores cero
non_constant_columns = std(features) > 0;
features = features(:, non_constant_columns);

%% PCA (Análisis de Componentes Principales) para reducción de dimensionalidad
all_features_norm = (features - mean(features)) ./ std(features); % Normalización
N = size(all_features_norm, 1);
Sdisp = (N-1) * cov(all_features_norm); % Matriz de covarianza
[Phi, Lambda] = eig(Sdisp); % Descomposición en valores propios
[lambda_sorted, indices] = sort(diag(Lambda), 'descend');
Phi_ordenada = Phi(:, indices); % Ordenar componentes principales
X_pca = (Phi_ordenada' * all_features_norm')'; % Transformar datos a componentes principales

%% Selección de componentes PCA para clustering
%Se puede elegir con que valores principales hacer la clusterización.
%opcion 1: Solo con el primer componente principal.
%opcion 2: Solo con el segundo componente principal.
%opcion 3: solo con el tercer componente principal.
%opcion 4: con los primeros 3 componentes principales.
opcion = 4;
num_clusters = 2;
switch opcion
    case 1
        [idx_kmeans_PCA, ~] = k_means(X_pca(:, 1), num_clusters);
        cluster_labels_hierarchical_PCA = clusterdata(X_pca(:, 1), 'Linkage', 'ward', 'Maxclust', num_clusters);
    case 2
        [idx_kmeans_PCA, ~] = k_means(X_pca(:, 2), num_clusters);
        cluster_labels_hierarchical_PCA = clusterdata(X_pca(:, 2), 'Linkage', 'ward', 'Maxclust', num_clusters);
    case 3
        [idx_kmeans_PCA, ~] = k_means(X_pca(:, 3), num_clusters);
        cluster_labels_hierarchical_PCA = clusterdata(X_pca(:, 3), 'Linkage', 'ward', 'Maxclust', num_clusters);
    case 4
        [idx_kmeans_PCA, ~] = k_means(X_pca(:, 1:3), num_clusters);
        cluster_labels_hierarchical_PCA = clusterdata(X_pca(:, 1:3), 'Linkage', 'ward', 'Maxclust', num_clusters);
    otherwise
        disp('Selección no válida.');
        return;
end

%% Clustering con características originales y validación
    %clusterizacion usando las caracteristicas normalizadas

    %K-means
    [idx_kmeans, centroids_kmeans] = k_means(all_features_norm, num_clusters);
    
    %Jerarquíco
    cluster_labels_hierarchical = clusterdata(all_features_norm, 'Linkage', 'ward', 'SaveMemory', 'on', 'Maxclust', num_clusters);
    
    % Comparación entre la agrupación de las caracteristicas puras vs el
    % PCA
    disp('----------Todas las caracteristicas vs PCA----------')
    RI_TC_PCA_kmeans = Rand_index(idx_kmeans_PCA, idx_kmeans);
    disp(['Rand Index entre k-means y k-means con PCA: ', num2str(RI_TC_PCA_kmeans)]);

    RI_TC_PCA_hierarquical = Rand_index(cluster_labels_hierarchical_PCA, cluster_labels_hierarchical);
    disp(['Rand Index entre jerarquico y jerarquico con PCA: ', num2str(RI_TC_PCA_hierarquical)]);

    disp('---------------------Con caracteristicas normales -----------------')
    
    % Validación caracterisiticas normal
    RI_comparison = Rand_index(idx_kmeans, cluster_labels_hierarchical);
    disp(['Rand Index entre K-means y Clustering Jerárquico: ', num2str(RI_comparison)]);

    % Validación PCA 
    disp('---------------------Con PCA -----------------')
   
    RI_comparison_PCA = Rand_index(idx_kmeans_PCA, cluster_labels_hierarchical_PCA);
    disp(['Rand Index entre K-means y Clustering Jerárquico: ', num2str(RI_comparison_PCA)]);

    %% Visualización de todas las características puras
        
    figure(1); clf;
    hold on;
    scatter(all_features_norm(:,1), 9*ones(N,1), 'k');     % Desviación Estándar
    scatter(all_features_norm(:,2), 8*ones(N,1), 'r');      % MAV
    scatter(all_features_norm(:,3), 7*ones(N,1), 'g');      % Zero Crossings
    scatter(all_features_norm(:,4), 6*ones(N,1), 'b');      % Curtosis
    scatter(all_features_norm(:,5), 5*ones(N,1), 'm');      % Ratio Theta/Alpha
    scatter(all_features_norm(:,6), 4*ones(N,1), 'c');      % Ratio Beta/Alpha
    scatter(all_features_norm(:,7), 3*ones(N,1), 'y');      % Ratio Theta/Beta
    scatter(all_features_norm(:,8), 2*ones(N,1), 'k');      % Ratio Theta+Alpha/Beta
    scatter(all_features_norm(:,9), ones(N,1), 'r');      % Ratio Theta+Alpha/Alpha+Beta
    scatter(all_features_norm(:,10), zeros(N,1), 'b');      % Asimetría
    ylim([-1 10]);
    grid on;
    yticks(0:9);
    yticklabels({'Asimetría', 'Ratio Theta+Alpha/Alpha+Beta', ...
        'Ratio Theta+Alpha/Beta', 'Ratio Theta/Beta', 'Ratio Beta/Alpha', ...
        'Ratio Theta/Alpha', 'Curtosis', 'Zero Crossings', 'MAV', ...
        'Desviación Estándar'});
    title('Todas las Características Puras Normalizadas');

    %% Componentes principales
    figure(2); clf;
    hold on;
    scatter(X_pca(:,1), ones(N,1), 'k');    
    scatter(X_pca(:,2), zeros(N,1), 'r');   
    scatter(X_pca(:,3), -ones(N,1), 'g');   
    scatter(X_pca(:,4), -2*ones(N,1), 'b'); 
    ylim([-3 2]);
    grid on;
    yticks([-2 -1 0 1]);  
    yticklabels({'PC4', 'PC3', 'PC2', 'PC1'});
    title('Componentes Principales');

   % Para K-means con PCA
    figure(3); clf;
    scatter3(X_pca(:, 1), X_pca(:, 2), X_pca(:, 3), 50, idx_kmeans_PCA, 'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('K-means con PCA');
    grid on;
    colorbar;
    
    % Para Clustering Jerárquico con PCA
    figure(4); clf;
    scatter3(X_pca(:, 1), X_pca(:, 2), X_pca(:, 3), 50, cluster_labels_hierarchical_PCA, 'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('Clustering Jerárquico con PCA');
    grid on;
    colorbar;
    
    figure(5); clf;
    scatter3(X_pca(:, 1), X_pca(:, 2), X_pca(:, 3), 50, 'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('Clustering Jerárquico con PCA');
    grid on;
    colorbar;

    figure(6); clf;
    VAT(all_features_norm);