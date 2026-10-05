# Tasks: Cyberpunk Palette Traceability

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~300 (theme +40, theme test +120, nav-bar test +35, widget_test +18, app.dart +3, this file +95) |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single commit after `06c4a20` (docs) |
| Delivery strategy | ask-always |
| Chain strategy | pending |

Commit 1 = `docs(sdd):` already pushed as `06c4a20` (363 lines). Binary font assets do not count as lines.

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

## Phase 1 — Unit RED (lib untouched)

- [x] W1 (RED) `test/core/theme/app_theme_test.dart`: add a second const block mirroring design.md token table for BOTH brightnesses — do NOT import from `lib/`. Assert 15 tokens as literal hex each: dark `background 0xFF0B0B1A`(scaffold), `surface 0xFF14142B`, `surfaceContainerLowest 0xFF0C0C1C`, `Low 0xFF101026`, `surfaceContainer 0xFF181833`, `High 0xFF1B1B3B`, `Highest 0xFF1E1E3F`, `primary 0xFF8B5CF6`, `secondary 0xFF3B82F6`, `tertiary 0xFF22D3EE`, `secondaryContainer 0xFF1E3A6E`, `onSecondaryContainer 0xFFD7E3FF`, `onSurface 0xFFEDE9FE`, `onSurfaceVariant 0xFF9A95C8`, `error 0xFFB91C1C`; light `background 0xFFF4F2FF`, `surface 0xFFFFFFFF`, `Low 0xFFF7F4FD`, `surfaceContainer 0xFFF0ECFA`, `High 0xFFE9E4F6`, `Highest 0xFFE2DCF2`, `primary 0xFF6D28D9`, `secondary 0xFF2563EB`, `tertiary 0xFF0891B2`, `secondaryContainer 0xFFDCE7FD`, `onSecondaryContainer 0xFF0B2A6B`, `onSurface 0xFF1A1636`, `onSurfaceVariant 0xFF5E5A85`, `error 0xFFB91C1C`. Pass: fails on missing container tokens + dark foregrounds.
  - **Result**: RED confirmed — 10 pass / 9 fail. Measured dark contrast 1.0044:1 and 2.6921:1, matching design.md's predicted 1.00:1 / 2.69:1.
- [x] W2 (RED) same file: ladder monotonicity — `computeLuminance()` over Lowest→Low→surfaceContainer→High→Highest strictly increases (dark) / strictly decreases (light). Pass: fails now.
  - **Result**: RED confirmed. Dark ladder measured 0.00823 flat across four roles (all inheriting `surface`), light 1.0 flat.
- [x] W3 (RED) same file: contrast helper over hardcoded hex — `onSurface 0xFFEDE9FE` and `onSurfaceVariant 0xFF9A95C8` each ≥ 3.0:1 against `0xFF181833`. Pass: fails (1.08:1 / 2.69:1 today).
  - **Result**: RED confirmed. Reads the production `onSurface`/`onSurfaceVariant` against the literal bar colour — a hardcoded-only test could never fail. Triangulated with the center-circle pair and the whole light palette.

## Phase 2 — Unit GREEN

- [x] W4 (GREEN) `lib/core/theme/app_theme.dart`: add 11 consts and pass them into both schemes. Dark: `surfaceContainerLowest 0xFF0C0C1C`, `Low 0xFF101026`, `surfaceContainer 0xFF181833`, `High 0xFF1B1B3B`, `Highest 0xFF1E1E3F` (reuse existing `_darkSurfaceVariant`), `secondaryContainer 0xFF1E3A6E`, `onSecondaryContainer 0xFFD7E3FF`. Light: `Low 0xFFF7F4FD`, `surfaceContainer 0xFFF0ECFA`, `High 0xFFE9E4F6`, `Highest 0xFFE2DCF2`, `secondaryContainer 0xFFDCE7FD`, `onSecondaryContainer 0xFF0B2A6B`. Rename shared `_onSurface`/`_onSurfaceVariant` to per-brightness `_darkOnSurface 0xFFEDE9FE` / `_darkOnSurfaceVariant 0xFF9A95C8` / `_lightOnSurface 0xFF1A1636` / `_lightOnSurfaceVariant 0xFF5E5A85`. Do NOT pass light `surface` or light `surfaceContainerLowest` (Decision C; `avoid_redundant_argument_values`, `analysis_options.yaml:19`). Keep `cardTheme.shape` radius 12 and `navigationBarTheme.elevation` 3 outside the brightness branch. Pass: W1–W3 green.
  - **Result**: GREEN — 20/20 in the theme test. Light `surface` and `surfaceContainerLowest` omitted; both pinned by value.

## Phase 3 — Widget intent

