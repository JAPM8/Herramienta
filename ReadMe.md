![UVG logo](https://res.cloudinary.com/webuvg/image/upload/f_auto,q_auto,fl_lossy,w_200/v1561048457/WEB/institucional/Logo_Cuadro_Verde3x.jpg "UVG logo")

# Herramienta de Software con una Base de Datos Integrada para el Estudio de la Epilepsia - Fase III

## Manual de instalación

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

## Descarga de  MySQL

1. Ingresar a <https://www.mysql.com/>
2. Ingresar a Downloads\
![mysql downloads](descarga_mysql/ingresardownloads.png "Downloads")
3. Ingresar a "MySQL Community (GPL) Downloads"\
![mysql community downloads](descarga_mysql/downloads2.png "Community Downloads")
4. Ingresar a "MySQL Installer for Windows"\
![mysql Installer](descarga_mysql/downloads3.png "Installers")
5. Seleccione la  última version de MySQL 8.0.XX y luego verifique que se encuentre Windows seleccionado. Descargar la opción A si la maquina donde se instalará tiene acceso a internet y B si no tiene acceso a internet.\
![mysql A y B downloads](descarga_mysql/downloads4.png "A y B Downloads")
6. Si no se cuenta con cuenta de oracle es necesario crear una, de lo contrario simplemente iniciar sesión.\
![mysql account downloads](descarga_mysql/downloads5.png "account Downloads")
7. Descargar el instalador.\
![mysql final downloads](descarga_mysql/downloads6.png "final Downloads")

## Instalación de MySQL

1. Ejecutar el instalador.
2. Seleccionar la instalación tipo "Custom".\
![mysql install1](install_mysql/1.png "install1")
3. Seleccionar únicamente MySQL Server y el conector ODBC x64.\
![mysql install2](install_mysql/2.png "install2")
4. Ejecutar la descarga. Obviar este paso, en caso de que se utiliza la versión sin internet (Opción B en la sección anterior).\
![mysql install3](install_mysql/3.png "install3")
5. Al terminar la descara, ejecute la instalación.\
![mysql install4](install_mysql/4.png "install4")
6. Continuar con el asistente de instalación hasta la pantalla de configuración inicial.\
![mysql install5](install_mysql/5.png "install5")\
7. Verificar que se cumplan las siguientes configuraciones.\
![mysql install6](install_mysql/6.png "install6")
![mysql install7](install_mysql/7.png "install7")
8. Ingresar una contraseña para el usuario "root" de la base de datos. Debe recordar esta contrseña, ya que se utilizara para crear el modelo relacional y es el único usuario con todos los permisos en la base de datos y en la aplicación EEG Analysis Toolbox.\
![mysql install8](install_mysql/8.png "install8")
9. Verificar que se cumplan las siguientes configuraciones.\\
![mysql install9](install_mysql/9.png "install9")
10. Verificar que se cumplan las siguientes configuraciones.\\
![mysql install10](install_mysql/10.png "install10")
10. Ejecute la configuración, continuar con el asistente de instalación hasta la última pantalla y salir.\
![mysql install11](install_mysql/11.png "install11")

### Configurar conexión ODBC a MySQL en Windows

1. Buscar en programas de Windows "ODBC". Abrir el programa "Origenes de datos ODBC..." o "ODBC Data Sources" si su sitema se encuentra en inglés.\
![mysql conf1](conf_mysql/1.png "conf1")
2. Ingresar en "Agregar".\
![mysql conf2](conf_mysql/2.png "conf2")
3. Seleccionar "MySQL ODBC 8.0 ANSI Driver".\
![mysql conf3](conf_mysql/3.png "conf3")
4. Ingresar los datos que se muestran a continuación y crear la conexión. Es importante usar "toolbox" como nombre de la conexión. Debido a que de esta forma está definida en la aplicación EEG Analysis Toolbox tanto en standalone, como en el App Designer.\
![mysql conf4](conf_mysql/4.png "conf4")
5. Verifique que el conector "toolbox" se encuentre en la lista de conectores.\
![mysql conf5](conf_mysql/5.png "conf5")
6. Cerrar.

## Instalación del Toolbox

En la carpeta "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer\EpilepticEEGAnalysisToolbox\for_redistribution" del repositorio de Github se encuentran los executables para Windows del toolbox.

Nota: Si se desea editar o utilizar la app para realizar modificaciónes o pruebas no es necesario seguir estos pasos. Basta con abrir el archivo principal.mlapp ubicado en "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer".

1. Iniciar instalador ubicado en "\GitHub\Datos-Epilepsia-2021\Jorge-Diego-Manrique\App Designer\EpilepticEEGAnalysisToolbox\for_redistribution". Este instaldor instalará el toolbox y el runtime de Matlab requerido para ejecutar la aplicación.\
![toolbox1](install_toolbox/1.png "toolbox1")
2. Seguir los pasos del instalador. Seleccionar si se desea crear un acceso directo al toolbox en el escritorio y continuar.\
![toolbox2](install_toolbox/2.png "toolbox2")
3. Cuando finalice la instalación cerrar la ventana e iniciar la applicación.\
![toolbox3](install_toolbox/3.png "toolbox3")

### Crear modelo relacional en MySQL
Al contar con la Toolbox y la base de datos instalada, lo único que falta es crear el modelo relaciónal en MySQL. En esta versión de la herramienta, ya no es necesario interactuar con el comando de la base de datos. 
1. Iniciar la aplicación Toolbox.
2. Dirigirse a la pestaña "DB", en la ventana principal. Ninguna otra pestaña tendrá botones activos, únicamente esta.
![toolboxDB1](install_toolbox/4.png "toolboxDB")
3. Ingrese la contraseña que colocó al instalar la base de datos y presione "Regenerar Base".
4. Obtendra un mensaje de confirmación en el que debe de presionar "Sí". 
5. Espere a obtener el mensaje de confirmación de que el modelo relacional fue creado.
