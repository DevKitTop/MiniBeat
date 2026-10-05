## Archive Report — theme-cyberpunk-palette

**Change**: theme-cyberpunk-palette — cyberpunk palette traceability
**Archived to**: `openspec/changes/archive/2026-10-05-theme-cyberpunk-palette/`
**Date**: 2026-10-05
**Branch**: `feature/nav-shell-router`
**Status**: ✅ ARCHIVED — PASS

### Summary

The `theme-cyberpunk-palette` change finalized the Material 3 design tokens for dark and light brightnesses based on the cyberpunk palette. It registered Plus Jakarta Sans as the bundled primary font, wired both palettes into `MaterialApp.router` with system brightness support (ASH-010), fixed dark foreground legibility on navigation components (ASH-008), resolved light mode center-circle tonal contrast, and brought the full test suite to 96 passing tests with zero analyzer warnings.

### What was implemented

| Area | Deliverable |
|------|-------------|
| Theme | `lib/core/theme/app_theme.dart` — explicit cyberpunk ColorScheme tokens for dark & light, Plus Jakarta Sans typography, container ladder |
| App Wiring | `lib/app.dart` — `theme` (light) and `darkTheme` (dark) wired into `MaterialApp.router` |
| Assets | `assets/fonts/PlusJakartaSans-Variable.ttf` + `assets/fonts/PlusJakartaSans-OFL.txt` |
| Tests | `test/core/theme/app_theme_test.dart`, `test/presentation/widgets/floating_nav_bar_test.dart`, `test/widget_test.dart` |
| Specs | `openspec/specs/app-shell/spec.md` updated with ASH-002, ASH-008, ASH-009, ASH-010, ASH-011 |

### Verification Evidence

- `flutter test`: **96/96 passed**, 0 failed
- `flutter analyze`: **No issues found!**
- Spec sync: `openspec/specs/app-shell/spec.md` updated and synchronized.

### Decisions Made

- Decisions A2, B, C, D, E, F documented and recorded in `rep_docs/music_app_docs/technical/architecture-decisions.md` (D-series).
- Dark surface kept at `#14142B` to preserve monotonic tonal ladder; separation of navbar from surface to be handled via gradient border in the upcoming navbar change.
