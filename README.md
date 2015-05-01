#Práctica Cloud Computing#

**App (Branch master)**
--

La app dispone de zona de autor y de lector.

*En el proyecto se incluye el código fuente de la parte cliente y servidor.*

---

**Zona autor**

* Se realiza login con FB y se obtienen las noticias del autor.
* Se muestra el estado de publicación en el que están.
* El usuario puede solicitar que la noticia pase a pendiente (llamada a una API).
* Publicación de noticia: se comprueba en servidor que tenga título (mediante el script de insert), si no lo tiene, devuelve un 500 y no se inserta. Se reduce la medida de la imagen antes de enviarla.

---


**Zona lector**

* Sin realizar login se obtiene el listado de noticias publicadas.
* Se permite al usuario realizar votación de las imágenes (llamada a una API).

---


**Scheduler**

* Cada 6 horas se pasan las noticias que están pendientes de revisión a Publicadas con un Schedule.

---
Pido perdón por el diseño de mi App :D

