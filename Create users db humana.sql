#drop user adm;
#drop user sec1;
#drop user sec2;

create user if not exists adm identified by '1234';
grant all privileges on humana.analisis to adm;
grant all privileges on humana.pacientes to adm;
grant all privileges on humana.pruebas to adm;
grant all privileges on humana.pruebas_datos to adm;
grant all privileges on humana.resultados_analisis to adm;

create user if not exists sec1 identified by '1234';
grant insert, update, select on humana.analisis to sec1;
grant insert (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion), 
	update (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion), 
	select (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion) on humana.pacientes to sec1;
grant insert, update, select on humana.pruebas to sec1;
grant insert, update, select on humana.pruebas_datos to sec1;
grant insert, update, select on humana.resultados_analisis to sec1;

create user if not exists sec2 identified by '1234';
grant select on humana.analisis to sec2;
grant select (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion) on humana.pacientes to sec2;
grant select on humana.pruebas to sec2;
grant select on humana.pruebas_datos to sec2;
grant select on humana.resultados_analisis to sec2;

show grants for adm;
show grants for sec1;
show grants for sec2;

select user, account_locked from mysql.user where account_locked != 'Y';

grant all privileges on humana.usuarios to jor;

grant update (primer_login) on humana.usuarios to tote;


grant all PRIVILEGES (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion) on humana.pacientes to sec1;

GRANT ALL PRIVILEGES (id_paciente, sexo, fecha_nacimiento, antecedentes, diagnostico, condicion) ON humana.pacientes to todo;

select u.authentication_string from mysql.`user` u where `User` = 'koke';

REVOKE ALL PRIVILEGES ON humana.usuarios from koke;

grant all privileges on humana.usuarios to sec1;

grant select on humana.usuarios  to sec1;

revoke select on humana.usuarios from sec1;

revoke all privileges on humana.usuarios from sec1;

show grants for koke;

REVOKE ALL privileges, grant option from koke;

drop user sec1;
