![UVG logo](https://res.cloudinary.com/webuvg/image/upload/f_auto,q_auto,fl_lossy,w_200/v1561048457/WEB/institucional/Logo_Cuadro_Verde3x.jpg "UVG logo")

# Herramienta de Software con una Base de Datos Integrada para el Estudio de la Epilepsia - Fase II

## Manual de instalación

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

## Descarga de  MySQL

1. Ingresar a <https://www.mysql.com/>
2. Ingresar a Downloads\
![mysql downloads](/Jorge-Diego-Manrique/descarga_mysql/ingresardownloads.png "Downloads")
3. Ingresar a "MySQL Community (GPL) Downloads"\
![mysql community downloads](/Jorge-Diego-Manrique/descarga_mysql/downloads2.png "Community Downloads")
4. Ingresar a "MySQL Installer for Windows"\
![mysql Installer](/Jorge-Diego-Manrique/descarga_mysql/downloads3.png "Installers")
5. Descargar la opción A si la maquina donde se instalará tiene acceso a internet y B si no tiene acceso a internet.\
![mysql A y B downloads](/Jorge-Diego-Manrique/descarga_mysql/downloads4.png "A y B Downloads")
6. Si no se cuenta con cuenta de oracle es necesario crear una, de lo contrario simplemente iniciar sesión.\
![mysql account downloads](/Jorge-Diego-Manrique/descarga_mysql/downloads5.png "account Downloads")
7. Descargar el instalador.\
![mysql final downloads](/Jorge-Diego-Manrique/descarga_mysql/downloads6.png "final Downloads")

## Instalación de MySQL

1. Ejecutar el instalador.
2. Seleccionar la instalación tipo "Custom".\
![mysql install1](/Jorge-Diego-Manrique/install_mysql/1.png "install1")
3. Seleccionar únicamente MySQL Server y el conector ODBC x64.\
![mysql install2](/Jorge-Diego-Manrique/install_mysql/2.png "install2")
4. Ejecutar la instalación.\
![mysql install3](/Jorge-Diego-Manrique/install_mysql/3.png "install3")
5. Continuar con el asistente de instalación hasta la pantalla de configuración inicial. Colocar la configuración como se muestra a continuación.\
![mysql install6](/Jorge-Diego-Manrique/install_mysql/6.png "install6")\
![mysql install7](/Jorge-Diego-Manrique/install_mysql/7.png "install7")
6. Ingresar una contraseña para el usuario root de la base de datos Es importante recordar esta contrseña ya que se utilizara para crear el modelo relacional y es el único usuario con todos los permisos en la base de datos y en la app de Matlab.\
![mysql install8](/Jorge-Diego-Manrique/install_mysql/8.png "install8")
7. Asegurarse que la configuración del servicio se muestre de la siguiente forma:\
![mysql install9](/Jorge-Diego-Manrique/install_mysql/9.png "install9")
8. Aplicar la configuración, continuar con el asistente de instalación hasta la última pantalla y salir.\
![mysql install10](/Jorge-Diego-Manrique/install_mysql/10.png "install10")

## Configuración adicional requerida de MySQL

### Modificar el parametro max_allowed_packet

1. Abrir notepad con permisos de administrador.
2. Abrir archivo "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini"\
![mysql conf1](/Jorge-Diego-Manrique/conf_mysql/1.png "conf1")
3. Buscar el parametro "max_allowed_packet=4M" y cambiarlo por" max_allowed_packet=1G".\
![mysql conf2](/Jorge-Diego-Manrique/conf_mysql/2.png "conf2")
4. Guardar los cambios.y cerrar notepad.
5. Buscar en programas de Windows "Servicios" o "Services" dependiendo del idioma instalado en Windows y abrir el programa.\
![mysql conf3](/Jorge-Diego-Manrique/conf_mysql/3.png "conf3")
6. .Buscar el servicio "MySQL80", seleccionarlos, clic derecho y presionar reiniciar.\
![mysql conf4](/Jorge-Diego-Manrique/conf_mysql/4.png "conf4")
7. Cerrar programa.

### Configurar conexión ODBC a MySQL en Windows

1. Buscar en programas de Windows "ODBC" y abrir el programa "Origenes de datos ODBC...".\
![mysql conf5](/Jorge-Diego-Manrique/conf_mysql/5.png "conf5")
2. Ingresar en "Agregar".\
![mysql conf6](/Jorge-Diego-Manrique/conf_mysql/6.png "conf6")
3. Seleccionar "MySQL ODBC 8.0 ANSI Driver".\
![mysql conf7](/Jorge-Diego-Manrique/conf_mysql/7.png "conf7")
4. Ingresar los datos que se muestran a continuación y crear la conexión. Es importante usar "toolbox" como nombre de la conexión ya que de esta forma está definida en la app de Matlab.\
![mysql conf8](/Jorge-Diego-Manrique/conf_mysql/8.png "conf8")
5. Cerrar.

# Crear modelo relacional en MySQL

1. Buscar en programas de Windows "MySQL 8.0 Command Line Client" Y abrir el programa.\
![mysql modelo1](/Jorge-Diego-Manrique/crear_modelo/1.png "modelo1")
2. Ingresar la contraseña del usuario root (La definida en la instalación de MySQL):\
![mysql modelo2](/Jorge-Diego-Manrique/crear_modelo/2.1.png "modelo2")
3. Ingresar lo siguiente para ejecutar el archivo "Creates consolidado.sql"

```sh
source <Ruta_del_archivo>\Creates consolidado.sql
```

Nota: En la última versión de MySQL el comando source se escribe: (\.). Al realizar la ejecución del comando, es posible recibir un error como este: ERROR 1366 (HY000): Incorrect string value: '\xF1a' for column 'asunto' at row 1
mysql> \. <Ruta_del_archivo>\Creates consolidado.sql
Query OK, 9 rows affected (0.12 sec)
Verificar que comando es necesario para la versión del momento.

![mysql modelo3](/Jorge-Diego-Manrique/crear_modelo/3.png "modelo3")\
4.  Cerrar la ventana cuando termine de ejecutarse el script.

# Instalación del Toolbox

En la carpeta "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer\EpilepticEEGAnalysisToolbox\for_redistribution" del repositorio de Github se encuentran los executables para Windows del toolbox.

Nota: Si se desea editar o utilizar la app para realizar modificaciónes o pruebas no es necesario seguir estos pasos. Basta con abrir el archivo principal.mlapp ubicado en "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer".

1. Iniciar instalador ubicado en "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer\EpilepticEEGAnalysisToolbox\for_redistribution". Este instaldor instalará el toolbox y el runtime de Matlab requerido para ejecutar la aplicación.\
![mysql toolbox1](/Jorge-Diego-Manrique/install_toolbox/1.png "toolbox1")
2. Seguir los pasos del instalador. Seleccionar si se desea crear un acceso directo al toolbox en el escritorio y continuar.\
![mysql toolbox3](/Jorge-Diego-Manrique/install_toolbox/3.png "toolbox3")
3. Cuando finalice la instalación cerrar la ventana e iniciar la applicación.\
![mysql toolbox7](/Jorge-Diego-Manrique/install_toolbox/7.png "toolbox7")
