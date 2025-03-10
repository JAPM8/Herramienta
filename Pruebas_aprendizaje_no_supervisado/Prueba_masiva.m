% Dylan Ixcayau 18486
% Esta prueba permite extraer características de señales EEG ictales y sanas de forma masiva en un contexto intersujeto. 
% La función carga archivos .edf de dos carpetas seleccionadas por el usuario (ictal y sano), 
% procesa los datos en ventanas de 30 segundos y extrae características estadísticas, descomposición en wavelets y ratios de 
% potencia en bandas de frecuencia. Luego, aplica PCA para reducción de dimensionalidad y realiza clustering utilizando K-means 
% y clustering jerárquico. Finalmente, muestra las características y las componentes principales en gráficos para análisis visual.
%% 

% Seleccionar la carpeta principal de señales ictales y sanas
ictal_folder = uigetdir('', 'Seleccionar la carpeta principal de señales ictales');
sano_folder = uigetdir('', 'Seleccionar la carpeta principal de señales sanas');

% Verificar si se seleccionaron ambas carpetas
if isequal(ictal_folder, 0) || isequal(sano_folder, 0)
    disp('No se seleccionó ninguna carpeta.');
else
    % Obtener todos los archivos .edf en las carpetas ictal y sano, incluyendo subcarpetas
    ictal_files = dir(fullfile(ictal_folder, '**/*.edf'));
    sano_files = dir(fullfile(sano_folder, '**/*.edf'));

    % Inicializar matrices para almacenar todas las características de señales ictales y sanas
    all_features_ictal = [];
    all_features_sano = [];
    
    % Definir un subconjunto común de canales
    common_channels = 1:29;  % Seleccionar los primeros 29 canales

    % Parámetros de la descomposición wavelet
    wavelet_madre = 'db3'; % Wavelet madre
    nivel_descomposicion = 2; % Nivel de descomposición wavelet

    % Definir la ventana de tiempo para dividir la señal en segmentos
    window_size = 30; % Ventana de 30 segundos

    %% Procesar archivos ictales
    for i = 1:length(ictal_files)
        % Obtener la ruta completa del archivo actual
        fullFilePathIctal = fullfile(ictal_files(i).folder, ictal_files(i).name);
        
        % Cargar señal EEG desde el archivo .edf
        [hdr_ictal, record_ictal] = EDF_read(fullFilePathIctal); 
        
        % Obtener la frecuencia de muestreo y número de muestras y canales
        fs_ictal = hdr_ictal.frequency(1); % Frecuencia de muestreo
        num_channels_ictal = size(record_ictal, 1); % Número de canales
        num_samples_ictal = size(record_ictal, 2); % Número de muestras

        % Seleccionar solo el subconjunto común de canales
        if num_channels_ictal >= length(common_channels)
            record_ictal = record_ictal(common_channels, :); % Extraer canales comunes
        else
            disp(['El archivo ' ictal_files(i).name ' tiene menos canales que el común, se omitirá.']);
            continue;
        end

        % Calcular el número de muestras por ventana y el número de ventanas
        samples_per_window = window_size * fs_ictal;
        num_windows = floor(num_samples_ictal / samples_per_window);

        % Inicializar matrices para almacenar características en cada ventana y canal
        std_features_ictal = zeros(length(common_channels), num_windows);
        mav_features_ictal = zeros(length(common_channels), num_windows);
        zc_features_ictal = zeros(length(common_channels), num_windows);
        kurtosis_features_ictal = zeros(length(common_channels), num_windows);
        theta_alpha_ratio_ictal = zeros(length(common_channels), num_windows);
        beta_alpha_ratio_ictal = zeros(length(common_channels), num_windows);
        theta_beta_ratio_ictal = zeros(length(common_channels), num_windows);
        theta_alpha_beta_ratio_ictal = zeros(length(common_channels), num_windows);
        theta_alpha_alpha_beta_ratio_ictal = zeros(length(common_channels), num_windows);
        asimetria_ictal = zeros(length(common_channels), num_windows);
        
        %% Extraer características por cada ventana y canal
        for ch = 1:length(common_channels)
            for w = 1:num_windows
                % Calcular índices de inicio y fin de la ventana actual
                start_index = (w-1) * samples_per_window + 1;
                end_index = min(w * samples_per_window, num_samples_ictal);
                window_data_ictal = record_ictal(ch, start_index:end_index); % Extraer datos de la ventana

                % Calcular características estadísticas y basadas en wavelets
                std_features_ictal(ch, w) = std(window_data_ictal); % Desviación estándar
                mav_features_ictal(ch, w) = mean(abs(window_data_ictal)); % Valor absoluto medio
                zc_features_ictal(ch, w) = ZC(window_data_ictal, 0); % Cruces por cero
                kurtosis_features_ictal(ch, w) = kurtosis(window_data_ictal); % Curtosis

                % Calcular PSD (Densidad Espectral de Potencia) y ratios de bandas de frecuencia

                % Calcular PSD (Densidad Espectral de Potencia) y ratios de bandas de frecuencia
    
                % 'pwelch' estima la Densidad Espectral de Potencia (PSD) usando el método de Welch,
                % dividiendo la señal en segmentos superpuestos, calculando el periodograma de cada
                % segmento, y promediando los resultados para una estimación más suave y confiable
                [pxx, f] = pwelch(window_data_ictal, [], [], [], fs_ictal);
                delta_power_ictal = bandpower(pxx, f, [0.5 4], 'psd'); % Potencia en banda delta
                theta_power_ictal = bandpower(pxx, f, [4 8], 'psd'); % Potencia en banda theta
                alpha_power_ictal = bandpower(pxx, f, [8 13], 'psd'); % Potencia en banda alpha
                beta_power_ictal = bandpower(pxx, f, [13 30], 'psd'); % Potencia en banda beta

                % Calcular ratios entre bandas de frecuencia
                theta_alpha_ratio_ictal(ch, w) = theta_power_ictal / alpha_power_ictal;
                beta_alpha_ratio_ictal(ch, w) = beta_power_ictal / alpha_power_ictal;
                theta_beta_ratio_ictal(ch, w) = theta_power_ictal / beta_power_ictal;
                theta_alpha_beta_ratio_ictal(ch, w) = (theta_power_ictal + alpha_power_ictal) / beta_power_ictal;
                theta_alpha_alpha_beta_ratio_ictal(ch, w) = (theta_power_ictal + alpha_power_ictal) / (alpha_power_ictal + beta_power_ictal);
                asimetria_ictal(ch, w) = skewness(window_data_ictal);  % Medida de asimetría
            end
        end

        % Concatenar características calculadas en una sola matriz
        features_ictal = [std_features_ictal; mav_features_ictal; zc_features_ictal; kurtosis_features_ictal; ...
                          theta_alpha_ratio_ictal; beta_alpha_ratio_ictal; theta_beta_ratio_ictal; ...
                          theta_alpha_beta_ratio_ictal; theta_alpha_alpha_beta_ratio_ictal; asimetria_ictal]';
        
        % Agregar las características del archivo actual a la matriz general
        all_features_ictal = [all_features_ictal; features_ictal];
    end

    %% Procesar archivos sanos 
    for i = 1:length(sano_files)
        % Obtener la ruta completa del archivo actual
        fullFilePathSano = fullfile(sano_files(i).folder, sano_files(i).name);
        
        % Cargar señal EEG desde el archivo .edf
        [hdr_sano, record_sano] = EDF_read(fullFilePathSano); 
        
        % Obtener la frecuencia de muestreo y número de muestras y canales
        fs_sano = hdr_sano.frequency(1); % Frecuencia de muestreo
        num_channels_sano = size(record_sano, 1); % Número de canales
        num_samples_sano = size(record_sano, 2); % Número de muestras

        % Seleccionar solo el subconjunto común de canales
        if num_channels_sano >= length(common_channels)
            record_sano = record_sano(common_channels, :); % Extraer canales comunes
        else
            disp(['El archivo ' sano_files(i).name ' tiene menos canales que el común, se omitirá.']);
            continue;
        end

        % Calcular el número de muestras por ventana y el número de ventanas
        samples_per_window = window_size * fs_sano;
        num_windows = floor(num_samples_sano / samples_per_window);

        % Inicializar matrices para almacenar características en cada ventana y canal
        std_features_sano = zeros(length(common_channels), num_windows);
        mav_features_sano = zeros(length(common_channels), num_windows);
        zc_features_sano = zeros(length(common_channels), num_windows);
        kurtosis_features_sano = zeros(length(common_channels), num_windows);
        theta_alpha_ratio_sano = zeros(length(common_channels), num_windows);
        beta_alpha_ratio_sano = zeros(length(common_channels), num_windows);
        theta_beta_ratio_sano = zeros(length(common_channels), num_windows);
        theta_alpha_beta_ratio_sano = zeros(length(common_channels), num_windows);
        theta_alpha_alpha_beta_ratio_sano = zeros(length(common_channels), num_windows);
        asimetria_sano = zeros(length(common_channels), num_windows);
        
        %% Extraer características por cada ventana y canal
        for ch = 1:length(common_channels)
            for w = 1:num_windows
                % Calcular índices de inicio y fin de la ventana actual
                start_index = (w-1) * samples_per_window + 1;
                end_index = min(w * samples_per_window, num_samples_sano);
                window_data_sano = record_sano(ch, start_index:end_index); % Extraer datos de la ventana

                % Calcular características estadísticas y basadas en wavelets
                std_features_sano(ch, w) = std(window_data_sano); % Desviación estándar
                mav_features_sano(ch, w) = mean(abs(window_data_sano)); % Valor absoluto medio
                zc_features_sano(ch, w) = ZC(window_data_sano, 0); % Cruces por cero
                kurtosis_features_sano(ch, w) = kurtosis(window_data_sano); % Curtosis

                % Calcular PSD (Densidad Espectral de Potencia) y ratios de bandas de frecuencia
    
                % 'pwelch' estima la Densidad Espectral de Potencia (PSD) usando el método de Welch,
                % dividiendo la señal en segmentos superpuestos, calculando el periodograma de cada
                % segmento, y promediando los resultados para una estimación más suave y confiable
                [pxx, f] = pwelch(window_data_sano, [], [], [], fs_sano);
                delta_power_sano = bandpower(pxx, f, [0.5 4], 'psd'); % Potencia en banda delta
                theta_power_sano = bandpower(pxx, f, [4 8], 'psd'); % Potencia en banda theta
                alpha_power_sano = bandpower(pxx, f, [8 13], 'psd'); % Potencia en banda alpha
                beta_power_sano = bandpower(pxx, f, [13 30], 'psd'); % Potencia en banda beta

                % Calcular ratios entre bandas de frecuencia
                theta_alpha_ratio_sano(ch, w) = theta_power_sano / alpha_power_sano;
                beta_alpha_ratio_sano(ch, w) = beta_power_sano / alpha_power_sano;
                theta_beta_ratio_sano(ch, w) = theta_power_sano / beta_power_sano;
                theta_alpha_beta_ratio_sano(ch, w) = (theta_power_sano + alpha_power_sano) / beta_power_sano;
                theta_alpha_alpha_beta_ratio_sano(ch, w) = (theta_power_sano + alpha_power_sano) / (alpha_power_sano + beta_power_sano);
                asimetria_sano(ch, w) = skewness(window_data_sano);  % Medida de asimetría
            end
        end

        % Concatenar características calculadas en una sola matriz
        features_sano = [std_features_sano; mav_features_sano; zc_features_sano; kurtosis_features_sano; ...
                          theta_alpha_ratio_sano; beta_alpha_ratio_sano; theta_beta_ratio_sano; ...
                          theta_alpha_beta_ratio_sano; theta_alpha_alpha_beta_ratio_sano; asimetria_sano]';
        
        % Agregar las características del archivo actual a la matriz general
        all_features_sano = [all_features_sano; features_sano];
    end

    % Concatenar características de señales ictales y sanas
    features = [all_features_ictal; all_features_sano];

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

    % Crear vector de etiquetas (1 para ictal, 2 para sano) y mezclar datos
    labels = [ones(size(all_features_ictal, 1), 1); 2 * ones(size(all_features_sano, 1), 1)];
    rand_indices = randperm(size(features, 1));
    features = features(rand_indices, :);
    labels = labels(rand_indices);

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
            [idx_kmeans_PCA, ~] = km_eans(X_pca(:, 1), num_clusters);
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
    
    % Validación caracterisiticas normal y etiquetas reales
    RI_kmeans = Rand_index(labels, idx_kmeans);
    disp(['Rand Index para K-means: ', num2str(RI_kmeans)]);
    
    RI_hierarchical = Rand_index(labels, cluster_labels_hierarchical);
    disp(['Rand Index para Clustering Jerárquico: ', num2str(RI_hierarchical)]);

    RI_comparison = Rand_index(idx_kmeans, cluster_labels_hierarchical);
    disp(['Rand Index entre K-means y Clustering Jerárquico: ', num2str(RI_comparison)]);

    % Validación PCA con etiquetas normales
    disp('---------------------Con PCA -----------------')
    RI_kmeans_PCA = Rand_index(labels, idx_kmeans_PCA);
    disp(['Rand Index para K-means: ', num2str(RI_kmeans_PCA)]);

    RI_hierarchical_PCA = Rand_index(labels, cluster_labels_hierarchical_PCA);
    disp(['Rand Index para Clustering Jerárquico: ', num2str(RI_hierarchical_PCA)]);

    RI_comparison_PCA = Rand_index(idx_kmeans_PCA, cluster_labels_hierarchical_PCA);
    disp(['Rand Index entre K-means y Clustering Jerárquico: ', num2str(RI_comparison_PCA)]);

    %% Visualización de todas las características puras
        
    figure(1); clf;
    hold on;
    scatter(features(:,1), 9*ones(N,1), 'k');     % Desviación Estándar
    scatter(features(:,2), 8*ones(N,1), 'r');      % MAV
    scatter(features(:,3), 7*ones(N,1), 'g');      % Zero Crossings
    scatter(features(:,4), 6*ones(N,1), 'b');      % Curtosis
    scatter(features(:,5), 5*ones(N,1), 'm');      % Ratio Theta/Alpha
    scatter(features(:,6), 4*ones(N,1), 'c');      % Ratio Beta/Alpha
    scatter(features(:,7), 3*ones(N,1), 'y');      % Ratio Theta/Beta
    scatter(features(:,8), 2*ones(N,1), 'k');      % Ratio Theta+Alpha/Beta
    scatter(features(:,9), ones(N,1), 'r');      % Ratio Theta+Alpha/Alpha+Beta
    scatter(features(:,10), zeros(N,1), 'b');      % Asimetría
    ylim([-1 10]);
    grid on;
    yticks(0:9);
    yticklabels({'Asimetría', 'Ratio Theta+Alpha/Alpha+Beta', ...
        'Ratio Theta+Alpha/Beta', 'Ratio Theta/Beta', 'Ratio Beta/Alpha', ...
        'Ratio Theta/Alpha', 'Curtosis', 'Zero Crossings', 'MAV', ...
        'Desviación Estándar'});
    title('Todas las Características Puras');

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

    % PCA 3 componentes
    figure(3); clf;
    scatter3(X_pca(:,1),X_pca(:,2),X_pca(:,3),50,labels ,'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('Nube de Puntos de los Primeros Tres Componentes Principales');
    grid on;

   % Para K-means con PCA
    figure(4); clf;
    scatter3(X_pca(:, 1), X_pca(:, 2), X_pca(:, 3), 50, idx_kmeans_PCA, 'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('K-means con PCA');
    grid on;
    colorbar;
    
    % Para Clustering Jerárquico con PCA
    figure(5); clf;
    scatter3(X_pca(:, 1), X_pca(:, 2), X_pca(:, 3), 50, cluster_labels_hierarchical_PCA, 'filled');
    xlabel('Componente Principal 1');
    ylabel('Componente Principal 2');
    zlabel('Componente Principal 3');
    title('Clustering Jerárquico con PCA');
    grid on;
    colorbar;
    
end