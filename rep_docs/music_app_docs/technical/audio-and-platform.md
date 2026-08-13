# Audio and Platform Decision Notes

## Current candidate

The current leading audio architecture is:

- `just_audio` as the playback engine.
- `audio_service` as the background/system media integration layer.

This is currently a strong fit because `audio_service` provides background playback, lock-screen/media controls, headset handling, queue manipulation, repeat/shuffle, rate controls, album art, and platform integrations, and is explicitly designed to be paired with an audio engine such as `just_audio`. citeturn405078search3turn405078search9

`just_audio_background` is intentionally not the default choice for this project because its documentation positions it as the simpler option for a single `AudioPlayer`, while recommending `audio_service` directly for more advanced requirements. Our app has richer requirements around queues, synchronization, cloud/local sources, background behavior and future platform controls. citeturn405078search4

## Required verification before locking

Before adding production dependencies, verify current stable versions and compatibility for:

- Flutter SDK version chosen for the project.
- Android compile/target requirements.
- iOS deployment target.
- `just_audio`.
- `audio_service`.
- audio session/interruption handling package(s).
- local media-library/file access package.

## Platform responsibilities

Flutter should own product logic and UI.

Native platform code should be introduced only when required for:

- background media behavior;
- system media controls;
- platform storage/media APIs;
- platform-specific permissions;
- platform-specific audio session/focus behavior;
- integrations that cannot be reliably implemented through Flutter packages.

## Gapless / crossfade note

Gapless and crossfade are playback-policy features, not guarantees that every codec/device combination will behave identically. The implementation must verify the selected engine's behavior with the actual MVP formats and representative Android/iOS devices.

## Local media access

A candidate package discovered during research is `media_browser`, which currently describes support for querying local media and folders across Android/iOS and other platforms. It should be evaluated rather than adopted blindly. citeturn405078search10

The final local-media solution must be evaluated against:

- Android scoped storage behavior.
- SD-card availability differences.
- User-selected folders.
- iOS sandbox/file-import capabilities.
- incremental change detection.
- metadata extraction.
- performance with large libraries.

## Open question

The exact local media package is intentionally not locked in this document yet.