- [x] W5 (GREEN) `test/presentation/widgets/floating_nav_bar_test.dart`: replace the derivation-only checks with literal ones — bar `Material.color` equals `0xFF181833` (dark) / `0xFFF0ECFA` (light) and differs from `colorScheme.surface`; center circle `BoxDecoration.color` equals `0xFF1E3A6E` / `0xFFDCE7FD` and is NOT `colorScheme.secondary`. Pass: green without touching `floating_nav_bar.dart`.
  - **Result**: 8 pass / 2 fail, both pre-existing. `floating_nav_bar.dart` untouched. Added light-palette variants of both assertions as triangulation.

## Phase 4 — A2 wiring

- [x] W6 (RED) `test/widget_test.dart`: pump `_boot()`, read the `MaterialApp.router` widget — `theme.brightness == Brightness.light`, `darkTheme.brightness == Brightness.dark`, `themeMode == ThemeMode.system`. Also assert the resolved scheme colours follow that polarity: `theme.colorScheme.primary == 0xFF6D28D9` (light primary) and `darkTheme.colorScheme.primary == 0xFF8B5CF6` (dark primary). Pass: fails (`darkTheme`/`themeMode` null today).
  - **Result**: RED confirmed — `theme.brightness` was `dark`; `theme.colorScheme.primary` was `0xFF8B5CF6`.
- [x] W7 (GREEN) `lib/app.dart`: on the existing `MaterialApp.router` add `darkTheme: buildAppTheme(brightness: Brightness.dark)` and `themeMode: ThemeMode.system`, and change the existing `theme:` to `buildAppTheme(brightness: Brightness.light)`. Pass: W6 green.
  - **Result**: GREEN — 5/5 in `widget_test.dart`. **DEVIATION**: `darkTheme: buildAppTheme(brightness: Brightness.dark)` and `themeMode: ThemeMode.system` were written as `darkTheme: buildAppTheme()` and the `themeMode` argument dropped, because both restate an existing default and tripped `avoid_redundant_argument_values` — the same rule ASH-011 sets for light `surface`. Both are pinned by value in `test/widget_test.dart`.

## Phase 5 — Gate + commit

- [x] W8 `dart format .` then `flutter analyze` → `No issues found!` then `flutter test` → 68 + new passing, ZERO new failures. The 2 pre-existing failures in `floating_nav_bar_test.dart` (`Historial`/`Música`/`Ajustes` vs asserted `History`/`Settings`) stay untouched — not regressions.
  - **Result**: `flutter analyze` → `No issues found!`. `flutter test` → **89 passed / 2 failed** against a clean-HEAD baseline of **68/2** (re-verified via `git worktree` at `6bf84bd`) = **+21 new**, all green, zero new failures. The 2 failures are the pre-existing Spanish-label ones.
  - **Corrected**: this line previously recorded the baseline as 75/2 and the delta as +14. Both were wrong. The clean-HEAD baseline is **68/2** — the earlier 75 was measured with a preliminary, still-broken `app_theme_test.dart` already in the working tree, which inflated the baseline by 7. Net new is **+21**, not +14.
  - **Note**: `dart format .` is a repo-wide sweep and reformatted 14 unrelated files (drift tables, `app_shell_test.dart`, `app_database_test.dart`, and others). Those were reverted to keep the diff scoped to this work unit; only the 5 files in this change are format-clean and modified.
- [ ] W9 Commit all as one work unit (`feat(theme): pin cyberpunk palette tokens for both brightnesses`), tests with the code they cover, no AI attribution. Include `lib/core/theme/app_theme.dart`, `lib/app.dart`, `test/core/theme/app_theme_test.dart`, `test/presentation/widgets/floating_nav_bar_test.dart`, `test/widget_test.dart`, `pubspec.yaml`, `assets/fonts/PlusJakartaSans-*`, this file.
  - **NOT DONE — delegated to the orchestrator.** The apply-phase launch prompt explicitly forbids `git commit`, `git push` and PR creation; changes are left staged-but-uncommitted.
  - **Budget flag**: the diff is 528 insertions / 39 deletions = **567 changed lines**, over the 400-line review budget. The forecast (~395 incl. this file) underestimated the theme test (260 added vs 120 predicted). The driver is the required ASH-008 scenario coverage plus strict-TDD triangulation. Delivery strategy is `ask-always`, so the orchestrator must choose: accept `size:exception`, or split into two work units (palette+tokens, then A2 wiring).

## Phase 6 — Review fix list (SHIP-WITH-FIXES, zero CRITICAL)

