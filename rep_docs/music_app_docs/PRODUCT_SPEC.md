# Personal Audio Cloud - Product Specification

**Estado:** MVP - especificación funcional inicial  
**Plataformas:** Android + iOS (teléfonos y tablets)  
**Privacidad:** contenido privado por usuario  
**Documento:** contrato funcional antes de implementar código

## 1. Visión del producto

La aplicación es un reproductor de audio móvil que permite al usuario reproducir su propia música y audios locales sin necesidad de una cuenta. Opcionalmente, el usuario puede crear una cuenta y guardar su biblioteca privada de audio en la nube para poder recuperarla en otros dispositivos.

La aplicación NO proporciona un catálogo musical propio y NO pretende competir con Spotify. La fuente de contenido es exclusivamente el contenido del usuario.

### Problema que resuelve

Cuando una persona cambia de teléfono puede perder el acceso inmediato a su biblioteca de música/audio, especialmente si el nuevo dispositivo no admite tarjeta SD. Transferir manualmente los archivos entre dispositivos es una tarea innecesaria y repetitiva.

La aplicación debe resolver esto mediante:

- reproducción local sin cuenta ni Internet;
- biblioteca cloud privada opcional;
- subida de archivos locales a cloud;
- streaming de archivos propios desde cloud;
- descarga de archivos propios desde cloud;
- organización de archivos y playlists en Local y Cloud sin mezclar ambos espacios.

## 2. Principios del producto

1. **El usuario es dueño del contenido.** La aplicación no aporta música propia.
2. **Privacidad por defecto.** Las canciones del usuario son privadas y no se comparten.
3. **Local funciona sin cuenta.** Registrar una cuenta no debe ser obligatorio para usar el reproductor local.
4. **Local y Cloud son espacios separados.** No se debe construir una biblioteca híbrida que oculte el origen del archivo.
5. **La nube es opcional.** El usuario decide qué subir, qué descargar y qué mantener solo localmente.
6. **Minimalismo.** La UI debe ser simple, rápida y visualmente cuidada.
7. **Material Design 3.** La interfaz seguirá el lenguaje visual de Material Design 3, con una capa futurista/animada sin sacrificar rendimiento.
8. **Privacidad y seguridad son requisitos de primera clase.** No debe existir un enlace público de una canción o biblioteca privada.

## 3. Estado de autenticación

### Sin cuenta

El usuario puede:

- escanear música local;
- reproducir música local;
- crear y administrar playlists locales;
- usar favoritos locales;
- consultar historial local;
- usar el reproductor y sus controles sin conexión.

### Con cuenta

Además de las funciones locales, el usuario puede:

- almacenar sus audios en Cloud;
- organizar el contenido Cloud en carpetas;
- crear playlists Cloud;
- hacer streaming de su contenido Cloud;
- descargar contenido Cloud al dispositivo;
- subir nuevas canciones y carpetas desde Local;
- mantener la biblioteca Cloud protegida y privada.

El método de autenticación previsto para el MVP es Google Sign-In.

## 4. Estructura principal de navegación

Navegación inferior prevista:

- Música
- Playlist
- Configuración

Dentro de Música existirán dos espacios claramente separados:

- Local
- Cloud

Cloud mostrará la opción de iniciar sesión cuando no exista una sesión activa.

## 5. Primera experiencia del usuario

Al instalar y abrir la aplicación:

1. Se muestra la interfaz principal.
2. Se informa al usuario de que puede utilizar el reproductor local sin cuenta.
3. Se ofrece la posibilidad de registrarse y se explican brevemente los beneficios del almacenamiento Cloud.
4. Para Local, se solicita permiso y se permite elegir entre:
   - escanear el dispositivo;
   - escanear una SD disponible;
   - seleccionar una carpeta concreta.
5. Se construye la biblioteca local.
6. El usuario puede comenzar a reproducir música inmediatamente.

Al registrarse posteriormente:

1. Se autentica con Google.
2. Se mantiene disponible la biblioteca Local.
3. Se informa de que ahora existe el espacio Cloud.
4. Si Cloud está vacío, se ofrece subir contenido Local.
5. El usuario decide qué subir.

## 6. Biblioteca Local

La biblioteca Local representa archivos que existen físicamente en el dispositivo y a los que la aplicación tiene acceso.

### Fuentes permitidas

- almacenamiento interno;
- tarjeta SD cuando la plataforma/dispositivo la exponga;
- carpetas seleccionadas por el usuario.

### Escaneo

El usuario controla qué ubicaciones se escanean. La aplicación debe poder detectar nuevas canciones dentro de las ubicaciones previamente autorizadas.

### MVP de formatos y tamaño

El MVP priorizará MP3, M4A y formatos de audio comunes soportados de forma fiable por el motor seleccionado.

Existe un límite inicial de tamaño por archivo para las operaciones Cloud. El valor exacto todavía queda pendiente de decisión y debe configurarse como una política del producto, no dispersarse por el código.

### Archivo no reproducible

