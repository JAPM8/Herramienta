drop database if exists humana;

create database if not exists humana;

use humana;

create table if not exists pacientes(
	id_paciente varchar(20) not null,
	nombre varchar(100),
	apellido varchar(100),
	notas_confidenciales varchar(50),
	sexo varchar(1) not null,
	fecha_nacimiento date not null,
	antecedentes text,
	diagnostico text,
	condicion varchar(10) not null,
	primary key (id_paciente)
);

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

create table if not exists pruebas_datos(
	id int not null auto_increment,
	id_prueba int not null,
	canal_1 float(8,3) not null,
	canal_2 float(8,3) not null,
	canal_3 float(8,3) not null,
	canal_4 float(8,3) not null,
	canal_5 float(8,3) not null,
	canal_6 float(8,3) not null,
	canal_7 float(8,3) not null,
	canal_8 float(8,3) not null,
	canal_9 float(8,3) not null,
	canal_10 float(8,3) not null,
	canal_11 float(8,3) not null,
	canal_12 float(8,3) not null,
	canal_13 float(8,3) not null,
	canal_14 float(8,3) not null,
	canal_15 float(8,3) not null,
	canal_16 float(8,3) not null,
	canal_17 float(8,3) not null,
	canal_18 float(8,3) not null,
	canal_19 float(8,3) not null,
	canal_20 float(8,3) not null,
	canal_21 float(8,3),
	canal_22 float(8,3),
	canal_23 float(8,3),
	canal_24 float(8,3),
	canal_25 float(8,3),
	canal_26 float(8,3),
	canal_27 float(8,3),
	canal_28 float(8,3),
	canal_29 float(8,3),
	canal_30 float(8,3),
	canal_31 float(8,3),
	canal_32 float(8,3),
	canal_33 float(8,3),
	canal_34 float(8,3),
	canal_35 float(8,3),
	primary key (id),
	constraint fk_pdatos foreign key (id_prueba) references pruebas(id_prueba)
);

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
	primary key (usuario)
);

insert into humana.usuarios values ('root','man13600@uvg.edu.gt' ,'SuperUser', true, true, true, true, true, true, true, true, false);

#Crear usuario encargado de la consulta de los correos en recuperar contraseña
create user if not exists resetpass;
alter user resetpass identified by '2022';
grant select on humana.usuarios to resetpass;
grant create user on *.* to resetpass;

#Crear usuario con permisos de administrador capaz de crear usuarios y asignar permisos
create user if not exists admin;
alter user admin identified by '1234';
GRANT ALL PRIVILEGES ON humana.usuarios TO admin WITH GRANT option;
GRANT SELECT ON mysql.user TO admin WITH GRANT option;
GRANT CREATE USER ON *.* TO admin WITH GRANT option;
insert into humana.usuarios values ('admin','man13600@uvg.edu.gt' ,'SuperUser', true, true, true, true, true, true, true, true, false);

/*GMail
 * eeganalysistoolbox@gmail.com
 * uvg@2022
 */
