datasource = "toolbox";
username = "root";
password = "2023";
conn = database(datasource,username,password);

execute(conn,['LOAD DATA INFILE ' ...
    ' ''C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tmp.txt'' INTO TABLE humana.pruebas_datos ' ...
    'FIELDS TERMINATED BY '';'' LINES TERMINATED ' ...
    'BY ''\n'''])