## Archive Report — custom-navbar

**Change**: custom-navbar — custom floating navigation bar (Music / History / Settings)
**Archived to**: `openspec/changes/archive/2026-08-14-custom-navbar/`
**Date**: 2026-08-14
**Branch**: `feature/custom-navbar` (merge base 192acf2)
**Status**: ✅ ARCHIVED — PASS (verify: WARNING resolved, re-verified 61/61)

### Summary

The `custom-navbar` change delivered the first UI slice of the user-confirmed navigation IA **History | Music (center, prominent) | Settings**: a pure-presentational `FloatingNavBar` widget (ASH-007), a repository read-layer verifying the two queries the router slice will consume (`HistoryRepository` LDB-007 with BR-011 cap-20 + space scoping; `DownloadsRepository` LDB-008 with completed-status filter), and the PRODUCT_SPEC.md §4 wording update. Router wiring, the ASH-003 branch rewrite (`/music`, `/history`, `/settings`), and in-screen auth gating were deliberately deferred to a future router slice — `app_shell.dart`, `app_router.dart`, and `app_providers.dart` were untouched. The spec deltas (ASH-007, LDB-007/008) were written additively into the main specs during the spec phase, so archive delta-sync was a verification-only pass.

### What was implemented

| Area | Deliverable |
|------|-------------|
| UI | `lib/presentation/widgets/floating_nav_bar.dart` — stateless, fixed 3-slot, center-prominent circle, theme-derived tokens only (no riverpod/go_router/auth imports) |
| Data (read layer) | `lib/repositories/history_repository.dart` (space-scoped, cap-20, BR-011) + `lib/repositories/downloads_repository.dart` (status filter, BR-006); drift `watch()` streams, no repository providers this slice |
| Tests | `test/presentation/widgets/floating_nav_bar_test.dart` (7), `test/repositories/history_repository_test.dart` (6), `test/repositories/downloads_repository_test.dart` (5), +2 D2 verify-fix tests |
| Docs | PRODUCT_SPEC.md §4 — Música/Playlist/Configuración → History / Music (centro, destacado) / Settings (single hunk; Local/Cloud bullets + L78 sign-in sentence untouched) |
| Specs | ASH-007 appended to `openspec/specs/app-shell/spec.md`; LDB-007/008 appended to `openspec/specs/local-database/spec.md` (done additively at spec phase) |

### Verification evidence

- `flutter test`: **61/61 passed**, 0 failed, 0 skipped (re-verified at archive time)
- `flutter analyze`: **No issues found** (6.3s)
- Spec compliance: 10/10 scenarios COMPLIANT (ASH-007 S1–S4, LDB-007 S1–S3, LDB-008 S1–S3)
- TDD: 10/10 tasks complete (W1–W10), strict RED→GREEN→REFACTOR evidence in apply-progress (Engram #463)
- Commits (4, Conventional, no AI-attribution):
  - `2e9e346` feat(ui): add custom floating navigation bar
  - `4a7a51a` feat(data): add history and downloads read repositories
  - `e22d348` docs(product): update navigation wording to Music/History/Settings
  - `2787e3e` fix(theme): derive nav bar radius/elevation from theme tokens (verify-fix batch)

### Decisions made

Design decisions D1–D7 (fixed 3-slot API; theme-derived tokens; center prominence tonal+size; LDB-008 `updatedAt` DESC + `id` DESC; LDB-007 `playedAt` DESC + `id` DESC tie-break; two focused repositories; drift watch streams with no providers) were all followed as designed. Two decision-recording actions were taken at archive, per the verify SUGGESTION and the design open question:

1. **D4/D5 ordering decisions** — recorded into `rep_docs/music_app_docs/technical/architecture-decisions.md` ("Recorded change decisions" section, change-attribution pattern matching the existing ADR table). Rationale: LDB-008's open question required resolution in a decision doc; `updatedAt DESC` reflects completion time for completed rows, `id DESC` gives deterministic tie-breaks.
2. **D2 theme-token reconciliation** — recorded alongside D4/D5. The verify WARNING (hardcoded radius 12 / elevation 3 fallbacks always active) was closed by commit `2787e3e`: `buildAppTheme()` now sets `cardTheme.shape` (radius 12) and `navigationBarTheme.elevation` (3), and `FloatingNavBar` throws `StateError` when the tokens are absent instead of silently substituting constants. ASH-007's "MUST NOT use hardcoded color or radius constants" is now literally satisfied.

Decision-recording convention note: `rep_docs/music_app_docs/decisions/open-decisions.md` is reserved for *open* decisions, and `rep_docs/music_app_docs/technical/architecture-decisions.md` records *confirmed* technical decisions with change attribution — the established convention, so the D4/D5/D2 records were placed in the latter. No new decision-doc location was invented.

### Deferred items (explicitly out of scope — router slice)

- Router wiring of `FloatingNavBar` into the shell (AppShell swap; `app_shell.dart` / `app_router.dart` / `app_providers.dart` remain untouched)
- ASH-003 branch rewrite: `/local`, `/cloud`, `/settings` → `/music`, `/history`, `/settings` (index contract 0=/history, 1=/music, 2=/settings already documented in the widget to prevent index drift)
- In-screen auth gating for the Cloud tab (the L78 sign-in hint in PRODUCT_SPEC.md stays; gating moves from router redirect to in-screen)
- Closing the "Navigation solution" checkbox in `technical/open-technical-decisions.md` (ADR-004 stands; no new ADR needed for this UI-only change)

### Spec sync status

| Domain | Requirement | Status |
|--------|-------------|--------|
| app-shell | ASH-007 Custom floating navigation bar | ✅ Present in `openspec/specs/app-shell/spec.md` (4 scenarios) |
| local-database | LDB-007 History read query | ✅ Present in `openspec/specs/local-database/spec.md` (3 scenarios) |
| local-database | LDB-008 Downloads read query | ✅ Present (3 scenarios); the embedded "Open question" blockquote about ordering is now resolved by the D4 decision record — a future spec cleanup may fold the exact ordering into the requirement text (not required for compliance) |

No destructive merges; the deltas were already applied additively during the spec phase.

### Next steps

- **Router slice change** (next SDD change): wire `FloatingNavBar` into the shell, rewrite ASH-003 branches to `/music`/`/history`/`/settings` (updating ASH-001/003/004/005 scenarios as needed), add in-screen auth gating for the Cloud space, close the navigation open-decision checkbox, and land repository providers (`StreamProvider`s over the D7 `watch()` streams).
- Optional: fold the D4 ordering wording into LDB-008's requirement text and remove the open-question blockquote.

### Engram traceability

- `sdd/custom-navbar/verify-report` — observation **#464**
- `sdd/custom-navbar/apply-progress` — observation **#463** (includes D2 verify-fix batch)
- `sdd/custom-navbar/tasks` — **#461** · `sdd/custom-navbar/design` — **#460** · `sdd/custom-navbar/spec` — **#459** · `sdd/custom-navbar/proposal` — **#458** · explore — **#457** · delivery decision — **#455**
- `sdd/custom-navbar/archive-report` — this report (saved at archive time)