# Design: Foundations — rep_mini scaffold

## Technical Approach

Lay the compileable, tested skeleton on the confirmed stack (proposal, spec ASH/LDB/CFG/PLT, stack #437). Two sequential apply batches with clean commit boundaries: **Batch A** = infra/config only (git, deps, platform configs, repo rules — no Dart under `lib/`); **Batch B** = app skeleton (Dart code + tests). Each batch leaves `flutter pub get`, `flutter analyze`, `flutter test` green. MVVM/Repository-lite, NO domain layer. No feature logic: placeholder screens, real router/providers/DB, service interfaces only for deferrables.

## Delivery Structure

| Batch | Content | Exit gate |
|-------|---------|-----------|
| **A — infra/config** (no Dart under `lib/`) | git init + initial commit; folder skeleton (empty dirs + `.gitkeep`); pubspec deps; `.env` + `.env.example` (+ `.gitignore`); `analysis_options.yaml`; root `AGENTS.md`; Android configs (FGS, POST_NOTIFICATIONS, deep link, OAuth placeholders); iOS configs (background audio, URL schemes, associated domains) | pub get resolves pinned versions; analyze clean; commit per work unit |
| **B — app skeleton** | Theme + font; go_router 3-branch shell + auth gate; Riverpod providers; Drift 10-table schema + baseline migration + in-memory test DB; `AppConfig` + env wiring; `ProductPolicy` constants; deferrable service interfaces; smoke tests | analyze clean; `flutter test` passes; commit per work unit |

## Requirement → Design Element → Batch

| Req | Design element(s) | Batch |
|-----|-------------------|-------|
| ASH-001 | `lib/main.dart` (flutter_dotenv load → `AppConfig` → `ProviderScope` → `MaterialApp.router`); `core/router/app_router.dart` | B |
| ASH-002 | `core/theme/app_theme.dart` — `ThemeData(useMaterial3: true)` + Google font; Roboto default; Google Sans licensing caveat in source comment | B |
| ASH-003 | `core/router/app_router.dart` — `StatefulShellRoute.indexedStack`, 3 branches; `presentation/app_shell.dart` (NavigationBar + 3 `StatefulShellBranch`) | B |
| ASH-004 | router `redirect()` + `core/providers/auth_session_provider.dart`; `presentation/features/cloud-library/sign_in_screen.dart` placeholder | B |
| ASH-005 | `auth_session_provider.dart` — manual `Notifier`, default unauthenticated; no riverpod codegen/legacy imports | B |
| ASH-006 | Folder tree: Batch A creates empty dirs + `.gitkeep`; Batch B fills them; test asserts no `domain/` | A + B |
| LDB-001 | `data/database/tables/*.dart` — 10 `Table` classes with `@DataClassName` matching spec record names | B |
| LDB-002 | `data/database/app_database.dart` — `schemaVersion: 1`, `MigrationStrategy(onCreate: createAll, beforeOpen: PRAGMA foreign_keys=ON)` | B |
| LDB-003 | `AppDatabase.forTesting()` → `NativeDatabase.memory()` (no platform channels); `test/app_database_test.dart` | B |
| LDB-004 | `build_runner` + `drift_dev`; `.g.dart` schema-only; `analysis_options.yaml` excludes `**/*.g.dart` | B |
| LDB-005 | `downloads` vs `cache` distinct tables; cleanup targets `CacheRecord` only (test) | B |
| LDB-006 | `audio_records`: `sizeBytes`, `durationMs`, `sha256Hash` + index on hash | B |
| CFG-001 | `.env.example` + `.gitignore` (A); flutter_dotenv load in `main()` (B) | A + B |
| CFG-002 | Root `AGENTS.md` no-secrets rules (A); placeholder-only env (A); secret-scan smoke test (B) | A + B |
| CFG-003 | `core/config/app_config.dart` — `AppConfig{supabaseUrl, anonKey}`; throws `ConfigException` with descriptive message on missing key; no silent defaults | B |
| CFG-004 | `core/policy/product_policy.dart` — 30 MB limit, MP3/M4A(ACC)/FLAC/WAV allowlist, SHA-256-over-(size+duration) dup policy | B |
| CFG-005 | Policy constants are the only source of those literals; meta-test scans `lib/` for duplicates | B |
| PLT-001 | `android/app/src/main/AndroidManifest.xml` — `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, AudioService `<service android:foregroundServiceType="mediaPlayback">` | A |
| PLT-002 | `ios/Runner/Info.plist` — `UIBackgroundModes` includes `audio` | A |
| PLT-003 | Android app-link intent filter placeholder (VIEW/https, placeholder host); iOS `CFBundleURLTypes` scheme + associated-domains placeholder (entitlements note) | A |
| PLT-004 | Android `strings.xml`/`build.gradle.kts` placeholders (client ID, SHA-1 comment); iOS reversed client-ID URL scheme placeholder; no real credentials | A |
| PLT-005 | Root `AGENTS.md` — no secrets in code/logs, Local/Cloud separation, ADR rule | A |
| PLT-006 | `analysis_options.yaml` (flutter_lints baseline + curated rules); verify clean at end of each batch | A + B |

## Folder Structure (`lib/`)

```
lib/
├── main.dart                        # ASH-001 entry
├── app.dart                         # MaterialApp.router wiring
├── core/                            # shared cross-cutting
│   ├── config/app_config.dart       # CFG-003 model + loader (throws ConfigException)
│   ├── policy/product_policy.dart   # CFG-004/005 constants
│   ├── providers/auth_session_provider.dart   # ASH-005 manual Notifier
│   ├── providers/app_providers.dart # config/database/router provider graph
│   ├── router/app_router.dart       # ASH-003/004 routes + redirect
│   └── theme/app_theme.dart         # ASH-002 M3 + font + caveat
├── presentation/
│   ├── app_shell.dart               # bottom-nav shell (3 StatefulShellBranch)
│   └── features/
│       ├── local-library/local_library_screen.dart     # placeholder
│       ├── cloud-library/cloud_library_screen.dart     # placeholder
│       ├── cloud-library/sign_in_screen.dart           # auth-gate placeholder
│       └── settings/settings_screen.dart               # placeholder
├── view-models/                     # empty for scaffold (.gitkeep)
├── repositories/                    # empty for scaffold (.gitkeep)
├── services/
│   ├── metadata_extractor.dart      # interface only (deferrable)
│   ├── media_indexer.dart           # interface only (deferrable)
│   └── transfer_service.dart        # interface only (deferrable)
├── audio/
│   └── playback_controller_interface.dart  # interface only (deferrable)
└── data/database/
    ├── app_database.dart            # LDB-002 DB + migration + forTesting()
    ├── tables/{audio,folder,playlist,playlist_item,favorite,history,download,cache,app_settings,playback_state}_record.dart
    └── app_database.g.dart          # generated, schema-only (LDB-004)
```

NO `domain/` folder (ASH-006, config rules). `view-models/` and `repositories/` remain `.gitkeep`-only until first feature.

## Architecture Decisions (ADR)

Recorded per `architecture-decisions.md` ADR rule (engine/storage/DB/state/nav changes require ADR).

| ADR | Choice | Alternatives | Rationale |
|-----|--------|--------------|-----------|
| ADR-001 Audio engine | just_audio 0.10.6 + audio_service 0.18.19 + audio_session 0.2.4 | just_audio_background (beta, single-player), media_kit (native/libmpv, licensing), native Media3 channels | Docs' leading candidate; ExoPlayer+AVPlayer codecs; queue/background/media-control/headset; Dart ^3.6 OK. Risk: Android 17 hardening → FGS types + POST_NOTIFICATIONS day one |
| ADR-002 Storage provider | Supabase (supabase_flutter 2.17.1) | Firebase Storage, Backblaze B2 / Cloudflare R2 / S3 | Only option covering auth (Google OAuth) + Postgres metadata + private buckets + RLS + signed URLs + TUS resumable in one managed product; others force custom backend (violates keep-it-small) |
| ADR-003 State management | flutter_riverpod **^2.6.1** (pinned; NOT 3.4.2), manual Notifier/Provider API | Bloc (boilerplate), Provider (weak async), @riverpod codegen (violates minimal-codegen) | Speed, testability (ProviderScope overrides), DI without context, stream support. DEVIATION (user-approved): riverpod 3.x depends on `test ^1.0.0`, which conflicts with flutter_test's test_api 0.7.11/matcher 0.12.19 pins in Flutter 3.44.9, and supabase_flutter 2.17.1 → realtime_client → web_socket_channel ^3.0.3 blocks the remaining ranges — 3.x is unsatisfiable (verified via pub solver). 2.6.1 is the latest 2.x; the manual Notifier/NotifierProvider/ConsumerWidget API is identical, so ASH-005 is unchanged |
| ADR-004 Navigation | go_router 17.5.0 `StatefulShellRoute.indexedStack` | auto_route (codegen-heavy), imperative Navigator | Declarative, per-branch state, auth redirect guards, deep links, no codegen |
| ADR-005 Local database | Drift 2.34.3 + drift_flutter 0.3.1 + drift_dev 2.34.5 | Isar (archived, no Dart 3), isar_community (fork risk), sqflite (raw SQL) | Type-safe SQL, versioned migrations, reactive watch(), in-memory tests, relational model maps 1:1 to the 10 records |
| ADR-006 Policy/identity model | 30 MB limit; allowlist MP3/M4A(ACC)/FLAC/WAV; dup = SHA-256 authoritative over size+duration pre-filter; history max 20 | Larger limits, OGG/OPUS inclusion, filename-only matching | User-confirmed decisions; OGG/OPUS lack reliable iOS AVPlayer support (BR-022); layered hash detection per local-persistence-and-sync |

## Data Flow

```
main() ──loads──> AppConfig ──> ProviderScope ──> MaterialApp.router ──> GoRouter
   │                                            (authSessionProvider │ redirect)
   └── flutter_dotenv(.env) ─────────────────────┘         │
                                                      /local /cloud /settings
                                                       (StatefulShellRoute)
Drift: AppDatabase ──watch──> repositories (future) ──> view-models (future) ──> screens
        │                                                                        ^
        └── NativeDatabase.memory() in tests (LDB-003) ──────────────────────────┘
```

Scaffold has no repositories/view-models yet; data flow is main → providers → router → placeholder screens; DB exists and is tested directly.

## Drift Schema (10 tables, schemaVersion = 1)

All tables declared with `@DataClassName('<Name>')` matching spec record names. PK = `id` INTEGER autoincrement unless noted.

| Table (sql) | Class | Columns (Drift field → sql) | Notes / Grounding |
|-------------|-------|------------------------------|-------------------|
| audio_records | AudioRecord | id; title TEXT; filePath TEXT (UNIQUE); fileName TEXT; sizeBytes INTEGER; durationMs INTEGER; sha256Hash TEXT; format TEXT; folderId INTEGER? FK→folders; isMissing BOOLEAN default false; createdAt/updatedAt INTEGER | LDB-006 identity trio; UNIQUE(filePath); index(sha256Hash); index(sizeBytes,durationMs) for pre-filter; isMissing for BR-015 reconcile |
| folders | FolderRecord | id; name TEXT; path TEXT UNIQUE; isMonitored BOOLEAN default false; createdAt/updatedAt | BR-021 folder monitoring |
| playlists | PlaylistRecord | id; name TEXT; space TEXT CHECK(local/cloud); createdAt/updatedAt | BR-008 playlist scope; BR-007 stores references (see items) |
| playlist_items | PlaylistItemRecord | id; playlistId FK→playlists (cascade); audioId INTEGER? FK→audio_records (SET NULL); cloudAudioId TEXT?; position INTEGER; createdAt | BR-007 order+references; UNIQUE(playlistId,position); BR-016 removal never deletes source |
| favorites | FavoriteRecord | id; space TEXT; audioId INTEGER? FK; cloudAudioId TEXT?; createdAt | BR-009 favorite follows space; UNIQUE(space,audioId,cloudAudioId) |
| history | HistoryRecord | id; space TEXT; audioId INTEGER? FK; cloudAudioId TEXT?; playedAt INTEGER | BR-010 scope; index(playedAt DESC); max 20 enforced in app layer (BR-011) |
| downloads | DownloadRecord | id; cloudObjectId TEXT NOT NULL; audioId INTEGER? FK; filePath TEXT; sizeBytes INTEGER; sha256Hash TEXT; status TEXT (queued/downloading/completed/failed); createdAt/updatedAt | Permanent user copy — never targeted by cleanup (LDB-005) |
| cache | CacheRecord | id; cloudObjectId TEXT NOT NULL; filePath TEXT; sizeBytes INTEGER; lastAccessedAt INTEGER; createdAt | Temporary, reclaimable (LDB-005) |
| app_settings | AppSettingsRecord | id; key TEXT UNIQUE NOT NULL; value TEXT NOT NULL | Key-value singleton store |
| playback_state | PlaybackStateRecord | id; space TEXT; audioId INTEGER? FK; cloudAudioId TEXT?; positionMs INTEGER; isPlaying BOOLEAN; updatedAt INTEGER | Single active row enforced in app layer; position persisted on pause/close |

FKs use `onDelete` per semantics: playlists→cascade items; audio deletion→SET NULL on items/favorites/history (BR-016/BR-017 style reference invalidation, exact cascade policy at apply).

## Router Table & Provider Graph

**go_router** (StatefulShellRoute.indexedStack, 3 branches):

| Path | Branch | Screen | Gate |
|------|--------|--------|------|
| `/local` (initial) | 0 | LocalLibraryScreen | always accessible (BR-003/004) |
| `/cloud` | 1 | CloudLibraryScreen | unauthenticated → redirect `/cloud/sign-in` |
| `/cloud/sign-in` | 1 | SignInScreen placeholder | authenticated → redirect `/cloud` |
| `/settings` | 2 | SettingsScreen | always accessible |
| `/` | — | redirect → `/local` | |

Redirect re-evaluated via `refreshListenable`: `AuthSessionController` (manual `Notifier`) bumps a `ValueNotifier<int>` owned by the router provider; test overrides `authSessionProvider` with authenticated session (ASH-005 scenario).

**Riverpod graph** (manual API only):

```
ProviderScope
├── configProvider           (Provider<AppConfig>, built in main from dotenv)
├── databaseProvider         (Provider<AppDatabase>; test override → forTesting())
├── authSessionProvider      (NotifierProvider<AuthSessionController, AuthSession>, default unauthenticated)
├── routerProvider           (Provider<GoRouter>, watches authSessionProvider + refresh notifier)
├── audioServiceProvider     (Provider<PlaybackControllerInterface>, placeholder)
└── ProductPolicy            (plain consts — no provider; CFG-005 single source)
```

## Product Policy Contract (`core/policy/product_policy.dart`)

| Key | Type | Default (confirmed) |
|-----|------|---------------------|
| `maxUploadSizeBytes` | `const int` | `30 * 1024 * 1024` (30 MB) |
| `supportedFormats` | `const Set<String>` | `{'mp3','m4a','aac','flac','wav'}` (lowercase, no dot) |
| `historyLimit` | `const int` | `20` (BR-011) |
| `isSupportedFormat(String ext)` | method | allowlist membership (lowercased) |
| `isWithinUploadLimit(int bytes)` | method | `bytes <= maxUploadSizeBytes` |
| `DuplicatePolicy` | const doc | SHA-256 authoritative; size+duration exact pre-filter; hash stored in `AudioRecord.sha256Hash` |

No literal `30`, `31457280`, or format strings outside this file (CFG-005 meta-test).

## Interfaces / Contracts (deferrables — interfaces only)

- `MetadataExtractor` — `Future<AudioMetadata?> extract(String filePath)` (audio_metadata_reader candidate; local-library feature).
- `MediaIndexer` — folder monitoring contract (BR-021); platform-specific impl deferred.
- `TransferService` — explicit upload/download contract (BR-006); Supabase TUS resumable verified at apply.
- `PlaybackControllerInterface` — play/pause/seek/stop; just_audio/audio_service impl deferred.

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Widget | Shell renders, boots `/local`, branch state preserved, `/cloud` redirects unauthenticated, override permits Cloud (ASH-001..004) | `flutter_test` + `ProviderScope(overrides: [databaseProvider, authSessionProvider])` |
| Unit | Drift: 10 tables created (LDB-001), fresh open reaches version 1 (LDB-002), AudioRecord round-trip in memory (LDB-003), cache/download distinct (LDB-005), identity fields populated (LDB-006) | `AppDatabase.forTesting()` = `NativeDatabase.memory()`, plain `flutter test` |
| Unit | `ProductPolicy` values (CFG-004); unsupported OGG/OPUS rejected; meta-scan for duplicate literals (CFG-005) | pure Dart tests |
| Unit | `AppConfig` missing key → descriptive `ConfigException` (CFG-003); no-secrets scan of `lib/` + `.env.example` (CFG-002) | pure Dart tests |

## Migration / Rollout

No data migration (schemaVersion 1, baseline). Rollout = Batch A then Batch B, each commit-green. Rollback: revert commit → delete `lib/` skeleton → drop platform additions → remove deps (per proposal).

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Plugin/platform pairing (compileSdk/targetSdk, audio_service FGS Android 14-17, iOS 17-18 background audio) | Med | Pin Gradle compileSdk/targetSdk at Flutter 3.44 defaults; device build gate in Batch A; ADR-001 records pairing; verify at apply |
| Drift 2.34.3 / drift_flutter 0.3.1 / drift_dev 2.34.5 codegen mismatch | Med | Run `build_runner` as first Batch B step; `.g.dart` excluded from analysis; pin exact versions |
| Riverpod 2.6.1 manual Notifier API surface (NotifierProvider vs StateNotifierProvider) | Low | Manual API only; no codegen/legacy imports; verified against the pinned 2.6.1 source at apply (see ADR-003 deviation) |
| flutter_dotenv 6.0.1 needs `.env` in `pubspec assets` | Low | Add `.env` to assets in Batch B; `.env.example` committed |
| supabase_flutter 2.17.1 transitive dependency weight at pub get | Low | Resolve in Batch A gate before any code |
| Empty dirs lost in git | Low | `.gitkeep` in `view-models/`, `repositories/` |
| ADR mirror into `rep_docs/technical/architecture-decisions.md` | Low | ADRs recorded here as design artifact; optional sync task at tasks phase (product-doc change, user-confirmed) |

## Open Questions

- [ ] Mirror ADRs into `rep_docs/music_app_docs/technical/architecture-decisions.md` "Confirmed" section, or keep in openspec only?
- [ ] Exact `compileSdk`/`targetSdk`/`minSdk` numbers — resolve at apply against Flutter 3.44 defaults and plugin requirements.