Un archivo que no pueda ser reproducido de forma válida no debe ser enviado a Cloud como si fuera compatible y no debe presentarse como reproducible.

## 7. Biblioteca Cloud

Cloud contiene únicamente archivos pertenecientes al usuario autenticado.

### Organización

El usuario podrá:

- crear carpetas;
- subir archivos a carpetas;
- organizar el contenido;
- crear playlists Cloud;
- descargar archivos individualmente;
- descargar contenido de forma masiva.

Cuando sea posible, la estructura de carpetas Local podrá conservarse al subir contenido a Cloud.

### Streaming

Una canción Cloud puede reproducirse sin descarga permanente previa cuando exista conectividad.

El sistema debe priorizar un inicio de reproducción rápido. Puede utilizar almacenamiento temporal/cache local para reducir retrasos y mejorar tolerancia ante pérdidas momentáneas de red, sin convertir automáticamente toda reproducción en una descarga permanente.

## 8. Separación Local / Cloud

Local y Cloud no se muestran como una biblioteca única.

Las operaciones entre ambos espacios son explícitas:

- Local -> Cloud: subir
- Cloud -> Local: descargar

El buscador global puede consultar ambos espacios, pero cada resultado debe indicar de qué origen procede.

Cuando la misma canción exista en ambos espacios, el resultado podrá indicar que existe en Local y Cloud.

## 9. Reproductor

El reproductor será intencionalmente sencillo, usando las capacidades disponibles del motor de audio elegido.

Controles previstos:

- reproducir/pausar;
- anterior;
- siguiente;
- barra de progreso/seek;
- repetir canción;
- repetir lista;
- shuffle cuando esté disponible;
- volumen cuando sea apropiado;
- gestión de cola.

### Cola

La cola de reproducción existe como entidad operativa independiente de una carpeta física.

Cuando termina una lista:

- sin repetición: se detiene;
- repetir canción: repite la canción actual;
- repetir lista: vuelve a recorrer la lista.

## 10. Reproducción en segundo plano

La reproducción debe continuar con la aplicación en segundo plano y con la pantalla apagada.

Debe existir integración con los controles de reproducción del sistema, incluyendo notificación/pantalla de bloqueo cuando la plataforma lo permita.

Compatibilidad esperada:

- audífonos;
- Bluetooth;
- controles del sistema;
- interrupciones de audio.

Ante una llamada u otra interrupción de audio del sistema, la reproducción se pausa. El usuario puede reanudarla desde la aplicación o desde el control disponible del sistema.

## 11. Restauración de reproducción

Al reabrir la aplicación se debe restaurar, como mínimo:

- canción actual;
- estado necesario de la cola;
- posición aproximada de reproducción.

No se debe guardar innecesariamente un historial de posición segundo por segundo. El intervalo/estrategia exacta de persistencia queda pendiente de diseño técnico.

## 12. UI del reproductor

La pantalla completa del reproductor tendrá una presentación visual dominante para la carátula/imagen, aproximadamente 60% del área disponible según el diseño final.

Características deseadas:

- Material Design 3;
- apariencia futurista;
- animaciones suaves;
- controles claros;
- rendimiento prioritario;
- gestos para anterior/siguiente desde el área visual del reproductor.

El cierre del player se delegará principalmente al comportamiento estándar de navegación/plataforma; los gestos propios se enfocarán en acciones de canción.

## 13. Mini Player

Cuando exista una canción activa, la aplicación mostrará un mini reproductor persistente en la navegación principal.

Debe ser pequeño y mostrar como mínimo:

- título/canción;
- artista cuando exista;
- control Play/Pause;
- acceso al reproductor completo.

## 14. Playlists

Una playlist NO es una carpeta física.

Una carpeta representa ubicación física/lógica de almacenamiento. Una playlist representa una colección lógica y ordenada de canciones.

Una playlist debe guardar referencias a canciones y su orden, no mover los archivos originales.

Las playlists existen de forma independiente en:

- Local;
- Cloud.

Una playlist Local puede ser subida/sincronizada a Cloud cuando el usuario lo decida. La sincronización no es obligatoria ni automática por defecto.

## 15. Favoritos

Los favoritos serán conceptualmente una playlist especial.

El usuario puede marcar canciones como favoritas.

Los favoritos deben existir en Local y Cloud según el espacio en el que se gestionen.

## 16. Historial

El historial muestra las últimas 20 reproducciones.

Regla de persistencia:

- reproducciones Local -> historial local;
- reproducciones Cloud -> historial Cloud.

Si existiese reproducción simultánea desde más de un dispositivo, el MVP no implementará resolución avanzada de conflictos. Se utilizará una política simple y determinista que priorice el primer evento válido recibido para el registro correspondiente.

## 17. Búsqueda

La búsqueda será una interfaz única con posibilidad de filtrar por origen.

Filtros principales:

- Local;
- Cloud;
- ambos.

Los resultados deben indicar visualmente si una canción existe en:

- Local;
- Cloud;
- ambos.

La búsqueda será incremental/en tiempo real.

Los filtros avanzados se abrirán desde un control de filtro asociado al buscador.

