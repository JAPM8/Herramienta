% Código para reemplazar función edfread con la que proporciona Matlab
clear; clc;

path = "C:\Users\javyp\Documents\UNIVERSIDAD\GraduationGateway\Tesis\Data" + ...
       "\Datos_TUH\v2.0.3\edf\train\aaaaaljo\s001_2011\01_tcp_ar\aaaaaljo_s001_t000.edf";

tic

hdr = edfinfo(path);
hdr = get(hdr);
hdr.Fs = hdr.NumSamples/seconds(hdr.DataRecordDuration);

data = edfread(path);

toc 

tic

[hdr2,data2] = EDF_read(path);

toc

% lectura = data.("EEGFP1_REF"){1};