datasource = "toolbox";
username = "root";
password = "2023";
conn = database(datasource,username,password);
Createsconsolidado_strings = importdata('Creates_consolidado.sql', ';')
query = strjoin(Createsconsolidado_strings);
query= strsplit(query, ';')
% load('Createsconsolidado_string.mat');
for i  = 1:length(query)-1 %ECl split crea una celda extra
    queryexe= strcat(query{i},';')
    execute(conn,queryexe);    
end


