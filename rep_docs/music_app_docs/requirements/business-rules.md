# Business Rules

## BR-001 - Ownership
Cada archivo Cloud pertenece exactamente a un usuario.

## BR-002 - Privacy
Los archivos Cloud son privados por defecto y no tienen URLs públicas compartibles en el MVP.

## BR-003 - Local independence
La reproducción Local no requiere autenticación ni conexión a Internet.

## BR-004 - Cloud is optional
Crear una cuenta habilita Cloud, pero no sustituye ni desactiva la biblioteca Local.

## BR-005 - Separate libraries
Local y Cloud son espacios separados y no deben fusionarse visualmente en una única biblioteca principal.

## BR-006 - Explicit transfer
Mover contenido entre Local y Cloud requiere una acción explícita de subir o descargar.

## BR-007 - Playlist references
Las playlists almacenan referencias/identificadores y orden; no mueven archivos fuente.

## BR-008 - Playlist scope
Una playlist pertenece al espacio Local o Cloud donde fue creada. La transferencia/sincronización entre espacios es una operación explícita.

## BR-009 - Favorite semantics
Favoritos se comporta como una playlist especial y sigue el espacio donde se registró.

## BR-010 - History scope
Historial Local se persiste Localmente; historial Cloud se asocia a Cloud.

## BR-011 - History size
El historial visible del MVP mantiene como máximo las últimas 20 reproducciones.

## BR-012 - Playback completion
Una cola termina al completar su lista salvo que repeat-one o repeat-list esté activo.

## BR-013 - Background playback
Una reproducción iniciada correctamente puede continuar en segundo plano y con pantalla apagada.

## BR-014 - Audio interruption
Ante una interrupción externa del sistema, la reproducción debe pausarse y poder reanudarse mediante UI o controles del sistema cuando estén disponibles.

## BR-015 - Broken local reference
Si un archivo Local deja de existir o deja de estar accesible, referencias rotas no deben iniciar una reproducción inválida.

## BR-016 - Playlist removal
Eliminar una canción de una playlist no elimina el archivo fuente.

## BR-017 - Cloud delete
Eliminar un archivo Cloud debe invalidar referencias Cloud dependientes y gestionarse de manera consistente en playlists/colecciones.

## BR-018 - Offline
La pérdida de Internet no debe afectar la reproducción Local.

## BR-019 - Cloud reconnect
Una reproducción Cloud interrumpida por red debe poder reintentar automáticamente con límites prudentes.

## BR-020 - Error UX
Errores recuperables y simples se comunican discretamente. Errores complejos requieren interacción se presentan como Dialog/Bottom Sheet u otro patrón apropiado.

## BR-021 - Folder monitoring
Las carpetas monitorizadas por el usuario pueden generar nuevos elementos Local cuando aparezcan archivos compatibles y accesibles.

## BR-022 - Unsupported media
Un archivo que el motor no pueda reproducir de forma fiable no se trata como audio compatible para las operaciones del MVP.

## BR-023 - Search origins
La búsqueda puede consultar Local, Cloud o ambos según filtro seleccionado.

## BR-024 - Search result provenance
Cada resultado debe permitir distinguir si la canción existe Local, Cloud o en ambos espacios.

## BR-025 - Conflict resolution
Una coincidencia o posible duplicado entre Local y Cloud no debe resolverse silenciosamente si existe riesgo de sobrescribir contenido. Debe existir una decisión explícita del usuario cuando sea necesario.

## BR-026 - No public sharing
No debe existir una función de compartir archivos Cloud mediante enlaces públicos en el MVP.

## BR-027 - One owner per account
El MVP no contempla múltiples propietarios o colaboración dentro de una misma cuenta.

## BR-028 - Cloud playlist sync is explicit
Los cambios Local no deben convertirse automáticamente en cambios Cloud salvo que el producto defina explícitamente una sincronización automática posterior.