Campos de búsqueda previstos:

- título;
- artista;
- álbum;
- otros metadatos disponibles.

## 18. Descargas

El usuario debe poder:

- descargar una canción individual;
- descargar un conjunto de canciones;
- descargar contenido de forma masiva cuando el flujo lo permita.

Una descarga fallida debe poder reintentarse manualmente.

Los problemas simples deben comunicarse discretamente. Los errores complejos o que requieran decisiones del usuario pueden mostrarse mediante Modal/Bottom Sheet/Dialog.

## 19. Sin conexión

La app debe funcionar como reproductor Local sin Internet.

Si una canción Cloud que se está reproduciendo pierde conectividad:

1. pausar la reproducción cuando ya no exista suficiente contenido/buffer;
2. mostrar un estado visual discreto de "Sin red";
3. reintentar automáticamente al recuperar conexión;
4. reanudar la reproducción cuando sea seguro hacerlo.

Los reintentos no deben producir loops agresivos ni consumir innecesariamente batería/datos.

## 20. Sincronización Local -> Cloud

El usuario puede subir canciones desde Local a Cloud.

Cuando existan conflictos aparentes entre contenido Local y Cloud, se debe presentar una interfaz de resolución.

El conflicto puede incluir:

- mismo nombre;
- posible archivo duplicado;
- diferencia de origen;
- posibilidad de reproducir/inspeccionar antes de decidir.

Las acciones candidatas incluyen:

- subir de todas formas;
- no subir;
- cambiar nombre;
- eliminar/descartar el elemento conflictivo según el contexto.

La resolución exacta de duplicados y el método técnico de comparación quedan pendientes de diseño.

## 21. Comparación Local / Cloud

La aplicación puede mostrar qué contenido está disponible en cada espacio y qué tan alineadas están las bibliotecas.

Existe la intención de mostrar un porcentaje o indicador de similitud/estado, pero la fórmula exacta todavía no debe considerarse definida.

## 22. Eliminación

Si un archivo deja de existir en Local, la aplicación debe invalidar referencias que dependan exclusivamente de ese archivo y evitar intentos de reproducción de una referencia rota.

La eliminación de una referencia de una playlist no debe eliminar automáticamente el archivo fuente.

## 23. Configuración

Configuración inicial esperada:

- gestionar carpetas monitorizadas;
- permitir importar/escuchar nuevas canciones de esas carpetas;
- preferencias de reproducción;
- cuenta;
- almacenamiento/caché cuando corresponda;
- opciones relacionadas con Cloud.

La monitorización de carpetas debe respetar permisos del sistema operativo y las limitaciones de cada plataforma.

## 24. Privacidad y seguridad

Requisitos obligatorios:

- contenido privado por usuario;
- sin enlaces públicos compartibles en el MVP;
- ningún usuario puede leer archivos de otro usuario;
- autenticación segura;
- acceso a objetos Cloud restringido por propietario;
- secretos y credenciales fuera del código cliente;
- políticas de autorización verificadas en backend/storage.

## 25. Backend

La primera opción será investigar una plataforma de almacenamiento adecuada para audio privado, teniendo en cuenta:

- coste;
- espacio;
- ancho de banda/egress;
- autenticación;
- reglas de acceso;
- facilidad para Flutter;
- almacenamiento de metadatos;
- protección de archivos privados.

Si no aparece una opción claramente superior para este caso de uso, se utilizará Supabase.

## 26. Alcance del MVP

El MVP debe centrarse exclusivamente en:

1. reproducción Local;
2. biblioteca Local;
3. autenticación opcional;
4. biblioteca Cloud privada;
5. subida Local -> Cloud;
6. streaming Cloud;
7. descarga Cloud -> Local;
8. playlists Local y Cloud;
9. favoritos;
10. historial de 20 elementos;
11. búsqueda Local/Cloud;
12. reproducción en segundo plano;
13. controles del sistema;
14. funcionamiento offline de Local;
15. interfaz minimalista Material 3.

## 27. Fuera del MVP

No deben implementarse ahora:

- red social;
- compartir música;
- links públicos;
- chats;
- recomendaciones sociales;
- funcionalidades Premium;
- almacenamiento adicional de pago;
- colaboración entre usuarios;
- playlists públicas.

Estas ideas pueden existir únicamente como roadmap futuro.

## 28. Decisiones todavía pendientes

Estas decisiones se mantienen deliberadamente abiertas:

- proveedor de almacenamiento Cloud definitivo;
- límite exacto por archivo (10/20/30 MB u otro valor);
- formatos exactos soportados en MVP;
- motor de audio Flutter definitivo;
- mecanismo de cache/descarga temporal de streaming;
- método exacto para comparar duplicados;
- fórmula del porcentaje de similitud Local/Cloud;
- estrategia concreta de sincronización de playlists;
- persistencia exacta de posición de reproducción;
- modelo técnico de monitorización de carpetas según Android/iOS.

No se deben inventar estas decisiones durante la implementación. Deben resolverse en documentos de decisión antes de afectar arquitectura/código.