Reviewer returned SHIP-WITH-FIXES and independently confirmed all 30 hex values, a non-tautological oracle, the `theme`/`darkTheme` mapping, clean `flutter analyze`, WCAG pairs over 3:1, ladder monotonicity both directions, and no secrets in the diff. The WARNING list was applied as follows. Palette hex values, nav-bar visuals, router, screens and `pubspec.yaml` declarations were NOT touched.

- [x] F1 (ASH-011) `lib/core/theme/app_theme.dart`: removed `surfaceTint: _darkPrimary` / `surfaceTint: _lightPrimary`. `ColorScheme` declares `surfaceTint => _surfaceTint ?? primary` (`color_scheme.dart:1338`), so both were redeclaring the M3 default. Approval test added first (`surfaceTint` resolves to `primary` on both palettes) — passed before and after, so behaviour is provably unchanged.
- [x] F2 (ASH-010 scenario 2, previously uncovered) `test/widget_test.dart`: new test sets `platformDispatcher.platformBrightnessTestValue` to dark then light and reads the RESOLVED theme via `Theme.of` on an element below `MaterialApp`, asserting `surfaceContainer` is `0xFF181833` then `0xFFF0ECFA`. `addTearDown` calls `clearPlatformBrightnessTestValue()` so the override cannot leak.
  - **RED proof**: with `themeMode: ThemeMode.light` temporarily pinned in `lib/app.dart`, the test failed — dark platform polarity resolved `0xFFF0ECFA` instead of `0xFF181833`. Restored → green. This is the inversion the previous slot-only assertions could not see.
- [x] F3 (ASH-002 scenario 2, previously uncovered) `test/core/theme/app_theme_test.dart`: new group reads `pubspec.yaml` over `dart:io` (package root located by walking up from the CWD — verified empirically that `flutter test` runs with the package root as CWD) and asserts the `fonts:` block declares `Plus Jakarta Sans` (with its asset present on disk) and `Roboto`, and declares no `Google Sans`.
  - **RED proof**: temporarily removing the `Roboto` family entry failed exactly that assertion, and no `TextStyle.fontFamily` check could have caught it.
- [x] F4 Record correction: clean-HEAD baseline is 68/2, not 75/2. Fixed in this file (W8) and in `design.md`.
- [x] F5 `test/presentation/widgets/floating_nav_bar_test.dart`: the comment on `expect(bar.color, _darkSurfaceContainer)` overstated what the assertion proves — pinning a literal cannot distinguish a scheme read from a hardcoded colour. Comment rewritten to claim value pinning only and to point at the `bar.shape`/`bar.elevation` 24/6 assertions, which DO prove derivation. The colour assertion itself is unchanged.
- [x] F6 Spec reconciliation: ASH-010 amended to accept either the explicit `themeMode: ThemeMode.system` / `brightness: Brightness.dark` argument or the Material default, mirroring ASH-011. Both scenarios reworded consistently; the intent (both palettes reachable per platform polarity) is unchanged.
- [x] F7 Gate: `dart format` scoped to the 4 changed Dart files (never `.` — that sweeps 14 unrelated drifted files) → `flutter analyze` → **No issues found!**; `flutter test` → **94 passed / 2 failed** = **+26 net** over the clean-HEAD 68/2, zero new failures. The 2 failures are still only the pre-existing Spanish-label ones.

Net effect of the fix list: 89 → 94 passing (+5 tests: 1 ASH-011 approval, 1 ASH-010 resolved-theme, 3 ASH-002 pubspec declarations), 0 → 2 failures unchanged.

Out of scope: nav bar redesign, `.env`-as-asset, router/screen changes, the `rep_mini` → `MiniBeat` rename. Two reviewer findings about low tonal contrast were escalated rather than actioned at this point: the light centre circle `#DCE7FD` vs bar `#F0ECFA` at 1.0706:1, and the dark bar vs surface at 1.0452:1. Both needed explicit human approval as design re-decisions, so no palette value and no surface-vs-surface contrast assertion was added or changed here. **Both were subsequently approved and resolved — see Phase 7.**

## Phase 7 — Approved contrast corrections

The two escalated findings above were reviewed and approved as explicit design decisions. This is the ONLY work unit that changes a hex value.

