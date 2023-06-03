use humana;

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
	Specificity float, #true negatives rate
	AUC float,
	AUC_Class varchar(10),
	MSE float,
	RMSE float,
	MAE float,
	R2 float,
	primary key (id),
	constraint fk_modelo foreign key (id_modelo) references modelo(id_modelo)
);