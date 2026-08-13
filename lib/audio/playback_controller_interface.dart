/// Playback control contract used by the audio layer.
///
/// DEFERRED (interface only): the just_audio/audio_service implementation
/// (ADR-001) lands with the audio feature. Audio playback must keep working
/// independently from UI animations.
abstract interface class PlaybackControllerInterface {
  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> stop();
}
