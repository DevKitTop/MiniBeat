# Tasks: Custom Floating Navigation Bar (Music / History / Settings)

## Review Workload Forecast

~620 lines: B1 widget+tests ~320 (Med) · B2 repos+tests ~285 (Med) · B3 docs ~10 (Low). PR 1 = B1 → PR 2 = B2 → PR 3 = B3, stacked to main. Delivery: ask-on-risk.

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

Commits (gates: W1–W3 analyze, W4–W8 analyze+test, W9 docs, W10 full suite):
W1 bar tests RED · W2 bar GREEN · W3 bar refactor+analyze · W4 history tests RED · W5 history repo GREEN · W6 downloads tests RED · W7 downloads repo GREEN · W8 batch-2 gate · W9 PRODUCT_SPEC §4 · W10 final gate.

## Phase 1 — Batch 1: FloatingNavBar widget + tests (ASH-007; strict TDD RED→GREEN→REFACTOR)

Deps: W1→W2→W3. No prior batch dependency.

- [x] W1 (RED) — `test/presentation/widgets/floating_nav_bar_test.dart` (new dir), pump `MaterialApp(theme: buildAppTheme(), home: Scaffold(bottomNavigationBar: ...))`, no ProviderScope/router: failing tests — exactly 3 destinations in order History, Music, Settings (`find.text` + x-order via `getTopLeft`); center Music slot bigger than side slots (`getSize`); `find.byType(NavigationBar)` findsNothing; tap key `floating-nav-destination-2` → callback index 2; bar color == `colorScheme.surfaceContainer`, radius == `cardTheme.shape`, elevation == `navigationBarTheme.elevation`; `selectedIndex: 0` → History visually distinct — ASH-007
- [x] W2 (GREEN) — `lib/presentation/widgets/floating_nav_bar.dart` (new dir): stateless, fixed 3-slot (History=0, Music=1 center prominent, Settings=2), API `selectedIndex` + `onDestinationSelected`; `SafeArea(top: false)` + horizontal padding + rounded `Material`; `Semantics(button: true, selected:)` + visible labels; theme-derived tokens only (D2/D3: surfaceContainer, secondaryContainer circle ~56dp, onSurfaceVariant/onSurface, cardTheme.shape, navigationBarTheme.elevation); doc-comment index→branch contract (0=/history, 1=/music, 2=/settings); NO riverpod/router/auth imports — minimum to pass — ASH-007
- [x] W3 (REFACTOR) — triangulate, `dart format`, `flutter analyze` clean; grep confirms no riverpod/go_router/auth imports in the widget; commit W3 — ASH-007

## Phase 2 — Batch 2: Repository read layer (LDB-007/008; strict TDD)

Deps: W4→W5, W6→W7, W8 after W5+W7. Independent of Batch 1.

- [x] W4 (RED) — `test/repositories/history_repository_test.dart` (new dir; `AppDatabase.forTesting()` setUp/tearDown per `app_database_test.dart`): failing tests — 25 inserts one space → at most 20, most recent first; local+cloud rows → space filter returns local only; empty space → empty; identical `playedAt` → `id` DESC; `limit: 5` → 5, `limit: 50` → still 20 — LDB-007/BR-011
- [x] W5 (GREEN) — `lib/repositories/history_repository.dart`: `watchRecent({required String space, int limit = ProductPolicy.historyLimit})` → drift `watch()`, where space, `orderBy` playedAt DESC + id DESC, cap `min(limit, ProductPolicy.historyLimit)`; no providers this slice — LDB-007
- [x] W6 (RED) — `test/repositories/downloads_repository_test.dart`: failing tests — completed+failed+queued rows → only completed; distinct `updatedAt` → DESC; identical `updatedAt` → `id` DESC; no completed rows → empty — LDB-008
- [x] W7 (GREEN) — `lib/repositories/downloads_repository.dart`: `watchByStatus(String status)` → drift `watch()`, where status, `orderBy` updatedAt DESC + id DESC — LDB-008/D4
- [x] W8 — batch-2 gate: `flutter analyze` clean + both repo suites green; commit W8

## Phase 3 — Batch 3: PRODUCT_SPEC §4 wording

Deps: independent.

- [ ] W9 — `rep_docs/music_app_docs/PRODUCT_SPEC.md` §4 (L65-78): replace Música/Playlist/Configuración block and `Dentro de Música` with the design's exact text (Music / History / Settings bullets in bar order, `Music (centro, destacado)`, `Dentro de Music`); keep `- Local` / `- Cloud` bullets and the L78 sign-in sentence; verify `git diff` shows §4 only — no tests needed

## Phase 4 — Finalization

Deps: W10 after all batches.

- [ ] W10 — full gate: `flutter analyze` clean + full `flutter test` green (existing `app_shell_test.dart`/`widget_test.dart` assert `NavigationBar` — app_shell untouched, still pass); commits already split by work unit