drop database if exists humana;

drop user if exists resetpass;
drop user if exists admin;

create database if not exists humana;

use humana;

create table if not exists pacientes(id_paciente varchar(20) not null,
nombre varchar(100),
apellido varchar(100),
notas_confidenciales varchar(50),
sexo varchar(1) not null,
fecha_nacimiento date not null,
antecedentes text,
diagnostico text,
condicion varchar(10) not null,
primary key (id_paciente));

create table if not exists pruebas(
id_prueba int not null auto_increment,
id_paciente varchar(20) not null,
fecha_prueba date not null,
hora_inicio time not null,
duracion int not null,
frecuencia int not null,
no_canales int not null,
prueba longblob not null,
primary key (id_prueba, id_paciente),
constraint fk_pruebas foreign key (id_paciente) references pacientes(id_paciente)
);

set global sql_generate_invisible_primary_key=1;

create table if not exists pruebas_datos(
id_prueba int not null,
canal_1 float not null,
canal_2 float not null,
canal_3 float not null,
canal_4 float not null,
canal_5 float not null,
canal_6 float not null,
canal_7 float not null,
canal_8 float not null,
canal_9 float not null,
canal_10 float not null,
canal_11 float not null,
canal_12 float not null,
canal_13 float not null,
canal_14 float not null,
canal_15 float not null,
canal_16 float not null,
canal_17 float not null,
canal_18 float not null,
canal_19 float not null,
canal_20 float not null,
canal_21 float,
canal_22 float,
canal_23 float,
canal_24 float,
canal_25 float,
canal_26 float,
canal_27 float,
canal_28 float,
canal_29 float,
canal_30 float,
canal_31 float,
canal_32 float,
canal_33 float,
canal_34 float,
canal_35 float,
constraint fk_pdatos foreign key (id_prueba) references pruebas(id_prueba)
) ENGINE=InnoDB;
ALTER TABLE pruebas_datos ALTER COLUMN my_row_id SET VISIBLE;
ALTER TABLE pruebas_datos RENAME COLUMN my_row_id to id;
ALTER TABLE pruebas_datos ALTER COLUMN id SET INVISIBLE;
set global sql_generate_invisible_primary_key=0;

create table if not exists usuarios(
usuario varchar(15),
correo varchar(60),
tipo varchar(15),
admin_usuarios boolean,
analizar_prueba boolean,
ingreso_pacientes boolean,
consulta_pacientes boolean,
consulta_confidencial boolean,
anotaciones_automaticas boolean,
crear_algoritmo boolean,
anotaciones_automaticas2 boolean,
primer_login boolean,
recuperar_contrasena boolean,
primary key (usuario)
);

insert into humana.usuarios values ('root','man13600@uvg.edu.gt' ,'Super User', true, true, true, true, true, true, true, true, false, true);

create table if not exists analisis(
id_analisis int not null auto_increment,
fecha date not null,
realizado_por varchar(50) not null,
notas varchar(50),
id_prueba int not null,
id_paciente varchar(20) not null,
canales_utilizados varchar(50) not null, 
primary key (id_analisis),
constraint fk_prueba_a foreign key (id_prueba) references pruebas(id_prueba),
constraint fk_paciente_a foreign key (id_paciente) references pruebas(id_paciente)
);

create table if not exists resultados_analisis(
id_resultados int not null auto_increment,
id_analisis int not null,
canal int not null,
inicio_vector int not null,
fin_vector int not null,
clasificacion varchar(50) not null,
primary key (id_resultados),
constraint fk_analisis foreign key (id_analisis) references analisis(id_analisis)
);

create table if not exists modelo(
id_modelo int not null auto_increment,
fecha_modelo date not null,
realizado_por varchar(50) not null,
modelo_utilizado varchar(20) not null,
descripcion varchar(50),
notas varchar(50),
id_prueba int not null,
primary key (id_modelo),
constraint fk_prueba foreign key (id_prueba) references pruebas(id_prueba)
);

create table if not exists resultados_modelo(
id int not null auto_increment,
id_modelo int not null,
mav float,
zc int,
type1_error int,
type2_error int,
Specificity float, 
AUC float,
AUC_Class varchar(10),
MSE float,
RMSE float,
MAE float,
R2 float,
primary key (id),
constraint fk_modelo foreign key (id_modelo) references modelo(id_modelo)
);

create table if not exists config(
correo varchar(500) not null,
pass varchar(500) not null,
asunto varchar(100) not null,
mensaje_1 varchar(500) not null,
mensaje_2 varchar(500) not null,
server varchar(500) not null
);


insert into humana.config values('eeganalysistoolbox@gmail.com','uvg@2022','EEG Analysis Toolbox - Recuperar contraseña','->','Puedes cambiarla en cualquier momento en la pantalla de configuraci�n despu�s de iniciar sesi�n.','smtp.gmail.com');

create user if not exists resetpass;
alter user resetpass identified by '2023';
grant select on humana.config to resetpass;
grant select on humana.usuarios to resetpass;
grant create user on *.* to resetpass;


create user if not exists admin;
alter user admin identified by '1234';

GRANT ALL PRIVILEGES ON humana.* TO admin WITH GRANT OPTION;
GRANT SELECT ON mysql.user TO admin WITH GRANT option;
GRANT CREATE USER ON *.* TO admin WITH GRANT option;
insert into humana.usuarios values ('admin','men19673@uvg.edu.gt' ,'Super User', true, true, true, true, true, true, true, true, false, true);

GRANT FILE ON *.* TO admin;

SET GLOBAL local_infile=1; 
RESTART;