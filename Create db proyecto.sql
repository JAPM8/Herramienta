create database if not exists proyecto;

use proyecto;

create table if not exists pacientes(
	id_paciente varchar(4) not null,
	Sexo varchar(1) not null,
	Edad int not null,
	Condición varchar(10) not null,
	primary key (id_paciente)
);

create table if not exists pruebas(
	id_prueba int not null,
	id_paciente varchar(4) not null,
	Fecha date not null,
	Hora time not null,
	Duración int not null,
	Frecuencia int not null,
	No_canales int not null,
	Prueba longblob,
	primary key (id_prueba, id_paciente),
	constraint fk_paciente foreign key (id_paciente) references pacientes(id_paciente)
);

create table if not exists procesamiento(
	id_prueba int not null,
	duracion int not null,
	frecuencia int not null,
	zc int not null,
	primary key (id_prueba),
	constraint fk_prueba foreign key (id_prueba) references pruebas(id_prueba)
);

create table if not exists pruebas_datos(
	id int not null auto_increment,
	id_prueba int not null,
	datos int not null,
	primary key (id),
	constraint fk_prueba2 foreign key (id_prueba) references pruebas(id_prueba)
);

#drop database if exists proyecto;