#Tablas datos del analisis y resultados
use humana;

create table if not exists analisis(
	id_analisis int not null auto_increment,
	fecha date not null,
	realizado_por varchar(50) not null,
	notas varchar(50),
	id_prueba int not null,
	id_paciente varchar(20) not null,
	canales_utilizados varchar(50) not null, #revisar tipo de dato
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
	clasificación varchar(50) not null,
	primary key (id_resultados),
	constraint fk_analisis foreign key (id_analisis) references analisis(id_analisis)
);
