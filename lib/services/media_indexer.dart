/// Change observed inside a monitored folder.
class MediaIndexEvent {
  const MediaIndexEvent(this.path);

  final String path;
}

/// Folder-monitoring contract (BR-021).
///
/// DEFERRED (interface only): the platform-specific implementation lands with
/// the local-library feature. Emits an event whenever a watched folder's
/// contents change.
abstract interface class MediaIndexer {
  Stream<MediaIndexEvent> watch(String folderPath);
}
