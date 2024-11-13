<p align="center">
  <img src="https://res.cloudinary.com/webuvg/image/upload/f_auto,q_auto,w_169,c_scale,fl_lossy,dpr_0.90/v1641327930/WEB/Nosotros/Imagen%20Institucional/Logotipo%20UVG/Logotipo%20UVG/logotipo-uvg_thumb2x.jpg" alt="Logo UVG" width="150" height="43"/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRotDGBXGiNzq-fq9I0_sjAT2RLeqjDtCuK_ChIFjFW7ZdjVP9H" alt="Logo Facultad de Ingeniería" width="150" height="43"/>
</p>

<h1 align="center">Aplicación de algoritmos de aprendizaje automático para la identificación y categorización de segmentos de interés en señales bioeléctricas para el estudio de la epilepsia</h1>

<h2 align="center">Fase V</h2>

<p align="center"><strong>Autores:</strong> <a href="mailto:per20183@uvg.edu.gt" target="_blank">Javier Alejandro Pérez Marín</a>, <a href="mailto:ixc18486@uvg.edu.gt" target="_blank">Dylan Antonio Ixcayau Morán</a></p>

<p align="center"><strong>Asesor:</strong> <a href="mailto:larivera@uvg.edu.gt" target="_blank">Dr. Luis Alberto Rivera Estrada</a></p>

<p align="center"><strong>Departamento de Ingeniería Electrónica, Mecatrónica y Biomédica</strong></p>

<p align="center">
  <img src="https://img.shields.io/badge/STATUS-EN_DESARROLLO-green" alt="Fase en desarrollo"/>
  <img src="https://img.shields.io/github/contributors/japm8/Herramienta" alt="GitHub contributors"/>
  <img src="https://img.shields.io/github/languages/top/japm8/Herramienta" alt="GitHub top language" >
 </p>

## **Descripción**

Este trabajo de graduación tuvo como objetivo principal desarrollar algoritmos de aprendizaje automático para identificar y categorizar segmentos de interés en señales bioeléctricas de pacientes con epilepsia, utilizando electroencefalogramas (EEG). 

La epilepsia es un trastorno neurológico que afecta a millones de personas en el mundo, esta se caracteriza por episodios de actividad eléctrica anormal en el cerebro que se manifiestan como crisis epilépticas. Debido a que el análisis de EEGs es un proceso riguroso y manual, esta investigación buscó optimizar este proceso mediante una herramienta automatizada para la detección de patrones asociados a episodios epilépticos.

