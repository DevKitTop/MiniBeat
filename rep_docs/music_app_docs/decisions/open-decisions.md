# Open Decisions

These items are deliberately unresolved. Agents must NOT silently choose them when the choice affects architecture, security, storage model or product behavior.

## Storage provider

Compare suitable private object-storage/backend options. Supabase is the fallback candidate if no clearly better fit is identified.

## Authentication

Google Sign-In is the planned MVP sign-in method. The exact auth/backend integration remains to be designed.

## Audio engine

Select a Flutter audio stack that can reliably support:

- local files;
- remote streams;
- background playback;
- notifications/system controls;
- Bluetooth/headset interactions;
- Android and iOS.

The selected package must be evaluated for current maintenance, platform support and licensing before adoption.

## File size policy

Initial conversation contained 10/20/30 MB candidates. Choose one explicit MVP limit after backend/storage and audio requirements are evaluated.

## Format policy

MVP should prioritize MP3, M4A and other formats reliably supported by the chosen audio stack. Exact allowlist must be documented before validation code is written.

## Duplicate detection

Filename equality is not sufficient to prove that two audio files are the same. Decide whether the MVP uses filename+size, metadata, hash, or a layered strategy.

## Cloud/Local similarity score

The product may show a percentage indicating how closely Local and Cloud libraries match. The metric is not yet defined and must not be hardcoded until specified.

## Cache versus permanent download

Cloud streaming may use temporary cache to reduce startup latency, but permanent offline availability must remain an explicit user action. Define cache eviction and storage policy after audio stack selection.

## Folder monitoring

Android/iOS have different storage APIs and restrictions. Decide the supported monitoring model per platform rather than assuming unrestricted background filesystem watching.

## Multi-device synchronization

The MVP does not require sophisticated concurrent-edit conflict resolution. A simple deterministic policy is acceptable until collaboration/sync becomes a product feature.

## Playback position

Persist enough state to reopen the player near the previous position without writing storage excessively frequently.
