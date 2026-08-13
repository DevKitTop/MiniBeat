/// Centralized product policy constants (CFG-004/CFG-005).
///
/// This file is the SINGLE source of truth for these literals: a meta-test
/// (CFG-005) fails if the 30 MB value, `31457280`, or the format strings are
/// duplicated anywhere else in `lib/`.
abstract final class ProductPolicy {
  /// Hard upload-size limit: 30 MB (ADR-006).
  static const int maxUploadSizeBytes = 30 * 1024 * 1024;

  /// Supported audio formats, lowercase and without a leading dot (ADR-006).
  ///
  /// MP3, M4A/AAC, FLAC and WAV. OGG and OPUS are intentionally excluded:
  /// they lack reliable iOS AVPlayer support (BR-022).
  static const Set<String> supportedFormats = {
    'mp3',
    'm4a',
    'aac',
    'flac',
    'wav',
  };

  /// Maximum number of play-history entries kept (BR-011).
  static const int historyLimit = 20;

  /// Duplicate-detection policy (ADR-006): SHA-256 is the authoritative
  /// signal layered over a size+duration exact pre-filter; the hash is stored
  /// in `AudioRecord.sha256Hash`.
  static const String duplicatePolicy =
      'SHA-256 authoritative over size+duration pre-filter';

  /// Whether [extension] (lowercased, leading dot optional) is in the
  /// allowlist.
  static bool isSupportedFormat(String extension) {
    final normalized = extension.toLowerCase().replaceFirst('.', '');
    return supportedFormats.contains(normalized);
  }

  /// Whether a payload of [bytes] fits within the upload limit.
  static bool isWithinUploadLimit(int bytes) => bytes <= maxUploadSizeBytes;
}
