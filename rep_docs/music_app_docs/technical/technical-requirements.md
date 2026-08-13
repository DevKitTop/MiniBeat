# Technical Requirements — Music App

## Purpose

This document defines implementation constraints and technical requirements derived from the technical questionnaire. It does not replace the product specification. Product behavior remains defined in the existing product documentation.

## Platform scope

- Mobile only: Android and iOS.
- Tablets are included.
- Development priority: Android first, then iOS validation.
- New features should be designed cross-platform even when validation is initially Android-first.

## Audio engine requirements

The audio subsystem must support, in the MVP:

- Local file playback.
- Remote HTTP and HTTPS audio sources.
- Streaming.
- Playlists and playback queues.
- Gapless playback where the source/codec permits it.
- Seeking.
- Buffering.
- Playback rate control is desired but not an MVP blocker unless the selected engine supports it cleanly.
- Speed control is explicitly lower priority than core playback reliability.
- Crossfade is desired.
- Equalizer and audio effects are out of scope for the MVP.
- Unsupported formats must be reported to the user rather than silently ignored.

## Background and system integration

Background playback is mandatory on Android and iOS.

The audio layer must support, where platform capabilities allow:

- Lock-screen controls.
- Notification/control-center controls.
- Bluetooth/headset controls.
- Audio focus/interruption handling.
- Headphone disconnect handling.
- System audio output changes.
- Android Auto / Apple CarPlay compatibility as an architectural requirement for future enablement.
- Future quick controls/widgets should not be blocked by the architecture.

Default interruption behavior:

1. Pause playback.
2. Allow the user to resume from the app or system controls.
3. Do not automatically resume unless a later platform-specific policy explicitly requires it.

## Local library

The user can choose any combination of:

- Full device scan.
- Storage/SD-card scan where available.
- User-selected folders.

The application should support multiple monitored folders.

The app should maintain a local index of selected media and detect changes incrementally. If continuous background monitoring is unavailable or unreliable on a platform, reconciliation should occur when the application becomes active again.

If a previously indexed file cannot be found at its expected location, the record should be reconciled and removed/invalidated rather than kept as a permanently broken file reference.

Physical file paths are part of the local record.

If a file moves, the system should attempt to recognize the moved file; if reliable identity cannot be established, the old reference may be removed and the moved file treated as a new file.

## Audio metadata

Metadata fields should support, with required/optional semantics determined during implementation:

- Title
- Artist
- Album
- Genre
- Year
- Track number
- Duration
- Artwork
- Bitrate
- Codec
- File size

Metadata editing is limited in MVP to non-file-destructive fields such as title, artist, and artwork. The underlying audio file must not be modified merely to edit metadata.

Missing artwork uses an application placeholder.

Artwork and other derived metadata should be cached locally to avoid repeated extraction.

## Cloud file model

A Cloud audio item consists conceptually of:

- The original audio object.
- Metadata.
- Artwork/derived metadata where applicable.
- Logical folder placement.

Cloud storage should preserve the user's folder hierarchy when the user chooses to synchronize that structure.

A cloud file has one physical storage location at a time.

The user may move, rename, and delete cloud files through the app. Cloud deletion requires a confirmation step.

## Streaming and cache

The streaming path should use adaptive behavior suitable for fast startup without causing avoidable playback interruptions.

Cloud playback may use temporary local cache for performance.

Cache policy is automatic and may be reclaimed when storage pressure requires it.

A user-requested permanent download is distinct from temporary streaming cache and must not be deleted merely because automatic cache cleanup runs.

## Downloads

The download system must support:

- Single-song download.
- Album/folder download.
- Playlist download.
- Full-library download.
- Background operation.
- Queueing.
- Pause/resume.
- Automatic retry.
- Per-item progress.
- Aggregate progress.
- Wi-Fi and mobile-data operation.

No hard download-storage quota is required for the MVP.

## Local persistence

A local database is required, including for anonymous/local-only users.

It should hold at least the metadata needed for:

- Indexed songs.
- Paths.
- Folders.
- Playlists.
- Favorites.
- Playback history.
- Downloads.
- Cache records where useful.
- App configuration.

