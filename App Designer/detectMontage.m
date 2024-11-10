function isBipolar = detectMontage(channelNames)
    
    % Caso 1: Detectar si es un montaje referencial
    % Contiene "REF" o "-REF" en los nombres de los canales
    referentialPattern = contains(channelNames, 'REF') | contains(channelNames, 'LE');
    
    % Caso 2: Detectar si es un montaje bipolar
    % Contiene un guion "-" pero NO contiene "REF" en los nombres
    bipolarPattern = contains(channelNames, '-') & (~contains(channelNames, 'REF') | ~contains(channelNames, 'LE'));
    
    % Caso 3: Montaje referencial simple (sin guion ni "REF")
    % No contiene guion "-" y no contiene "REF"
    simpleReferentialPattern = ~contains(channelNames, '-') & (~contains(channelNames, 'REF') | ~contains(channelNames, 'LE'));
    
    % Determinar el tipo de montaje
    if mean(referentialPattern) > 0.9
        isBipolar = false;
    elseif mean(bipolarPattern) > 0.9
        isBipolar = true;
    elseif mean(simpleReferentialPattern) > 0.9
        isBipolar = false;
    else
        isBipolar = false;  % O manejar como un caso especial
    end
end