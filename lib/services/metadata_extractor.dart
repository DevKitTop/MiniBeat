/// Technical metadata extracted from an audio file.
class AudioMetadata {
  const AudioMetadata({
    required this.title,
    required this.durationMs,
    required this.sizeBytes,
    required this.format,
  });

  final String title;
  final int durationMs;
  final int sizeBytes;
  final String format;
}

/// Extracts technical metadata from an audio file on disk.
///
/// DEFERRED (interface only): the `audio_metadata_reader` implementation
/// lands with the local-library feature. Contract: returns null when the file
/// cannot be read or carries no usable metadata.
abstract interface class MetadataExtractor {
  Future<AudioMetadata?> extract(String filePath);
}