Este trabajo se presenta como la quinta fase de esta línea de investigación, cuyo desarrollo incluye la actualización y optimización de la herramienta *Epileptic EEG Analysis Toolbox*. A la vez que, se exploraron los enfoques de [aprendizaje supervisado](#Enfoque-aprendizaje-supervisado) y [no supervisado](#Enfoque-aprendizaje-no-supervisado).

<br>

<p align="center">
  <img src="https://i.gifer.com/3YB1.gif" alt="Fase 1 - EEG" width="30%"/>
  <img src="https://i.gifer.com/9P8h.gif" alt="Fase 2 - EEG" width="30%"/>
  <img src="https://i.gifer.com/origin/bb/bb3c10a9aebc133d55b8ae9d76abe825.gif" alt="Fase 3 - EEG" width="30%"/>
</p>

<p align="center"><i>Fuente: <a href="https://i.gifer.com/3YB1.gif" target="_blank">Gifer</a>, <a href="https://i.gifer.com/9P8h.gif" target="_blank">Gifer</a> y <a href="https://i.gifer.com/origin/bb/bb3c10a9aebc133d55b8ae9d76abe825.gif" target="_blank">Gifer</a></i></p>

<h2>Enfoque aprendizaje supervisado</h2>
<p><strong>Por:</strong> <a href="https://github.com/JAPM8" target="_blank">
  <img src="https://img.shields.io/badge/JAPM8-a?style=social&logo=github" alt="JAPM8"/>
</a></p>

En este enfoque se exploraron e implementaron las redes neuronales profundas en 
el contexto del análisis de las señales EEG. Para lo cual, se abordó inicialmente 
una estructura de red neuronal recurrente de tipo *[LSTM](https://colah.github.io/posts/2015-08-Understanding-LSTMs/)* 
y posteriormente se trabajó con una red neuronal convolucional de tipo *[TCN](https://dida.do/blog/temporal-convolutional-networks-for-sequence-modeling)*, 
para las cuales se trabajaron distintas combinaciones de capas evaluando su rendimiento en la categorización de segmentos de interés en EEGs.

<p align="center">
  <img src="https://miro.medium.com/max/3840/1*v0ng9VkbuTu6ey9v8S3VDw.gif" alt="Ejemplo Red Neuronal Profunda" width="60%"/>
</p>

<p align="center"><i>Fuente: <a href="https://medium.com/analytics-vidhya/what-are-convolution-neural-networks-10-points-9d6d24086098" target="_blank">Sarkar, Ayantika </a></i></p>

Uno de los principales desafíos para la implementación de estas estructuras de red era la disponibilidad de datos. 
Por ello, se gestionó el acceso a la base de datos del *[Temple University Hospital (TUH)](https://isip.piconepress.com/projects/nedc/html/tuh_eeg/)*, 
uno de los repositorios de EEGs más grandes disponibles públicamente. Esta fuente de datos fue clave para el desarrollo de esta quinta fase y establece 
una base sólida para continuar reforzando los modelos de clasificación de eventos epilépticos, además de abrir la puerta a nuevas exploraciones de algoritmos de aprendizaje de máquina.

### No olvides revisar :nerd_face: :
- [Extracción Señales Base de Datos TUH](App%20Designer/Prototipo_Data_TUH.m): Este contiene distintos métodos para una lectura eficiente de estudios del corpus SEIZ de base de datos de TUH.
- [Estadísticas Base de Datos TUH](App%20Designer/Stats_DataTUHSEIZ.m): Este permite la extracción de estadísticas para el corpus SEIZ de la base de datos de TUH.
- [Redes RNN](App%20Designer/Desarrollo_Redes_RNN.m): Este contiene las variantes de RNN trabajadas y su implementación en `MATLAB`.
- [Redes CNN](App%20Designer/Desarrollo_Redes_RRN.m): Este contiene las variantes de CNN trabajadas y su implementación en `MATLAB`.
- [Función de lectura openedf](App%20Designer/openedf.m): Esta permite la lectura de archivos `.edf` dándoles formato para ser analizados con la herramienta *Epileptic EEG Analysis Toolbox*.
- [Epileptic EEG Analysis Toolbox](App%20Designer): Este carpeta contiene los archivos necesarios para la herramienta diseñada
a lo largo de las últimas cinco fases.
- [¿Qué necesito para hacer funcionar la herramienta?](App%20Designer#readme): Aquí se detallan todas las dependencias, productos y *Add-Ons* necesarios.

:mailbox_with_mail:**Dudas, comentarios o sugerencias:** [per20183@uvg.edu.gt](mailto:per20183@uvg.edu.gt)

<h2>Enfoque aprendizaje no supervisado</h2>
<p><strong>Por:</strong> <a href="https://github.com/DAIMUVG" target="_blank">
  <img src="https://img.shields.io/badge/DAIMUVG-a?style=social&logo=github" alt="DAIMUVG"/>
</a></p>

En este enfoque se implementaron técnicas de aprendizaje no supervisado en el análisis de señales EEG, enfocándose en la identificación y categorización de 
segmentos de interés sin necesidad de etiquetas previas. Esto permite a los especialistas introducir señales EEG desconocidas en la herramienta, la cual 
detecta automáticamente segmentos con patrones distintos o atípicos. Inicialmente, se utilizaron algoritmos como *[K-means](https://www.ibm.com/topics/k-means-clustering)*, 
*[Jerarquíco](https://www.ibm.com/think/topics/hierarchical-clustering)* y *[Fuzzy C-Means](https://la.mathworks.com/help/fuzzy/fuzzy-clustering.html)* para agrupar las características extraídas de las señales. Posteriormente, 
se exploraron técnicas de reducción de dimensionalidad como PCA para optimizar el rendimiento y visualización de los clusters generados.

<p align="center">
  <img src="https://waterprogramming.wordpress.com/wp-content/uploads/2022/03/graphic.png?w=1024" alt="Ejemplo de agrupación" width="60%"/>
</p>

<p align="center"><i>Fuente: <a href="https://waterprogramming.wordpress.com/2022/03/16/clustering-basics-and-a-demonstration-in-clustering-infrastructure-pathways/" target="_blank">Amestoy, Trevor </a></i></p>

Al igual que en el enfoque supervisado, el acceso a una base de datos amplia y diversa fue fundamental para validar los resultados de los algoritmos de clustering. En esta fase, se utilizó la base de datos
*[TUH EEG Epilepsy Corpus](https://isip.piconepress.com/projects/nedc/html/tuh_eeg/)* que contiene múltiples conjuntos de señales EEG. Algunas de estas señales incluyen etiquetas que resultaron especialmente
útiles para validar la precisión de los algoritmos al agrupar segmentos y distinguir entre diferentes patrones en las señales EEG.

### Pueder consultar:
- [Función de Extracción de Características EEG](App%20Designer/ExtraerCaracteristicas.m): función que extrae estadísticas, cruces por cero, y potencias en bandas de frecuencia de señales EEG. Normaliza y limpia los datos para su uso en análisis de clustering y 
  clasificación.
- [Función para hacer uso de Fuzzy C-Means](App%20Designer/fcm.m): Esta función sirve para hacer uso de el cluster Fuzzy C-means.
- [Epileptic EEG Analysis Toolbox](App%20Designer): Este carpeta contiene los archivos necesarios para la herramienta diseñada

:mailbox_with_mail:**Dudas, comentarios del aprendizaje no supervisado:** [ixc18486@uvg.edu.gt](mailto:ixc18486@uvg.edu.gt)
