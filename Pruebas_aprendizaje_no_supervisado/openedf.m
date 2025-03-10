% Código realizado por: Javier Alejandro Pérez Marín (20183) - 2024
% Funcional 2024A-2024B

function [hdr, record] = openedf(filename)
% openedf: Función para apertura de archivos .edf/.EDF y su respectivo
% formateo. Sustituye la función EDF_read utilizada en fases anteriores,
% dado que ahora MATLAB proporciona la función edfread. 
% filename es la ruta de acceso al archivo .EDF
% hdr es el header de información del archivo y record son las señales

% Se verifica que al llamar la función solo se proporcione un argumento
if nargin ~= 1
    error('openedf: Solo se requiere un argumento (ruta de acceso al EDF).');
end

% Se verifica que el argumento recibido sea una ruta de acceso a un archivo
if ~isfile(filename)
    error('openedf: Verifique la ruta de acceso, no se encontró archivo.');
end

try
    
    % Se obtiene header del edf (devuelve objeto edfinfo)
    hdr = edfinfo(filename);

    % Objeto edfinfo se convierte a struct modificable
    hdr = get(hdr);

    % Cálculo frecuencia de muestreo y se incluye propiedad en header
    hdr.Fs = hdr.NumSamples/seconds(hdr.DataRecordDuration);

    % Se leen señales de EDF
        % Note que edfread tiene más opciones para una lectura selectiva
    record = table2cell(edfread(filename));
    
    % Dado que hay celdas que devuelven solo un valor escalar, se
    % formatean para que cumplan con presentar un valor por cada timestep
    for i = 1:numel(record) % numel devuelve la cantidad total de celdas
        if diff(size(record{i})) == 0 % Si es un valor escalar (celda de dimensiones iguales)
            record(i) = {repmat(cell2mat(record(i)),hdr.Fs(1),1)};
        end
    end
    
    % Se devuelven señales en formato canales - columna, timesteps - fila
    record = cell2mat(record);
    
catch ME

    % Control de errores
    disp(ME);
    error('openedf: Verifique que la ruta de acceso.');  

end