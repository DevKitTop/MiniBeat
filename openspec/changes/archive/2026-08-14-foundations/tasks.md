# Tasks: Foundations — rep_mini scaffold

## Review Workload Forecast

~1900 lines: Batch A ~340 (Low), Batch B ~1560 (High, incl. .g.dart ~600). PR 1 = A → PR 2 = B, stacked to main. Delivery: ask-on-risk.

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

Commits (gates: W1–W3 analyze, W4+ analyze+test, W5–W9 flutter test):
W0 scaffold (A1) · W1 skeleton+deps (A2–A3) · W2 env+lints+AGENTS (A4–A6) · W3 android+iOS (A7–A8) · W4 Batch A boundary (A9) · W5 db (B1–B4) · W6 config+policy (B5–B6) · W7 shell (B7–B10) · W8 wiring+interfaces (B11–B12) · W9 smoke (B13).

## Phase 1 — Batch A: infra/config (no Dart under lib/)

Deps: A1→all; A3→all B; A4→B11; A5→analyze gates.

- [x] A1 — git init + .gitignore + initial commit — `git log`, `flutter test` green
- [x] A2 — lib/ skeleton per design tree + .gitkeep — ASH-006 — dirs exist, no domain/
- [x] A3 — pubspec pins stack deps per #437 (just_audio, audio_service, audio_session, supabase_flutter, flutter_riverpod, go_router, drift, drift_flutter, google_sign_in, flutter_dotenv; dev: drift_dev, build_runner) + `flutter pub get` — lock pinned
- [x] A4 — .env.example placeholders (SUPABASE_URL, ANON_KEY, GOOGLE_CLIENT_ID) + .env + .gitignore — CFG-001/002 — no secrets, .env untracked
- [x] A5 — analysis_options.yaml: flutter_lints, exclude `**/*.g.dart` — PLT-006 — `flutter analyze` clean
- [x] A6 — root AGENTS.md: no secrets, Local/Cloud separation, ADR rule — PLT-005/CFG-002
- [x] A7 — AndroidManifest: POST_NOTIFICATIONS, FOREGROUND_SERVICE(+MEDIA_PLAYBACK), AudioService FGS, app-link filter; strings/gradle OAuth placeholders — PLT-001/003/004 — apk debug build
- [x] A8 — iOS Info.plist: UIBackgroundModes audio, CFBundleURLTypes scheme, associated-domains placeholder — PLT-002/003/004 — inspect
- [x] A9 — Batch A gate: pub get+analyze+test clean; commit W4

## Phase 2 — Batch B: app skeleton (Dart + tests; test-first RED→GREEN)

Deps: B1→B2→B3→B4; B7/B8→B9→B10→B11→B13; B5/B6 before B11.

- [x] B1 — 10 Drift tables, @DataClassName, FKs — LDB-001/005/006 — compiles
- [x] B2 — app_database.dart: v1, MigrationStrategy (onCreate, foreign_keys), forTesting() memory — LDB-002/003
- [x] B3 — build_runner → schema-only .g.dart — LDB-004
- [x] B4 — app_database_test.dart: 10 tables, open v1, AudioRecord round-trip, cache≠download, identity — LDB-001..006
- [x] B5 — AppConfig{supabaseUrl, anonKey} + ConfigException on missing key — CFG-003 — test throws
- [x] B6 — ProductPolicy: 30MB, {mp3,m4a,aac,flac,wav}, historyLimit 20 + helpers; tests: values, OGG/OPUS reject, literal meta-scan, no-secrets — CFG-004/005/002
- [x] B7 — app_theme.dart: M3 + Roboto, Google Sans caveat — ASH-002
- [x] B8 — providers: auth_session (manual Notifier, unauth) + app_providers graph — ASH-001/005
- [x] B9 — router: StatefulShellRoute.indexedStack 3 branches + /cloud/sign-in, redirect refreshListenable — ASH-003/004
- [x] B10 — app_shell.dart + 4 placeholder screens — ASH-003/004
- [x] B11 — main/app.dart: dotenv → AppConfig → ProviderScope → MaterialApp.router; .env asset — ASH-001/CFG-001
- [x] B12 — interfaces: metadata_extractor, media_indexer, transfer_service, playback_controller — deferrables
- [x] B13 — smoke tests: shell renders, /local boots, /cloud redirects unauth, override Cloud OK — ASH-001..004
- [x] B14 — optional: mirror ADRs to rep_docs/…/architecture-decisions.md

Open: ADR mirror to rep_docs? compileSdk pin at apply.
