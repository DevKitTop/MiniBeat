# App Shell Specification

## Purpose

Defines the compileable app entry point, Material 3 theme, three-branch navigation shell, Riverpod provider scope, and MVVM/Repository-lite folder skeleton for rep_mini. Scaffold only: no playback UI, no real auth flow, no feature implementations. New capability (baseline spec).

## Requirements

### Requirement: ASH-001 App entry

The app MUST provide a `main()` entry that loads configuration, wires a Riverpod `ProviderScope`, and starts a single `MaterialApp.router` instance backed by one go_router router.

#### Scenario: App boots to Local

- GIVEN the app is launched
- WHEN `main()` runs
- THEN `ProviderScope` wraps the routed app and the initial location resolves to `/local`

### Requirement: ASH-002 Material 3 theme and font family

The app theme MUST follow Material Design 3. Plus Jakarta Sans SHALL be the default family — Google Fonts, OFL 1.1, bundled at `assets/fonts/PlusJakartaSans-Variable.ttf`, license at `assets/fonts/PlusJakartaSans-OFL.txt`. Roboto SHALL remain registered as a fallback family. Google Sans SHALL NOT be bundled without a license (caveat documented in the theme source).

#### Scenario: Theme follows Material 3

- GIVEN a widget test pumps the app
- WHEN the theme is inspected
- THEN ThemeData follows Material 3 and the configured Google font family resolves

#### Scenario: Plus Jakarta Sans is default, Roboto is fallback

- GIVEN `buildAppTheme()` and the bundled font assets
- WHEN the text theme is read and the declared families are enumerated
- THEN the styles resolve to family `Plus Jakarta Sans`
- AND `Plus Jakarta Sans` and `Roboto` are both declared, and `Google Sans` is not

### Requirement: ASH-003 Navigation shell

The app MUST use a `StatefulShellRoute.indexedStack` with three branches — `/local`, `/cloud`, `/settings` — each rendering its own placeholder screen and preserving its own navigation state.

#### Scenario: Branch switching preserves state

- GIVEN the app is on `/local`
- WHEN the user switches to `/settings` and back to `/local`
- THEN each branch retains its stack state

### Requirement: ASH-004 Auth gating

The Cloud branch MUST redirect unauthenticated users to a sign-in placeholder route; Local and Settings MUST remain accessible without authentication (BR-003, BR-004).

#### Scenario: Cloud redirects when signed out

- GIVEN the auth provider reports no session
- WHEN the user navigates to `/cloud`
- THEN the router redirects to the sign-in placeholder route

#### Scenario: Local accessible signed out

- GIVEN the auth provider reports no session
- WHEN the user navigates to `/local` or `/settings`
- THEN the route renders without redirect

### Requirement: ASH-005 Riverpod scope

Riverpod providers MUST use the manual Notifier/Provider API only — no codegen and no legacy imports. The scaffold SHALL provide an `AuthSession` provider that defaults to unauthenticated.

#### Scenario: Provider override gates Cloud

- GIVEN a test overrides the auth provider with an authenticated session
- WHEN the router redirect evaluates `/cloud`
- THEN Cloud navigation is permitted

### Requirement: ASH-006 Folder skeleton

`lib/` MUST contain `presentation/features/{local-library,cloud-library,settings}`, `view-models/`, `repositories/`, `services/`, `audio/`, and `data/`; a domain layer SHALL NOT exist.

#### Scenario: Skeleton exists without domain layer

- GIVEN the scaffold is built
- WHEN the `lib/` folder tree is inspected
- THEN all required folders exist and no `domain/` folder exists

### Requirement: ASH-007 Custom floating navigation bar

The app shell MUST provide a custom floating rounded Material 3 navigation bar widget with exactly three destinations in fixed order — History (left), Music (center, prominent), Settings (right) — serving as the visual replacement for the standard `NavigationBar`.

The bar MUST be a pure presentational widget: it SHALL NOT import Riverpod, go_router, auth, or repository code; it MUST consume a `selectedIndex` and expose `onDestinationSelected(int)` so the shell can wire it without adapter changes. The bar SHALL NOT contain a standard `NavigationBar` widget.

The bar MUST derive its colors, shapes, and elevation from `Theme.of(context)` using Material 3 `colorScheme`, `textTheme`, and shape tokens; it MUST NOT use hardcoded color or radius constants.

The destination-to-branch mapping SHALL be documented as a contract — index 0 = `/history`, index 1 = `/music`, index 2 = `/settings` — to prevent index drift when the router is wired in a later slice.

#### Scenario: Renders three destinations with center prominence

- GIVEN the bar is pumped with the app theme and `selectedIndex` 1
- WHEN the bar renders
- THEN exactly three destinations appear in order History, Music, Settings
- AND the center Music destination is visually prominent and no standard `NavigationBar` is in the tree

#### Scenario: Callback reports tapped index

- GIVEN the bar is pumped with an `onDestinationSelected` listener
- WHEN the user taps the Settings destination
- THEN the callback reports index 2

#### Scenario: Theme-derived visuals

- GIVEN the bar is pumped under a Material 3 theme
- WHEN the bar's colors, shape, and elevation are inspected
- THEN they derive from the theme's `colorScheme`/`textTheme`/shape tokens with no hardcoded color or radius constants

#### Scenario: Selected destination is distinct

- GIVEN the bar is pumped with `selectedIndex` 0
- WHEN the bar renders
- THEN the History destination is visually distinct from the unselected destinations

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

