datasource = "toolbox";
username = "root";
password = "2023";
conn = database(datasource,username,password);
txtnum = sprintf('%i.txt',i)
execute(conn,['LOAD DATA INFILE ' ...
    ' ''C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tmp' ...
    txtnum...
    ''' INTO TABLE humana.pruebas_datos ' ...
    'FIELDS TERMINATED BY '';'' LINES TERMINATED ' ...
    'BY ''\n'''])