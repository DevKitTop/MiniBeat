# Backlog — rep_mini

Pending work collected from the `foundations` change (archived 2026-08-14). Items are picked up by future SDD changes. Product truth remains in `rep_docs/music_app_docs/`; this file tracks implementation debt and follow-ups only.

## Deferred implementations (interfaces exist, no concrete library chosen)

| Item | Status | Where it will be used | Notes |
|---|---|---|---|
| MetadataExtractor implementation | interface-only | `local-library` (audio scan, artwork) | Candidate: `audio_metadata_reader` (verified 1.7.1 at exploration). Cache artwork locally. |
| MediaIndexer implementation | interface-only | `local-library` (folder scan + monitoring) | Android scoped-storage APIs + iOS file-import; reconcile on app-activate instead of live watching (open decision). |
| TransferService upload implementation | interface-only | `cloud-library` (upload) | Supabase resumable upload (Dart API to verify). Enforce 30 MB ProductPolicy limit. |
| TransferService download implementation | interface-only | `cloud-library` (download) | Download-to-cache vs permanent download must be separate namespaces; never evict user downloads. |
| Signed-URL streaming | not started | `cloud-library` (playback) | Short-lived signed URLs (5-10 min) issued per playback request. |
| Background download queue | not started | `cloud-library` | MVP may accept simple sequential transfers; investigate Supabase native support. |

## Config-time values (placeholders shipped — real values are NOT code)

| Item | Placeholder location | Action |
|---|---|---|
| Real Supabase project URL + anon key | `.env` / `.env.example` | Create Supabase project, fill `.env` (never commit). |
| Real Google OAuth client IDs | `android/app/build.gradle`(kts?) + `ios/Runner/Info.plist` + `.env` | Create OAuth client (SHA-1 + reversed client ID), replace `YOUR_*` placeholders. |
| Deep-link domain | Android intent filter + iOS associated domains | Replace `repmini.example.com` placeholders. |

## Verify-phase follow-ups (suggestions, low priority)

| Item | Type | Detail |
|---|---|---|
| `.gitattributes` | suggestion | LF→CRLF warnings on Windows; add line-ending normalization. |
| ASH-006 folder-skeleton guard test | warning | No automated test asserts "no domain/ folder" — add regression test. |
| Manifest/plist parsing test | suggestion | Make PLT-001..004 regression-proof. |
| `main()` env-load e2e | warning | `AppConfig.fromEnv` unit-tested; `main()` not executed under test (standard for Flutter entry). |

## Future change candidates (SDD changes, in dependency order)

1. **`local-library`** — local audio scan + playback. Core product value (offline, account-less). Needs MetadataExtractor + MediaIndexer implementations. Builds on Drift schema + ProductPolicy + playback controller interface.
2. **`cloud-auth`** — Google Sign-In + Supabase session (auth-gate placeholder in shell becomes real).
3. **`cloud-library`** — upload/download, streaming, signed URLs.
4. **`playlists` / `favorites` / `history` / `search`** — per MVP scope (playlists live inside each content space, per IA decision).

## Cross-cutting reminders

- Strict TDD active: `flutter test` (RED→GREEN→REFACTOR). `flutter analyze` must stay clean.
- Work-unit commits, conventional messages, no AI attribution, no PRs unless a remote/team requires review.
- ADR required before changing: audio engine, storage provider, local DB, state management, navigation, security model (see `rep_docs/music_app_docs/technical/architecture-decisions.md`).