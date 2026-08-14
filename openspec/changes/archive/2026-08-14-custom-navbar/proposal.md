# Proposal: Custom Floating Navigation Bar (Music / History / Settings)

## Intent

Replace the standard Material 3 `NavigationBar` with a custom floating rounded bar and adopt the user-confirmed IA: **History | Music (center, prominent) | Settings**. Music hosts the Local/Cloud spaces via an internal top toggle; Cloud stays gated (sign-in hint per PRODUCT_SPEC L78). First slice is UI-only + read-layer verification so the router can swap in later with zero adapter work.

## Product Documentation Impact

| Doc | Section | Content | Status |
|-----|---------|---------|--------|
| PRODUCT_SPEC.md | §4 (L65-78) | Nav = Música/Playlist/Configuración → **Music/History/Settings** | **IN SCOPE** (user sign-off) |
| PRODUCT_SPEC.md | §4 L78 | Cloud shows sign-in option | Keep — no change now (in-screen gate in router slice) |
| PRODUCT_SPEC.md | §13 L230 | mini-player on main nav | Generic — no change |
| business-rules.md | BR-003/004/011 | /music accessibility; history cap 20 | No wording change; BR-011 enforced in repo (this slice); BR-003/004 → router slice |
| core-user-flows.md | Flow 01/02 | "core navigation", "chooses Cloud" | Generic — no change |
| decisions/open-decisions.md | — | No nav IA references | No change |
| technical/open-technical-decisions.md | "Navigation solution" (L19) | Open checkbox | DEFERRED — close in router slice; ADR-004 stands (UI change, no new ADR) |
| technical/technical-requirements.md | L21/123/144 | "Playlist" = feature (downloads/persistence) | No change |
| openspec/specs/app-shell/spec.md | ASH-001/003/004/005 | /local boot, 3 branches, redirects | DEFERRED (router slice); additive ASH-007 IN SCOPE |
| openspec/specs/local-database/spec.md | LDB-001..006 | Schema only; repos out of scope | Modified: additive read-query requirements IN SCOPE |

## Scope

### In Scope

- `FloatingNavBar` — isolated pure-presentational widget (no Riverpod/router/auth imports); contract `selectedIndex` + `onDestinationSelected(int)`; theme-derived colors/radii (`colorScheme`/`shape`), no hardcoded tokens.
- Widget tests: labels, tap → index callback, prominent center destination, no `NavigationBar` inside.
- Read-layer verification: `HistoryRepository` (space-scoped last-played, cap-20 BR-011 enforced in repo) + `DownloadsRepository` (completed explicit cloud copies BR-006); drift watch/select queries; in-memory DB tests.
- PRODUCT_SPEC.md §4 wording update (Music / History / Settings).

### Out of Scope

- Router wiring / AppShell swap; ASH-003 branch rewrite (/music,/history,/settings); in-screen auth gating for the Cloud tab; playlist feature; playback UI; mini player; any other product-doc edits.

## Capabilities

- **Modified `app-shell`**: additive ASH-007 — custom floating rounded nav bar (pure presentational, index contract, theme-derived tokens). Existing ASH-001/003/004/005 unchanged in this change.
- **Modified `local-database`**: additive LDB-007 history reads + LDB-008 download reads (repository layer; BR-011 cap and space scoping live here).
- New: None.

## Approach

1. `lib/presentation/widgets/floating_nav_bar.dart`: Stateless widget mirroring `NavigationBar`'s contract; const destinations (History=0, Music=1 center prominent, Settings=2); visuals derived from `Theme.of(context)` (`colorScheme` surface tint, indicator pill, `shape` radius); floating via SafeArea + padding.
2. Widget tests under `test/presentation/widgets/`, pumping `MaterialApp(theme: appTheme)`.
3. `lib/repositories/history_repository.dart` (`watchRecent(space, limit: productPolicy.historyLimit)`, ordered playedAt desc) and `downloads_repository.dart` (`watchCompleted()`, status == completed); unit tests with in-memory DB prove BR-011 cap (>20 inserts) and space scoping.
4. Edit PRODUCT_SPEC.md §4 destination list; keep Local/Cloud separation and the L78 sign-in hint.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/presentation/widgets/floating_nav_bar.dart` | New | The isolated bar widget |
| `lib/repositories/history_repository.dart` | New | Last-played reads, cap-20 |
| `lib/repositories/downloads_repository.dart` | New | Completed-download reads |
| `test/presentation/widgets/floating_nav_bar_test.dart` | New | Bar widget tests |
| `test/repositories/history_repository_test.dart`, `test/repositories/downloads_repository_test.dart` | New | Read-layer tests |
| `rep_docs/music_app_docs/PRODUCT_SPEC.md` §4 | Modified | IA wording (Music/History/Settings) |
| `openspec/specs/app-shell/spec.md`, `openspec/specs/local-database/spec.md` | Modified (archive) | ASH-007, LDB-007/008 deltas |
| `lib/core/router/app_router.dart`, `lib/presentation/app_shell.dart` | Untouched | Router slice later |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| PRODUCT_SPEC §4 conflict (old IA) | High | User sign-off captured; §4 updated this slice |
| Gate relocation (router → in-screen) | Med | Deferred to router slice; index contract avoids rework; L78 hint kept |
| Cap-20 semantics drift to UI | Med | Enforced in HistoryRepository with tests (BR-011) |
| Destination→branch index drift | Low | Contract documented in widget + ASH-007 |
| Hardcoded theme tokens | Low | All visuals theme-derived; tests assert no NavigationBar |
| Existing tests break | Low | Router untouched; old NavigationBar assertions stay valid |

## Rollback Plan

All-additive: delete widget/repos/tests, revert PRODUCT_SPEC §4. Router untouched → no runtime behavior change. Restore point: pre-change commit on `feature/custom-navbar`.

## Dependencies

- Flutter 3.44.9 / Dart 3.12.2; existing drift schema (tables already defined); no new packages.

## Success Criteria

- [ ] `flutter analyze` clean
- [ ] `flutter test` passes (new widget + repository tests; existing suite unchanged)
- [ ] Bar is pure presentational — no Riverpod/go_router/auth imports; honors `selectedIndex`/`onDestinationSelected`
- [ ] HistoryRepository proves BR-011 cap-20 + space scoping via tests
- [ ] DownloadsRepository proves BR-006 completed-copy reads via tests
- [ ] PRODUCT_SPEC.md §4 lists Music / History / Settings
- [ ] `app_router.dart` and `app_shell.dart` unmodified