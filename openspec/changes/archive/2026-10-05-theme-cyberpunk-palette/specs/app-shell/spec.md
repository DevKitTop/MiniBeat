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

Container roles SHALL form a monotonic tonal ladder per brightness, and `surfaceContainer` SHALL NOT equal `surface`. Distinct means a visible tonal step, NOT a WCAG contrast ratio — M3's own tonal steps sit near 1.08:1, measured from the SDK's real baselines: `ColorScheme.dark`'s `surface` `#141318` against its `surfaceContainer` `#1D1B20` is **1.0826:1**, and `ColorScheme.light`'s `#FDF7FF` against `#F3EDF7` is **1.0907:1**. An earlier revision of this spec cited "M3's own `surfaceContainer` is 1.14:1" — that figure was fabricated and is withdrawn. The shipped dark pair (`surfaceContainer` `#181833` against `surface` `#14142B`, **1.0452:1**) sits slightly below that ~1.08:1 reference but in the same tonal family, which is the intended outcome rather than a defect; see the "Distinctness by tonal step, not contrast ratio" decision in `design.md` for why the step was not widened.

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

`MaterialApp.router` SHALL set `theme` to the light palette and `darkTheme` to the dark palette. A palette no user can reach SHALL NOT be shipped as the accessibility variant.

`themeMode` SHALL either be passed `ThemeMode.system` explicitly or left at the `MaterialApp` default, which already IS `ThemeMode.system`. Likewise `darkTheme` SHALL either be passed `buildAppTheme(brightness: Brightness.dark)` explicitly or rely on `buildAppTheme()`'s own `Brightness.dark` default. Both arguments are omitted in the shipped code because restating an existing default trips `avoid_redundant_argument_values` (`analysis_options.yaml:19`) — the same ASH-011 rule that keeps light `surface` unredeclared. Either form satisfies this requirement; what MUST hold is that BOTH palettes stay reachable per platform polarity.

`MaterialApp` resolves `theme` when the effective `ThemeMode` is light and `darkTheme` when it is dark. Mapping the dark palette to `theme` and the light palette to `darkTheme` would hand the dark palette to light-mode users, so the assignment MUST follow the platform polarity rather than the palette's aesthetic intensity.

#### Scenario: Theme mapping is declared

- GIVEN a widget test pumps `App`
- WHEN the `MaterialApp.router` widget is inspected
- THEN `theme.brightness` is light and `darkTheme.brightness` is dark
- AND `themeMode` is `ThemeMode.system`, whether passed explicitly or inherited from the `MaterialApp` default

#### Scenario: System brightness selects the palette

- GIVEN the app is pumped under a dark platform brightness and then under a light one
- WHEN the RESOLVED theme is read from below `MaterialApp` via `Theme.of(context)`, NOT from the declared `theme`/`darkTheme` slots
- THEN `surfaceContainer` is `0xFF181833` under dark polarity and `0xFFF0ECFA` under light polarity

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
| `secondaryContainer` | `#1E3A6E` | `#BFD2FB` |
| `onSecondaryContainer` | `#D7E3FF` | `#0B2A6B` |

Rationale: `secondaryContainer` is a desaturated, low-chroma tint of `secondary` — never the raw accent — matching M3 container semantics. Alternatives: brighter bar (`#1B1B3B` dark / `#EBE5F8` light); violet-tinted dark container (`#2A2350`). Rejected: `surfaceContainer == surface` — violates ASH-008.

Light `secondaryContainer` was revised from `#DCE7FD` to **`#BFD2FB`** (decision E / D-series row D8). Measured against the light bar `surfaceContainer` `#F0ECFA`, `#DCE7FD` gave **1.0706:1** — a tonal step too small to see — while `#BFD2FB` gives **1.3079:1**. The cost is headroom on the centre-circle icon: `onSecondaryContainer` `#0B2A6B` measures **8.8764:1** on `#BFD2FB` against **10.8439:1** on the old value. Both remain far above the 4.5:1 text floor, so no legibility requirement is violated, but the reduction is real and recorded rather than described as free. The token is read only for the nav bar's centre circle; nothing else depends on it.

`onSecondaryContainer` clears WCAG AA on both fills: dark `#D7E3FF` on `#1E3A6E` = 8.66:1, light `#0B2A6B` on `#BFD2FB` = 8.8764:1.

### OPEN Q2 — Dark palette foregrounds fail legibility

With the agreed dark tokens, nav foregrounds are unreadable against the proposed bar surface `#181833`: `onSurface` `#1A1636` → **1.00:1**, `onSurfaceVariant` `#5E5A85` → **2.69:1** (both under the 3:1 non-text minimum; today they sit on `#14142B` at 1.04:1 and 2.81:1). The light palette is fine (`onSurface` 14.92:1, `onSurfaceVariant` 5.52:1 on `#F0ECFA`). Proposed dark alternatives: `onSurface` `#EDE9FE` (14.53:1), `onSurfaceVariant` `#9A95C8` (6.17:1). These two values were already agreed, so the delta does NOT change them silently — a decision is required before apply.