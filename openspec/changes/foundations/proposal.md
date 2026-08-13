# Proposal: Foundations — rep_mini scaffold

## Intent

rep_mini is 0% implemented: `lib/` holds only the Flutter counter demo and there is no git repo. Feature work (local library, cloud library, playback, transfers) cannot start until the project has a compileable, tested skeleton on the confirmed stack. This change lays that foundation: repository discipline, MVVM/Repository-lite folder structure (NO domain layer), confirmed dependencies, env/config, platform setup, Drift schema, routing shell, Riverpod providers, and test infrastructure — with no feature implementations.

## Scope

### In Scope

- git init + work-unit commit discipline
- Folder structure: `presentation/` (features: `local-library`, `cloud-library`, `settings`), `view-models/`, `repositories/`, `services/`, `audio/`, `data/`; NO domain layer
- Dependencies (confirmed stack): just_audio 0.10.6, audio_service 0.18.19, audio_session 0.2.4, supabase_flutter 2.17.1, flutter_riverpod 3.4.2, go_router 17.5.0, drift 2.34.3 + drift_flutter 0.3.1, google_sign_in 7.2.0, flutter_dotenv 6.0.1
- `.env` + `.env.example` + config loading (no secrets in code)
- Platform configs: Android FGS/permissions, iOS background audio mode, deep links, Google OAuth setup
- Drift schema: 10 records (AudioRecord, FolderRecord, PlaylistRecord, PlaylistItemRecord, FavoriteRecord, HistoryRecord, DownloadRecord, CacheRecord, AppSettingsRecord, PlaybackStateRecord)
- go_router 3-branch shell (Local / Cloud / Settings) + auth redirects
- Riverpod provider setup (manual Notifier API first)
- Centralized product-policy constants: 30 MB limit, format allowlist MP3/M4A/FLAC/WAV, duplicate-detection policy (SHA-256 layered over size+duration)
- Test infrastructure: unit/widget test setup, in-memory Drift test DB, project analysis_options, AGENTS.md at repo root (per docs' recommendation)
- ADR recording the confirmed stack (engine/storage/DB/state/nav changes require ADR per architecture-decisions.md)

### Out of Scope

- Feature implementations (no playback UI, no auth flow UI, no upload/download flows, no sync engine)
- Deferrables: metadata extractor, media indexer, signed-URL streaming mechanism, background download queue (scaffold defines service interfaces only)
- Backend provisioning (Supabase project, Google OAuth credentials are config-time, not code)

## Capabilities

### New Capabilities

- `app-shell`: 3-tab navigation shell (Local/Cloud/Settings) via StatefulShellRoute; Cloud branch auth-gated, Local always accessible (BR-003/BR-004)
- `local-database`: Drift schema for the 10 records, baseline migration, in-memory test DB
- `app-config`: flutter_dotenv config loading + centralized product-policy constants
- `app-platform`: Android FGS/permissions, iOS background audio mode, deep links, Google OAuth wiring (BR-013)

### Modified Capabilities

- None (`openspec/specs/` is empty — no existing capabilities)

## Approach

Scaffold in dependency order: git init → pubspec deps → folder skeleton → platform configs → Drift schema → policy constants → providers → router shell → test infra. Each layer compiles and passes tests before the next; skeleton views are empty-but-wired (placeholder screens, real router/providers/DB). Env and OAuth follow repo-root AGENTS.md security rules; stack ADR recorded per docs' ADR rule.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `pubspec.yaml` | Modified | Confirmed dependency set |
| `lib/` | New | Full skeleton: data/, services/, repositories/, view-models/, audio/, presentation/ |
| `android/`, `ios/` | Modified | FGS, permissions, background audio, deep links, OAuth |
| `.env`, `.env.example` | New | Config only, no secrets |
| `test/` | New | Unit/widget tests, in-memory Drift DB |
| `analysis_options.yaml` | Modified | Project lint baseline |
| `AGENTS.md` | New | Repo-root operating rules (per docs) |
| `openspec/specs/` | New | 4 capability specs |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Plugin/platform version pairing (Android 14-17 / iOS 17-18 audio) | Med | Device validation at apply; pairing recorded in ADR |
| Android 17 background-audio hardening | Med | FGS types + POST_NOTIFICATIONS from day one |
| just_audio custom HTTP headers / Supabase resumable API unknown | Med | Service interfaces isolate; verify at apply |
| Riverpod 3 breaking changes (legacy StateProvider import) | Low | Manual Notifier API; no legacy imports |
| Drift codegen vs minimal-codegen rule | Med | Codegen limited to schema tables only |

## Rollback Plan

All changes are additive and reversible. Restore point: initial git commit after scaffold. Revert sequence: remove added deps from pubspec → delete `lib/` skeleton folders → restore analysis_options baseline → drop platform config additions. No data migration exists yet (baseline schema), so DB rollback is delete-and-recreate.

## Dependencies

- Flutter 3.44.9 / Dart 3.12.2 (verified compatible with all chosen versions)
- Supabase project + Google OAuth credentials (config-time, not code)

## Success Criteria

- [ ] `flutter pub get` resolves the confirmed versions
- [ ] `flutter analyze` passes with project analysis_options
- [ ] `flutter test` passes (unit + widget, in-memory Drift DB)
- [ ] App builds on Android and iOS with empty-but-wired skeleton
- [ ] 3-tab shell navigates; Cloud branch redirects unauthenticated users
- [ ] Policy constants centralized in one file; env loads from `.env.example`
- [ ] ADR recorded for the confirmed stack
- [ ] Initial commit + work-unit commit discipline established
