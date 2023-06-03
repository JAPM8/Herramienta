create database if not exists pruebas;

use pruebas;

create table if not exists pacientes(
	id_paciente varchar(4) not null,
	Sexo enum('F','M') not null,
	Edad int not null,
	Condicion enum('SANO','ENFERMO') not null,
	EEG varchar(100),
	primary key (id_paciente)
);

INSERT INTO pacientes VALUES ("P001", "M", 26, "ENFERMO",NULL);
INSERT INTO pacientes VALUES ("P002", "M", 23, "SANO",NULL);

#drop database if exists pruebas;