- [x] C1 (decision E / D-series row D8) light `secondaryContainer` `#DCE7FD` → **`#BFD2FB`**. Measured against the light bar `#F0ECFA`: the old value gave **1.0706:1** (tonal step essentially invisible), the new gives **1.3079:1**. `onSecondaryContainer` `#0B2A6B` on the new fill measures **8.8764:1**, down from **10.8439:1** on the old — a real reduction in headroom, but both remain far above the 4.5:1 text floor, so no legibility requirement is violated. The token is read only for the nav bar's centre circle. Dark `secondaryContainer` `#1E3A6E` is UNCHANGED.
  - **RED/GREEN proof**: with only `lib/core/theme/app_theme.dart` updated, `flutter test` went **94/2 → 92 passed / 4 failed**. The two new failures were exactly the two literal pins — `app_theme_test.dart` "emits every light token as a literal palette value" and `floating_nav_bar_test.dart` "center circle uses the light container tone, not the accent". Updating the two test oracles returned it to **94/2**. The oracle fired on the value change alone, confirming both pins are real and non-tautological.
  - **Updated literals**: `lib/core/theme/app_theme.dart`, `test/core/theme/app_theme_test.dart`, `test/presentation/widgets/floating_nav_bar_test.dart`, `spec.md` (OPEN Q1 table + rationale), `design.md` (token table, plan, testing-strategy table).
  - **Audit-trail note**: the W1, W4 and W5 task descriptions above still read `#DCE7FD` because that is what those tasks actually asserted and shipped. Rewriting them would falsify the record of what was executed, so they are corrected additively here instead. `test/widget_test.dart` needed no change — it pins `surfaceContainer`, never `secondaryContainer`.
- [x] C2 Fabricated citation withdrawn. `spec.md` justified bar-vs-surface distinctness with "M3's own `surfaceContainer` is 1.14:1 against its `surface`". That number was **invented**. Replaced with the SDK's real measured baselines: dark `#141318` vs `#1D1B20` = **1.0826:1**, light `#FDF7FF` vs `#F3EDF7` = **1.0907:1**. The shipped dark pair `#181833` vs `#14142B` at **1.0452:1** sits slightly below M3's ~1.08:1 step but in the same tonal family — intended, not a defect.
- [x] C3 (decision F / D-series row D9) the dark `surface` `#14142B` is **deliberately NOT changed**. Recorded in `design.md` under "Distinctness by tonal step, not contrast ratio" and cross-referenced from `spec.md`. M3 keeps the `surface`↔`surfaceContainer` and `surface`↔`surfaceContainerLowest` steps roughly equal, so widening one necessarily narrows the other: darkening `surface` to `#101024` would lift bar-vs-surface to 1.0853:1 but drop surface-vs-lowest to 1.0338:1, and `#0D0D1C` would reach 1.1153:1 while collapsing it to **1.0060:1** — visually identical, and it would break the ASH-008 monotonic ladder. Zero-sum trade; a gradient border on the navigation bar is the better mechanism and is a separate, upcoming change.
- [x] C4 Gate: `dart format` scoped to the 3 changed Dart files → `flutter analyze` → **No issues found!**; `flutter test` → **94 passed / 2 failed**, unchanged count, the 2 failures still only the pre-existing Spanish-label ones.

All contrast figures above were re-measured in-session with `Color.computeLuminance()` — the same WCAG relative-luminance function the test suite's contrast helper uses — not carried over from the review.

## Phase 8 — Stale Spanish-label expectations repaired

- [x] G1 `test/presentation/widgets/floating_nav_bar_test.dart`: the 2 failures that had been carried as "pre-existing, not regressions" since the start of this change were a genuine test defect, not an acceptable baseline. Commit `9227fd8` ("fix(ui): navbar labels in Spanish") correctly changed `FloatingNavBar` to render `Historial` / `Música` / `Ajustes` but did not update the test expectations, which still asserted `History` / `Music` / `Settings`. **The widget was right and the test was stale**, so only the test was changed.
  - Updated: 3 `find.text(...)` assertions, the 3 `getTopLeft(find.text(...))` finders, both `find.bySemanticsLabel(...)` lookups, 2 test names, and 4 inline comments naming the destinations.
  - Left alone deliberately: local identifier names (`historyX`, `musicX`, `settingsX`, `history`, `settings`, `historySemantics`, `settingsSemantics`) stay English — identifiers are English by repo convention, and renaming them would be pure diff noise. No colour, token, geometry or theme assertion was touched, and no assertion added by Phases 1–7 was altered.
  - `lib/presentation/widgets/floating_nav_bar.dart` is byte-identical to HEAD: `git status --porcelain` and `git diff --stat` both return nothing for it.
  - The non-ASCII `ú` in `Música` was verified at byte level — valid UTF-8, `ú` = U+00FA present 5× (lines 49, 53, 57, 63, 131), byte pair `C3 BA` correct, zero U+FFFD mojibake characters. A console render of `M? sica` is a PowerShell codepage artifact, not a file defect.
- [x] G2 Gate: `dart format` scoped to that single file (0 changed) → `flutter analyze` → **No issues found!**; `flutter test` → **96 passed / 0 failed. Suite fully green.**

**Final state for W9:** the whole branch is green for the first time — 96/0, zero failures anywhere. The "2 pre-existing failures" caveat recorded in the W8 and C4 gates is now historical, not current.