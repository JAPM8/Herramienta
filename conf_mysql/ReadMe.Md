### Configurar conexión ODBC a MySQL en Windows

<p><strong>Realizado por:</strong> <a href="https://github.com/Men19673" target="_blank">
  <img src="https://img.shields.io/badge/Men19673-a?style=social&logo=github" alt="Men19673"/>
</a></p>

1. Buscar en programas de Windows "ODBC". Abrir el programa "Origenes de datos ODBC..." o "ODBC Data Sources" si su sitema se encuentra en inglés.\
![mysql conf1](1.png "conf1")
2. Ingresar en "Agregar".\
![mysql conf2](2.png "conf2")
3. Seleccionar "MySQL ODBC 8.0 ANSI Driver".\
![mysql conf3](3.png "conf3")
4. Ingresar los datos que se muestran a continuación y crear la conexión. Es importante usar "toolbox" como nombre de la conexión. Debido a que de esta forma está definida en la aplicación EEG Analysis Toolbox tanto en standalone, como en el App Designer.\
![mysql conf4](4.png "conf4")
5. Verifique que el conector "toolbox" se encuentre en la lista de conectores.\
![mysql conf5](5.png "conf5")
6. Cerrar.
