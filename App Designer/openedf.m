function [hdr, record] = openedf(path)
% openedf Función para apertura de archivos .edf/.EDF y formateo.
% Función creada por Javier Pérez: path es la ruta de acceso al archivo
% .EDF, hdr es el header de información del archivo y record son las
% señales

if ~nargin
    error('openedf: Solo se requiere un argumento (ruta de acceso al EDF).');
end

if ~isfile(path)
    error('openedf: Verifique la ruta de acceso, no se encontró archivo.');
end

try
    % Se obtiene header del archivo (devuelve objeto edfinfo)
    hdr = edfinfo(path);
    
    % Objeto edfinfo se convierte a struct modificable
    hdr = get(hdr);
    
    % Cálculo frecuencia de muestreo y se incluye propiedad en header
    hdr.Fs = hdr.NumSamples/seconds(hdr.DataRecordDuration);
catch
    error('openedf: Verifique que la ruta de acceso sea de un archivo .edf/.EDF.');  
end