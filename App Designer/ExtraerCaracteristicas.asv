function features = ExtraerCaracteristicas(EEGData, Fs, window_size)
    % EEGData: Matriz con los datos EEG (canales x muestras)
    % Fs: Frecuencia de muestreo
    % window_size: Tamaño de la ventana en segundos (por defecto 30 segundos)
    
    if nargin < 3
        window_size = 30;  % Definir tamaño de ventana por defecto a 30 segundos
    end
    
    % Calcular muestras por ventana
    samples_per_window = window_size * Fs;
    num_channels = size(EEGData, 1);
    num_samples = size(EEGData, 2);
    num_windows = floor(num_samples / samples_per_window);

    % Inicializar matrices para características
    std_features = zeros(num_channels, num_windows);
    mav_features = zeros(num_channels, num_windows);
    zc_features = zeros(num_channels, num_windows);
    kurtosis_features = zeros(num_channels, num_windows);
    theta_alpha_ratio_features = zeros(num_channels, num_windows);
    beta_alpha_ratio_features = zeros(num_channels, num_windows);
    theta_beta_ratio_features = zeros(num_channels, num_windows);
    theta_alpha_beta_ratio_features = zeros(num_channels, num_windows);
    theta_alpha_alpha_beta_ratio_features = zeros(num_channels, num_windows);
    asimetria_features = zeros(num_channels, num_windows);

    % Extraer características por cada ventana y canal
    for ch = 1:num_channels
        for w = 1:num_windows
            start_index = (w-1) * samples_per_window + 1;
            end_index = min(w * samples_per_window, num_samples);
            window_data = EEGData(ch, start_index:end_index);

            % Calcular características estadísticas
            std_features(ch, w) = std(window_data);
            mav_features(ch, w) = mean(abs(window_data));
            zc_features(ch, w) = ZC(window_data, 0);  % Función de cruces por cero
            kurtosis_features(ch, w) = kurtosis(window_data);

            % Calcular PSD y ratios de bandas de frecuencia
            [pxx, f] = pwelch(window_data, [], [], [], Fs);  % Cambiado Fs en vez de fs_sano
            
            % Calcular potencia en bandas y sus ratios
            delta_power = bandpower(pxx, f, [0.5 4], 'psd');
            theta_power = bandpower(pxx, f, [4 8], 'psd');
            alpha_power = bandpower(pxx, f, [8 13], 'psd');
            beta_power = bandpower(pxx, f, [13 30], 'psd');

            % Ratios
            theta_alpha_ratio_features(ch, w) = theta_power / alpha_power;
            beta_alpha_ratio_features(ch, w) = beta_power / alpha_power;
            theta_beta_ratio_features(ch, w) = theta_power / beta_power;
            theta_alpha_beta_ratio_features(ch, w) = (theta_power + alpha_power) / beta_power;
            theta_alpha_alpha_beta_ratio_features(ch, w) = (theta_power + alpha_power) / (alpha_power + beta_power);
            
            % Asimetría
            asimetria_features(ch, w) = skewness(window_data);
        end
    end

    % Concatenar todas las características en una sola matriz
    features = [std_features; mav_features; zc_features; kurtosis_features; theta_alpha_ratio_features; ...
                beta_alpha_ratio_features; theta_beta_ratio_features; theta_alpha_beta_ratio_features; ...
                theta_alpha_alpha_beta_ratio_features; asimetria_features]';

    % Eliminar columnas con más del 10% de NaN
    threshold_nan = 0.1 * size(features, 1);
    columns_to_keep = sum(isnan(features)) <= threshold_nan;
    features = features(:, columns_to_keep);

    % Reemplazar NaN con ceros en las columnas restantes
    features(isnan(features)) = 0;

    % Eliminar columnas con todos los valores cero
    non_constant_columns = std(features) > 0;
    features = features(:, non_constant_columns);

    % Normalizar las características
    features = (features - mean(features)) ./ std(features);
end