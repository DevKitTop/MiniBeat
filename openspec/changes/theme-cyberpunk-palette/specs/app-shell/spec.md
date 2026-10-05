# Delta for app-shell

**Change**: `theme-cyberpunk-palette` — cyberpunk palette traceability.
**Amends**: `openspec/specs/app-shell/spec.md` (ASH-001, ASH-003–ASH-007 unchanged).
Token inventory and open questions below are context, not requirements.

## MODIFIED Requirements

### Requirement: ASH-002 Material 3 theme and font family

The app theme MUST follow Material Design 3. Plus Jakarta Sans SHALL be the default family — Google Fonts, OFL 1.1, bundled at `assets/fonts/PlusJakartaSans-Variable.ttf`, license at `assets/fonts/PlusJakartaSans-OFL.txt`. Roboto SHALL remain registered as a fallback family. Google Sans SHALL NOT be bundled without a license (caveat documented in the theme source).

(Previously: Roboto SHALL be the default family.)

#### Scenario: Theme follows Material 3

- GIVEN a widget test pumps the app
- WHEN the theme is inspected
- THEN ThemeData follows Material 3 and the configured Google font family resolves

#### Scenario: Plus Jakarta Sans is default, Roboto is fallback

- GIVEN `buildAppTheme()` and the bundled font assets
- WHEN the text theme is read and the declared families are enumerated
- THEN the styles resolve to family `Plus Jakarta Sans`
- AND `Plus Jakarta Sans` and `Roboto` are both declared, and `Google Sans` is not

## ADDED Requirements

### Requirement: ASH-008 ColorScheme token pinning

Every `ColorScheme` token read by a presentation widget SHALL be declared explicitly in `buildAppTheme()` for BOTH brightnesses. `FloatingNavBar` paints exactly `surfaceContainer`, `secondaryContainer`, `onSecondaryContainer`, `onSurface`, `onSurfaceVariant`; none MAY be inherited from a Material 3 fallback getter, which silently resolves to `surface`, `secondary`, or `onSecondary` (`color_scheme.dart` L1099, L1109, L1266).

Container roles SHALL form a monotonic tonal ladder per brightness, and `surfaceContainer` SHALL NOT equal `surface`. Distinct means a visible tonal step, NOT a WCAG contrast ratio — M3's own `surfaceContainer` is 1.14:1 against its `surface`.

Assertions SHALL compare tokens against literal palette values; an expected value read from the `ColorScheme` under test is tautological and prohibited.

#### Scenario: Dark tokens are declared, not inherited

- GIVEN `buildAppTheme()` (dark, the default)
- WHEN its color scheme is read
- THEN `surfaceContainer`, `secondaryContainer`, `onSecondaryContainer` each differ from `surface`, `secondary`, `onSecondary`
- AND `surfaceContainer` differs from `surface`

#### Scenario: Light tokens are declared, not inherited

- GIVEN `buildAppTheme(brightness: Brightness.light)`
- WHEN its color scheme is read
- THEN the same three tokens differ from their fallbacks
- AND `surfaceContainer` differs from `surface`

#### Scenario: Container ladder is monotonic

- GIVEN either brightness
- WHEN roles are ordered Lowest → Low → surface → Container → High → Highest
- THEN luminance increases monotonically in dark and decreases monotonically in light

#### Scenario: Bar background is distinct from the Card surface

- GIVEN the bar is pumped under either palette
- WHEN its background color and `colorScheme.surface` are compared
- THEN they are different tones, so the bar does not read as Card content

#### Scenario: Center circle fill is a container tone, not the raw accent

- GIVEN the bar is pumped under either palette
- WHEN the center circle decoration and icon colors are read
- THEN they equal `secondaryContainer`/`onSecondaryContainer`, NOT `secondary`/`onSecondary`

### Requirement: ASH-009 Theme token contract survives both brightnesses

`FloatingNavBar` throws `StateError` when `Theme.cardTheme.shape` or `Theme.navigationBarTheme.elevation` is null. `buildAppTheme()` SHALL set `cardTheme.shape` at radius `12` and `navigationBarTheme.elevation` at `3` outside any brightness conditional, so both palettes satisfy the contract.

#### Scenario: Dark palette satisfies the contract

- GIVEN `buildAppTheme()`
- WHEN the nav tokens are read
- THEN `cardTheme.shape` is a `RoundedRectangleBorder` with radius 12 and `navigationBarTheme.elevation` is 3

#### Scenario: Light palette satisfies the contract

- GIVEN `buildAppTheme(brightness: Brightness.light)`
- WHEN the nav tokens are read
- THEN radius is 12 and elevation is 3, equal to the dark palette, not merely non-null

### Requirement: ASH-010 Both cyberpunk palettes are reachable

`MaterialApp.router` SHALL set `theme` to the dark palette, `darkTheme` to the light palette, and `themeMode: ThemeMode.system`. A palette no user can reach SHALL NOT be shipped as the accessibility variant.

