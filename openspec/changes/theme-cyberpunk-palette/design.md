# Design: Cyberpunk Palette Traceability

`buildAppTheme()` declares every `ColorScheme` token the UI reads, once per brightness; `App` wires both palettes through `ThemeMode.system`. Recorded as D-series rows D6/D7, **not** an ADR — theming is absent from that document's closed 9-item ADR list.

## Technical approach

Two hand-built `ColorScheme`s, each with a complete container ladder and a brightness-specific foreground pair. No new packages, no widget edits, no `ThemeExtension` (D2 precedent).

```
FloatingNavBar ──> surfaceContainer · secondaryContainer · onSecondaryContainer
                  onSurface · onSurfaceVariant · cardTheme.shape · navBar.elevation
                                │ all seven pinned in BOTH schemes
buildAppTheme() ──> _darkScheme | _lightScheme ──> App(theme, darkTheme, ThemeMode.system)
```

## Decisions

| # | Option | Tradeoff | Decision |
|---|--------|----------|----------|
| A2 | `theme` light + `darkTheme` dark + `ThemeMode.system` | +3 lines; light becomes reachable | **Chosen** (ASH-010) |
| B | D-series row vs new ADR | ADR rule has 9 areas; theming is not one | **D-series row** |
| C | Declare light `surfaceContainerLowest` or omit | Declare = no-op; contradicts ASH-011 | **Omit**; pinned by test |
| D | Shared `on*` pair vs per-brightness | Shared saves 2 constants, breaks dark legibility | **Per-brightness** |

## Polarity rule (design constraint)

`on*` tokens are polarity-dependent and MUST be resolved per brightness. **A single shared foreground pair is forbidden.**

| Foreground | DARK | LIGHT | Ratio on bar surface |
|---|---|---|---|
| `onSurface` | `#EDE9FE` | `#1A1636` | 14.53:1 / 14.92:1 |
| `onSurfaceVariant` | `#9A95C8` | `#5E5A85` | 6.17:1 / 5.52:1 |

The working copy shares one pair (`#1A1636` / `#5E5A85`) across both palettes. On the pinned dark bar `#181833` it measures **1.00:1** / **2.69:1** — still **1.08:1** / **2.50:1** on `#1E1E3F`. Both under the 3:1 non-text floor. `FloatingNavBar` paints selected icons with `onSurface`, unselected with `onSurfaceVariant`: invisible icons. Do not re-derive.

## Token table (approved)

| Role | DARK | LIGHT |
|---|---|---|
| `background` | `#0B0B1A` | `#F4F2FF` |
| `surface` | `#14142B` | `#FFFFFF` (M3 default — do NOT redeclare) |
| `surfaceContainerLowest` | `#0C0C1C` | `#FFFFFF` (via `surface` fallback — do NOT redeclare) |
| `surfaceContainerLow` | `#101026` | `#F7F4FD` |
| `surfaceContainer` | `#181833` | `#F0ECFA` |
| `surfaceContainerHigh` | `#1B1B3B` | `#E9E4F6` |
| `surfaceContainerHighest` | `#1E1E3F` | `#E2DCF2` |
| `primary` | `#8B5CF6` | `#6D28D9` |
| `secondary` | `#3B82F6` | `#2563EB` |
| `tertiary` | `#22D3EE` | `#0891B2` |
| `secondaryContainer` | `#1E3A6E` | `#DCE7FD` |
| `onSecondaryContainer` | `#D7E3FF` | `#0B2A6B` |
| `onSurface` | `#EDE9FE` | `#1A1636` |
| `onSurfaceVariant` | `#9A95C8` | `#5E5A85` |
| `error` | `#B91C1C` | `#B91C1C` |

Dark ladder luminance rises monotonically (0.0042 → 0.0156); light falls monotonically (1.0000 → 0.7377).

## Token-pinning strategy

Every token the UI reads is passed explicitly. Verified in `material/color_scheme.dart`: all five `surfaceContainer*` roles fall back to `surface` (L1248, L1254, L1266, L1272, L1278), `secondaryContainer` → `secondary` (L1099), `onSecondaryContainer` → `onSecondary` (L1109). `ColorScheme.light` leaves all five container params null (L786–790), so every container role MUST be declared — except light `surfaceContainerLowest`, whose intended value *is* the `surface` fallback.

## File changes

| File | Action | Description |
|------|--------|-------------|
| `lib/core/theme/app_theme.dart` | Modify | Split foregrounds per brightness; add 11 constants; pass 12 new arguments |
| `lib/app.dart` | Modify | Add `darkTheme:` + `themeMode: ThemeMode.system` |
| `test/core/theme/app_theme_test.dart` | Modify | Pin all 15 tokens by literal value, both brightnesses |
| `test/widget_test.dart` | Modify | Assert the `MaterialApp.router` theme mapping |
| `rep_docs/.../architecture-decisions.md` | Modify | D-series rows D6, D7 |

`lib/presentation/widgets/floating_nav_bar.dart` untouched.

## Apply sequence (2 commits)

**Commit 1 — `docs(sdd):` artifacts + decisions.** `proposal.md`, `specs/app-shell/spec.md`, this `design.md`, `tasks.md`, plus the two `architecture-decisions.md` rows.

**Commit 2 — `fix(theme):` code + tests, TDD.**

1. `app_theme_test.dart`: failing literal-value assertions for all 15 tokens (both brightnesses) + ladder monotonicity.
2. `app_theme.dart`: declare dark `#0C0C1C #101026 #181833 #1B1B3B #1E1E3F` + `#1E3A6E`/`#D7E3FF`; light `#F7F4FD #F0ECFA #E9E4F6 #E2DCF2` + `#DCE7FD`/`#0B2A6B`; split foregrounds into `_darkOnSurface #EDE9FE` / `_darkOnSurfaceVariant #9A95C8`, light keeps `#1A1636` / `#5E5A85`; pass all into both schemes. Do NOT pass light `surface` or `surfaceContainerLowest`.
3. Tests green; `flutter analyze` clean.
4. `test/widget_test.dart`: failing `MaterialApp.router` mapping assertion; then `lib/app.dart`: `theme: buildAppTheme(brightness: Brightness.light)` + `darkTheme: buildAppTheme(brightness: Brightness.dark)` + `themeMode: ThemeMode.system`.

## Testing strategy

The gap: `floating_nav_bar_test.dart` asserts *derivation* (`bar.shape == theme.cardTheme.shape`), which passes against any value — dropping five container tokens produced zero failures. Tests must pin **intended values**.

| Layer | Assertion | Approach |
|---|---|---|
| Unit | 15 tokens per brightness = literal hex | Constants duplicated in the test file; **never** imported from `lib/` (tautological oracle) |
| Unit | Dark ladder rises, light falls | `computeLuminance()` monotonicity over the 5-role order |
| Unit | Dark foregrounds clear 3:1 on `#181833` | Contrast helper over hardcoded hex |
| Widget | Bar surface ≠ Card surface | `bar.color` vs literal `#181833`/`#F0ECFA` |
| Widget | Center circle is a container tone | Decoration color vs literal `#1E3A6E`/`#DCE7FD`, **not** `secondary` |
| Widget | `themeMode` mapping (A2) | Inspect pumped `MaterialApp.router` |

Baseline `flutter test`: 75 pass / 2 pre-existing label failures (`Historial`/`Música`/`Ajustes`). Success = 75 + new, zero new failures.

## Migration / rollout

None. Rollback = revert commit 2; the delta spec applies only at archive.

## Open questions

None — A2 and B resolved; C and D settled here.