#Copiar y pegar los siguientes comandos en la linea de comando de mysql
#1
use humana

#2
DELIMITER $$

#3
#esto ejecutarlo desde matlan

create user if not exists jorge2;

#-
CREATE PROCEDURE asignarpermisos(in nombre varchar(15), in tipo varchar(15), in admu boolean, in analizar boolean, in ingreso boolean, in consulta boolean, in conultac boolean)
begin
	if admu then
		GRANT ALL PRIVILEGES ON *.* TO jorge2 WITH GRANT OPTION;
	end if;
end $$

GRANT ALL PRIVILEGES ON *.* TO nombre WITH GRANT OPTION;

call asignarpermisos('jorge2', 'superuser', true, true, true, true, true);
#esto ejecutarlo desde matlan
alter user jorge2 identified by '1234';

drop procedure asignarpermisos;
grant select on mysql.user to jor;
drop user jorge;
delete from humana.usuarios where usuario = 'jorge';
alter user nombre identified by '1234';

select * from mysql.`user` u;
select * from mysql.user u where u.User not in ('root', 'k4');
select * from humana.usuarios u;

select * from humana.pacientes p;
select * from humana.pruebas p ;
select * from humana.pruebas_datos pd;

drop user jorge;
drop user luis;
drop user luis2;
drop user resetpass;
delete from humana.usuarios where usuario != 'root';

alter user koke account lock;
alter user koke account unlock;

select u.`User`, u2.tipo, u.authentication_string, u.account_locked, u2.admin_usuarios, u2.analizar_prueba, u2.ingreso_pacientes, u2.consulta_pacientes, u2.consulta_confidencial from mysql.user u, humana.usuarios u2 where u.`User` = u2.usuario;

update humana.usuarios u set u.admin_usuarios = false where u.usuario = 'root';

update humana.usuarios u set u.tipo = 'rolex' where u.usuario = 'koke';

create user if not exists resetpass;
alter user resetpass identified by '2022';
grant select on humana.usuarios to resetpass;
GRANT CREATE USER ON *.* TO resetpass;
alter user luis identified by '2222';

#para los que tengan rol de administradores de usuarios
grant all privileges on humana.usuarios to jor with grant option;
grant select on mysql.user to jor with grant option;
grant create user on *.* to jor with grant option;

#para los que tengan rol para analizar pruebas
pruebas_datos
pruebas
analisis
resultado_analisis
modelo
resultados_modelo

delete from humana.usuarios u where u.usuario = 'koke';

drop table humana.usuarios;