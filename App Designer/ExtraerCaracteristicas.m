function features = ExtraerCaracteristicas(EEGData, Fs, window_size)
    % Función para extraer varias caracteristicas de una señal EEG 
    % EEGData: Matriz con los datos EEG (canales x muestras)
    % Fs: Frecuencia de muestreo
    % window_size: Tamaño de la ventana en segundos (por defecto 30 segundos)
    
    window_size = 30;  % Definir tamaño de ventana por defecto a 30 segundos
    
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
            % Calcular los índices de inicio y fin de la ventana de datos actual
            start_index = (w-1) * samples_per_window + 1;
            end_index = min(w * samples_per_window, num_samples);
            window_data = EEGData(ch, start_index:end_index);  % Extraer datos de la ventana actual
    
            % Calcular características estadísticas
    
            % Desviación estándar de la ventana actual - mide la variabilidad de la señal
            std_features(ch, w) = std(window_data);
    
            % Valor absoluto medio (MAV) - calcula el promedio del valor absoluto de la señal,
            % una medida que refleja la actividad general de la señal
            mav_features(ch, w) = mean(abs(window_data));
            
            % Cruces por cero (ZC) - cuenta el número de veces que la señal cruza el eje cero,
            % lo cual da una indicación de la frecuencia de cambios en la señal
            zc_value = ZC(window_data, 0);  % Llamar a la función personalizada de cruces por cero
            if isscalar(zc_value)
                zc_features(ch, w) = zc_value;  % Si ZC devuelve un escalar, lo almacena
            else
                zc_features(ch, w) = NaN;  % Si no es un escalar, asigna NaN y lanza una advertencia
                
            end
            
            % Curtosis - mide la "picudez" de la distribución de los datos, valores altos pueden
            % indicar la presencia de picos en la señal, lo cual es relevante en EEG
            kurtosis_features(ch, w) = kurtosis(window_data);
    
            % Calcular PSD (Densidad Espectral de Potencia) y ratios de bandas de frecuencia
    
            % 'pwelch' estima la Densidad Espectral de Potencia (PSD) usando el método de Welch,
            % dividiendo la señal en segmentos superpuestos, calculando el periodograma de cada
            % segmento, y promediando los resultados para una estimación más suave y confiable
            [pxx, f] = pwelch(window_data, [], [], [], Fs);
    
            % Calcular la potencia en diferentes bandas de frecuencia
            % Utiliza 'bandpower' para calcular la potencia en la señal PSD en cada banda
            delta_power = bandpower(pxx, f, [0.5 4], 'psd');  % Banda delta (0.5-4 Hz)
            theta_power = bandpower(pxx, f, [4 8], 'psd');    % Banda theta (4-8 Hz)
            alpha_power = bandpower(pxx, f, [8 13], 'psd');   % Banda alpha (8-13 Hz)
            beta_power = bandpower(pxx, f, [13 30], 'psd');   % Banda beta (13-30 Hz)
    
            % Calcular ratios de potencia entre las bandas de frecuencia
            % Estos ratios son comunes en el análisis de EEG para describir relaciones entre
            % diferentes actividades cerebrales asociadas a distintas bandas de frecuencia
            theta_alpha_ratio_features(ch, w) = theta_power / alpha_power;
            beta_alpha_ratio_features(ch, w) = beta_power / alpha_power;
            theta_beta_ratio_features(ch, w) = theta_power / beta_power;
            theta_alpha_beta_ratio_features(ch, w) = (theta_power + alpha_power) / beta_power;
            theta_alpha_alpha_beta_ratio_features(ch, w) = (theta_power + alpha_power) / (alpha_power + beta_power);
            
            % Asimetría (Skewness) - mide la asimetría de la distribución de los datos en la ventana
            % Valores positivos o negativos indican una distribución sesgada a derecha o izquierda
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