#### Scenario: Theme mapping is declared

- GIVEN a widget test pumps `App`
- WHEN the `MaterialApp.router` widget is inspected
- THEN `theme.brightness` is dark, `darkTheme.brightness` is light, `themeMode` is `ThemeMode.system`

#### Scenario: System brightness selects the palette

- GIVEN the bar theme resolves once per platform brightness
- WHEN the platform brightness is dark and then light
- THEN the dark palette is used and then the light palette is used

### Requirement: ASH-011 Material 3 defaults are not redeclared

Where a value is already the Material 3 default, `buildAppTheme()` SHALL NOT redeclare it. Light `surface` SHALL be left at the `ColorScheme.light` default (white) and pinned by value in `app_theme_test.dart`; redeclaring `surface: Color(0xFFFFFFFF)` trips `avoid_redundant_argument_values` (`analysis_options.yaml:19`).

#### Scenario: White light surface is inherited and pinned by test

- GIVEN `buildAppTheme(brightness: Brightness.light)`
- WHEN its color scheme is read and `flutter analyze` runs
- THEN `surface` equals `Colors.white` with no explicit argument in `buildAppTheme()`
- AND no `avoid_redundant_argument_values` diagnostic is reported

---

## Token inventory (context)

| Token read by the UI | Dark | Light | Today |
|---|---|---|---|
| `surfaceContainer` (bar background) | **OPEN Q1** | **OPEN Q1** | falls back to `surface` |
| `secondaryContainer` (pill, center fill) | **OPEN Q1** | **OPEN Q1** | falls back to `secondary` |
| `onSecondaryContainer` (center icon) | **OPEN Q1** | **OPEN Q1** | falls back to `onSecondary` (near black) |
| `surfaceContainerLowest/Low/High` | **OPEN Q1** | **OPEN Q1** | fall back to `surface` |
| `surfaceContainerHighest` | `#1E1E3F` | **OPEN Q1** | dark only |
| `onSurface` | `#1A1636` | `#1A1636` | declared — see OPEN Q2 |
| `onSurfaceVariant` | `#5E5A85` | `#5E5A85` | declared — see OPEN Q2 |
| `surface` | `#14142B` | `#FFFFFF` (M3 default) | declared / inherited (ASH-011) |
| `secondary` (accent, not a fill) | `#3B82F6` | `#2563EB` | declared |
| `primary` / `tertiary` / `error` / `surfaceTint` | declared | declared | declared |
| `scaffoldBackgroundColor` | `#0B0B1A` | `#F4F2FF` | declared |
| `cardTheme.shape` / `navigationBarTheme.elevation` | 12 / 3 | 12 / 3 | declared (ASH-009) |

## Open questions — MUST be resolved before apply

### OPEN Q1 — Undecided container and `secondaryContainer` values

The `surfaceContainer*` ladder plus `secondaryContainer` / `onSecondaryContainer` are NOT decided for either brightness. Proposed values (monotonic luminance verified; contrast measured against `surface`):

| Role | DARK proposed | LIGHT proposed |
|---|---|---|
| `surfaceContainerLowest` | `#0C0C1C` | `#FFFFFF` (= `surface`, M3 default) |
| `surfaceContainerLow` | `#101026` | `#F7F4FD` |
| `surfaceContainer` | `#181833` | `#F0ECFA` |
| `surfaceContainerHigh` | `#1B1B3B` | `#E9E4F6` |
| `surfaceContainerHighest` | `#1E1E3F` (agreed) | `#E2DCF2` |
| `secondaryContainer` | `#1E3A6E` | `#DCE7FD` |
| `onSecondaryContainer` | `#D7E3FF` | `#0B2A6B` |

Rationale: `secondaryContainer` is a desaturated, low-chroma tint of `secondary` — never the raw accent — matching M3 container semantics; `onSecondaryContainer` clears WCAG AA (dark 8.66:1, light 10.84:1). Alternatives: brighter bar (`#1B1B3B` dark / `#EBE5F8` light); violet-tinted dark container (`#2A2350`). Rejected: `surfaceContainer == surface` — violates ASH-008.

### OPEN Q2 — Dark palette foregrounds fail legibility

With the agreed dark tokens, nav foregrounds are unreadable against the proposed bar surface `#181833`: `onSurface` `#1A1636` → **1.00:1**, `onSurfaceVariant` `#5E5A85` → **2.69:1** (both under the 3:1 non-text minimum; today they sit on `#14142B` at 1.04:1 and 2.81:1). The light palette is fine (`onSurface` 14.92:1, `onSurfaceVariant` 5.52:1 on `#F0ECFA`). Proposed dark alternatives: `onSurface` `#EDE9FE` (14.53:1), `onSurfaceVariant` `#9A95C8` (6.17:1). These two values were already agreed, so the delta does NOT change them silently — a decision is required before apply.