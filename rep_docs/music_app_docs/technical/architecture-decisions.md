# Architecture Decisions

## Decision status

This document records confirmed technical preferences and current leading choices. It is intentionally separate from product requirements.

## Confirmed

- Mobile only: Android + iOS, tablets included.
- Android-first development, then iOS validation.
- Local database exists for all users.
- Local and Cloud libraries remain separate.
- Permanent downloads and temporary streaming cache are distinct.
- Background playback is mandatory.
- Architecture changes require explicit user approval.
- Significant architectural changes require ADR documentation.
- Dependencies should be minimal and justified.
- Code generation should be minimal and justified.
- Product logic should remain platform-independent wherever practical.

## Leading architectural direction

```text
Presentation
   |
ViewModels / State
   |
Repositories
   |
Services / Data Sources
   |
+-------------------+--------------------+
| Local             | Cloud              |
| media/files       | API + storage      |
| local database    | private storage    |
+-------------------+--------------------+
            |
        Audio layer
            |
   just_audio candidate
            |
      audio_service
```

This is a conceptual architecture, not a final folder structure.

## State management

The user delegated the choice. The selection must optimize for:

- speed;
- testability;
- low boilerplate;
- maintainability;
- predictable dependency injection;
- suitability for streams and background audio state.

**CONFIRMED (ADR-003): flutter_riverpod 2.6.1**, manual `Notifier`/`Provider`/`ConsumerWidget`
API. No code generation for providers (keeps the minimal-codegen rule).

Version pin rationale: Riverpod 3.x is not usable with the current Flutter/Dart
toolchain (its `test ^1.0.0` dependency conflicts with the `flutter_test` pins,
and the `supabase_flutter` → `realtime_client` → `web_socket_channel ^3.0.3`
chain blocks the remaining resolution ranges — verified with the pub solver).
2.6.1 is the latest 2.x and its manual API is identical, so the decision is
unchanged: any future 3.x migration needs a new ADR.

## Navigation

**CONFIRMED (ADR-004): go_router 17.5.0** with `StatefulShellRoute.indexedStack`
(three branches: Local, Cloud, Settings; per-branch state; auth-gate redirects;
deep links; no codegen). Compatibility verified at apply time.

## Why this is not a large Clean Architecture template

The app should not start with unnecessary domain/use-case layers. Layers should be introduced when they reduce real complexity.

## ADR rule

Any decision that changes one of the following requires an ADR and user approval:

- audio engine;
- storage/backend provider;
- database technology;
- state management;
- navigation strategy;
- local media indexing strategy;
- sync identity/conflict model;
- security model;
- cross-platform architecture.

## Recorded ADRs

Confirmed decisions recorded with the change that introduced them
(change: `foundations`, flutter app skeleton).

| ADR | Decision | Rationale (short) |
|-----|----------|--------------------|
| ADR-001 | Audio engine: `just_audio` 0.10.6 + `audio_service` 0.18.19 + `audio_session` 0.2.4 | ExoPlayer/AVPlayer codecs, queue, background playback, media controls, headset events; Dart ^3.6 compatible. Risk noted: Android 17 FGS hardening requires foreground-service types + POST_NOTIFICATIONS from day one |
| ADR-002 | Storage provider: Supabase (`supabase_flutter` 2.17.1) | Only option covering auth (Google OAuth) + Postgres metadata + private buckets + RLS + signed URLs + TUS resumable transfers in one managed product; alternatives force a custom backend (violates keep-it-small) |
| ADR-003 | State management: `flutter_riverpod` 2.6.1, manual API | Testability via ProviderScope overrides, DI without context, streams; rejected: Bloc (boilerplate), Provider (weak async), `@riverpod` codegen (minimal-codegen rule). Pin rationale documented in the State management section |
| ADR-004 | Navigation: `go_router` 17.5.0, `StatefulShellRoute.indexedStack` | Declarative, per-branch navigation state, auth redirect guards, deep links, no codegen; rejected: auto_route (codegen-heavy), imperative Navigator |
| ADR-005 | Local database: Drift 2.34.3 + `drift_flutter` 0.3.1 (`drift_dev` 2.34.5) | Type-safe SQL, versioned migrations, reactive `watch()`, in-memory test database, relational model maps 1:1 to the 10 persisted records; rejected: Isar (archived, no Dart 3), sqflite (raw SQL) |
| ADR-006 | Policy/identity model: 30 MB upload limit; allowlist MP3/M4A(AAC)/FLAC/WAV; duplicate = SHA-256 authoritative over size+duration pre-filter; history max 20 | User-confirmed; OGG/OPUS excluded (unreliable iOS AVPlayer support); layered hash detection per local-persistence-and-sync |

## Recorded change decisions (change: `custom-navbar`, custom floating navigation bar)

Non-ADR decisions recorded with the change that introduced them (change: `custom-navbar`).
These do not require an ADR under the rule above (no engine/storage/DB/state/nav-strategy
change); they are recorded here because the design's open question asked for a decision
doc and the verify report requested reconciliation at archive.

| Decision | Choice | Rationale (short) |
|----------|--------|--------------------|
| D4 — LDB-008 downloads ordering | `updatedAt` DESC primary, `id` DESC tie-break | A completed-downloads view means "most recently completed first"; `updatedAt` reflects the transfer state machine's last change (completion time for completed rows), `createdAt` would order by transfer start (stale semantics); `id DESC` is a deterministic tie-break for identical timestamps |
| D5 — LDB-007 history tie-break | `playedAt` DESC (spec) + `id` DESC secondary | Matches "most recent play first" and keeps query results reproducible for identical `playedAt` timestamps |
| D2 — FloatingNavBar theme tokens | Bar `colorScheme.surfaceContainer`; center circle `secondaryContainer`/`onSecondaryContainer`; side icons `onSurfaceVariant`/`onSurface`; container radius `cardTheme.shape`; elevation `navigationBarTheme.elevation` | One radius does not justify a ThemeExtension (justify-every-token rule); deriving from M3 tokens satisfies ASH-007 "no hardcoded color/radius constants". Reconciliation (commit 2787e3e): `buildAppTheme()` sets radius 12 / elevation 3 and the widget throws `StateError` if the tokens are absent — no silent hardcoded fallbacks |

