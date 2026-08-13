# Non-Functional Requirements

## Performance

- Local library and UI must remain responsive on modest mobile devices.
- Animations must not block audio playback or scrolling.
- Search should feel immediate for normal library sizes.
- Background audio must not be unnecessarily interrupted by UI work.
- Sync and indexing should be asynchronous and cancellable where appropriate.

## Reliability

- Audio playback must not crash because metadata is missing or malformed.
- Network failures must fail gracefully and support retry.
- Partial uploads/downloads must not be mistaken for valid completed files.
- Indexes/references must be resilient to files being renamed, moved or deleted when platform APIs allow detection.

## Privacy & security

- Every Cloud query and storage access must be scoped to the authenticated owner.
- Client UI must never be treated as the only security boundary.
- Backend/storage authorization must enforce ownership.
- Credentials and sensitive configuration must not be hardcoded in the application.
- Public storage buckets/objects are forbidden for private audio.

## Platform

- Android and iOS are first-class targets.
- Phones and tablets are supported by responsive layout.
- Platform-specific media behavior must respect each operating system's lifecycle, permissions and background-audio rules.

## Accessibility

- Controls must expose semantic labels.
- Tap targets must be usable on small screens.
- UI cannot rely on color alone to communicate Local/Cloud/offline state.
- Text remains readable under platform accessibility settings.

## Observability

The production app should be able to diagnose:

- playback errors;
- upload/download failures;
- authentication failures;
- indexing/scanning problems;
- storage/network issues.

Logging must avoid exposing private audio URLs, tokens or sensitive user content.
