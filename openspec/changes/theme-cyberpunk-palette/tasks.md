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

- [ ] W1 (RED) `test/core/theme/app_theme_test.dart`: add a second const block mirroring design.md token table for BOTH brightnesses — do NOT import from `lib/`. Assert 15 tokens as literal hex each: dark `background 0xFF0B0B1A`(scaffold), `surface 0xFF14142B`, `surfaceContainerLowest 0xFF0C0C1C`, `Low 0xFF101026`, `surfaceContainer 0xFF181833`, `High 0xFF1B1B3B`, `Highest 0xFF1E1E3F`, `primary 0xFF8B5CF6`, `secondary 0xFF3B82F6`, `tertiary 0xFF22D3EE`, `secondaryContainer 0xFF1E3A6E`, `onSecondaryContainer 0xFFD7E3FF`, `onSurface 0xFFEDE9FE`, `onSurfaceVariant 0xFF9A95C8`, `error 0xFFB91C1C`; light `background 0xFFF4F2FF`, `surface 0xFFFFFFFF`, `Low 0xFFF7F4FD`, `surfaceContainer 0xFFF0ECFA`, `High 0xFFE9E4F6`, `Highest 0xFFE2DCF2`, `primary 0xFF6D28D9`, `secondary 0xFF2563EB`, `tertiary 0xFF0891B2`, `secondaryContainer 0xFFDCE7FD`, `onSecondaryContainer 0xFF0B2A6B`, `onSurface 0xFF1A1636`, `onSurfaceVariant 0xFF5E5A85`, `error 0xFFB91C1C`. Pass: fails on missing container tokens + dark foregrounds.
- [ ] W2 (RED) same file: ladder monotonicity — `computeLuminance()` over Lowest→Low→surfaceContainer→High→Highest strictly increases (dark) / strictly decreases (light). Pass: fails now.
- [ ] W3 (RED) same file: contrast helper over hardcoded hex — `onSurface 0xFFEDE9FE` and `onSurfaceVariant 0xFF9A95C8` each ≥ 3.0:1 against `0xFF181833`. Pass: fails (1.08:1 / 2.69:1 today).

## Phase 2 — Unit GREEN

- [ ] W4 (GREEN) `lib/core/theme/app_theme.dart`: add 11 consts and pass them into both schemes. Dark: `surfaceContainerLowest 0xFF0C0C1C`, `Low 0xFF101026`, `surfaceContainer 0xFF181833`, `High 0xFF1B1B3B`, `Highest 0xFF1E1E3F` (reuse existing `_darkSurfaceVariant`), `secondaryContainer 0xFF1E3A6E`, `onSecondaryContainer 0xFFD7E3FF`. Light: `Low 0xFFF7F4FD`, `surfaceContainer 0xFFF0ECFA`, `High 0xFFE9E4F6`, `Highest 0xFFE2DCF2`, `secondaryContainer 0xFFDCE7FD`, `onSecondaryContainer 0xFF0B2A6B`. Rename shared `_onSurface`/`_onSurfaceVariant` to per-brightness `_darkOnSurface 0xFFEDE9FE` / `_darkOnSurfaceVariant 0xFF9A95C8` / `_lightOnSurface 0xFF1A1636` / `_lightOnSurfaceVariant 0xFF5E5A85`. Do NOT pass light `surface` or light `surfaceContainerLowest` (Decision C; `avoid_redundant_argument_values`, `analysis_options.yaml:19`). Keep `cardTheme.shape` radius 12 and `navigationBarTheme.elevation` 3 outside the brightness branch. Pass: W1–W3 green.

## Phase 3 — Widget intent

- [ ] W5 (GREEN) `test/presentation/widgets/floating_nav_bar_test.dart`: replace the derivation-only checks with literal ones — bar `Material.color` equals `0xFF181833` (dark) / `0xFFF0ECFA` (light) and differs from `colorScheme.surface`; center circle `BoxDecoration.color` equals `0xFF1E3A6E` / `0xFFDCE7FD` and is NOT `colorScheme.secondary`. Pass: green without touching `floating_nav_bar.dart`.

## Phase 4 — A2 wiring

- [ ] W6 (RED) `test/widget_test.dart`: pump `_boot()`, read the `MaterialApp.router` widget — `theme.brightness == Brightness.light`, `darkTheme.brightness == Brightness.dark`, `themeMode == ThemeMode.system`. Also assert the resolved scheme colours follow that polarity: `theme.colorScheme.primary == 0xFF6D28D9` (light primary) and `darkTheme.colorScheme.primary == 0xFF8B5CF6` (dark primary). Pass: fails (`darkTheme`/`themeMode` null today).
  - Rationale: `MaterialApp` selects `theme` when `ThemeMode` resolves to light and `darkTheme` when it resolves to dark. Wiring `theme: dark` + `darkTheme: light` would hand the dark palette to light-mode users, inverting A2.
- [ ] W7 (GREEN) `lib/app.dart`: on the existing `MaterialApp.router` add `darkTheme: buildAppTheme(brightness: Brightness.dark)` and `themeMode: ThemeMode.system`, and change the existing `theme:` to `buildAppTheme(brightness: Brightness.light)`. Pass: W6 green.

## Phase 5 — Gate + commit

- [ ] W8 `dart format .` then `flutter analyze` → `No issues found!` then `flutter test` → 75 + new passing, ZERO new failures. The 2 pre-existing failures in `floating_nav_bar_test.dart` (`Historial`/`Música`/`Ajustes` vs asserted `History`/`Settings`) stay untouched — not regressions.
- [ ] W9 Commit all as one work unit (`feat(theme): pin cyberpunk palette tokens for both brightnesses`), tests with the code they cover, no AI attribution. Include `lib/core/theme/app_theme.dart`, `lib/app.dart`, `test/core/theme/app_theme_test.dart`, `test/presentation/widgets/floating_nav_bar_test.dart`, `test/widget_test.dart`, `pubspec.yaml`, `assets/fonts/PlusJakartaSans-*`, this file.

Out of scope: nav bar redesign, `.env`-as-asset, router/screen changes, the `rep_mini` → `MiniBeat` rename.