Local database contents are disposable on uninstall. No restoration is required from the local database itself.

Local playback history remains local. Cloud playback history belongs to the cloud account.

## Playback state

The playback session should be restored when the app reopens.

The minimum persistent playback state is not yet finalized; implementation should avoid unnecessary state persistence. Position is expected to be persisted on meaningful state transitions such as pause/close rather than continuously every second.

The current queue and active playback configuration should remain restorable if the selected storage strategy can do so without unnecessary complexity.

Invalid queue entries should normally be surfaced to the user rather than silently disappearing.

## Synchronization

Local and Cloud remain separate libraries.

Synchronization is an explicit user action, not an implicit merge.

The comparison model should be song-centric. It may use:

- Name.
- Metadata.
- File size.
- Duration.
- Hash/content identity.

File content/hash should be considered for robust duplicate/conflict detection, while name remains important for user-visible conflict handling.

The UI should distinguish at minimum:

- Local only.
- Cloud only.

An item existing on both sides can be inferred from the comparison result and does not require a third top-level state.

Different versions of what appear to be the same song must be detectable.

Conflicts require explicit user choice. The conflict flow should support reviewing the competing files before deciding when practical.

A dedicated synchronization screen/modal is required for reviewing proposed changes.

The user must explicitly approve potentially destructive synchronization operations.

The synchronization percentage is intentionally not fixed yet. It should describe song-level correspondence and not pretend that folders, metadata, playlists, or histories are fully synchronized unless the implementation actually checks those dimensions.

## Downloads and offline behavior

Cloud audio downloaded permanently becomes a local playable copy.

A local copy must remain usable for local playback even when the Cloud session is unavailable, subject to the product's security and ownership rules.

## Authentication and session behavior

Google Sign-In is the only authentication method for the MVP.

Other providers may be added later.

Local playback remains usable without network access and without requiring an active cloud session.

Session expiry must not interrupt already-downloaded local content.

## Security requirements

Cloud content must remain private.

The architecture must not expose permanent public URLs for private audio.

Access to cloud database rows and storage objects must be scoped to the authenticated user.

Private storage should be accessed using authenticated requests and/or time-limited signed URLs as appropriate. Supabase currently supports private buckets protected by RLS and time-limited signed URLs. citeturn405078search0turn405078search1

Local audio files are outside the application's cloud security boundary once they exist on the user's device.

## Performance requirements

Performance is a first-class product requirement.

The app should avoid:

- blocking the UI during scans;
- blocking the UI during indexing;
- unnecessary full-library rescans;
- synchronous metadata extraction on the main isolate/thread where avoidable;
- heavy animations that degrade responsiveness or battery life.

A first scan may take time for very large libraries, but it must remain responsive and provide meaningful progress/feedback.

Incremental scanning is preferred.

Animations target smooth 60 FPS behavior where practical, but responsiveness and battery efficiency take precedence over ornamental effects.

Accessibility should be supported from the beginning.

## Navigation and architecture preferences

The project should follow Flutter's recommended layered approach where appropriate, avoiding unnecessary enterprise abstractions.

MVVM/Repository-style separation is preferred.

Dependency injection should be explicit and testable.

Navigation should use a fast, stable declarative solution if it materially improves the app; the exact router remains an open decision until package/version research is completed.

State management is intentionally delegated to the architecture evaluation; the selected solution must favor performance, testability, minimal boilerplate, and maintainability.

Code generation is permitted but should remain minimal and justified.

External dependencies should be kept to the minimum needed for required capabilities.

## Agent workflow constraints

For substantial changes, OpenCode should:

1. Read the relevant project documentation.
2. Identify affected architecture and business rules.
3. Propose an implementation plan.
4. Wait for approval when a change alters an established architectural decision.
5. Implement.
6. Run static analysis and relevant tests.
7. Report validation results.

Architecture changes require explicit user approval.

Significant architectural decisions should be recorded as ADRs.

## Explicit non-goals for MVP

- Equalizer.
- Advanced audio effects.
- Social sharing.
- Public links.
- Public/shared libraries.
- Premium storage tiers.
- Email/password authentication.
- Full metadata editing.
