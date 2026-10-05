import 'package:flutter/material.dart';

/// Builds the rep_mini cyberpunk theme (ASH-002).
///
/// Dark is the default experience (the primary aesthetic); the light palette is
/// a softened lavender variant for accessibility.
///
/// Font: **Plus Jakarta Sans** (Google Fonts, OFL) — bundled at
/// `assets/fonts/PlusJakartaSans-Variable.ttf` with its OFL license at
/// `assets/fonts/PlusJakartaSans-OFL.txt`. `Roboto` remains registered as a
/// fallback family.
///
/// This function is the single source of truth for the floating nav bar's
/// container radius and elevation (ASH-007 D2): the widget reads those tokens
/// from `Theme.of(context)` and must never hardcode its own fallbacks. Both
/// brightnesses therefore MUST keep [cardRadius] and [navBarElevation] set, or
/// `FloatingNavBar` throws a `StateError`.
///
/// Token policy (ASH-008):
/// - Every `ColorScheme` token the UI reads is passed EXPLICITLY. M3 silently
///   falls back to `surface`, `secondary` or `onSecondary` when a token is
///   omitted, which collapses the bar onto the Card panel and the center circle
///   onto the raw accent.
/// - The `on*` foregrounds are polarity-dependent and are resolved per
///   brightness. A single shared pair is forbidden: it makes the dark bar
///   illegible.
/// - Where a value already IS the M3 default, it is not redeclared (ASH-011).
///   Light `surface` stays at `ColorScheme.light`'s white, light
///   `surfaceContainerLowest` stays at its `surface` fallback, and `surfaceTint`
///   stays at `ColorScheme`'s `primary` fallback — passing `surfaceTint: primary`
///   would only restate `surfaceTint => _surfaceTint ?? primary`. All three are
///   pinned by value in `test/core/theme/app_theme_test.dart` so the omissions
///   stay deliberate rather than accidental.
ThemeData buildAppTheme({Brightness brightness = Brightness.dark}) {
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Plus Jakarta Sans',
    colorScheme: isDark ? _darkScheme : _lightScheme,
    scaffoldBackgroundColor: isDark ? _darkBackground : _lightBackground,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      elevation: navBarElevation,
    ),
  );
}

/// M3 Card default corner radius (dp). Consumed by `FloatingNavBar` (ASH-007).
const double cardRadius = 12;

/// M3 NavigationBar default elevation. Consumed by `FloatingNavBar` (ASH-007).
const double navBarElevation = 3;

// ── Cyberpunk palette ───────────────────────────────────────────────────────
// Design tokens. Deliberately explicit rather than derived from a seed color:
// `ColorScheme.fromSeed` cannot produce these exact surfaces and accents.

const Color _darkBackground = Color(0xFF0B0B1A); // deep space navy
const Color _darkSurface = Color(0xFF14142B); // raised panel

// Dark container ladder, Lowest → Highest (monotonic in luminance).
const Color _darkSurfaceContainerLowest = Color(0xFF0C0C1C);
const Color _darkSurfaceContainerLow = Color(0xFF101026);
const Color _darkSurfaceContainer = Color(0xFF181833); // nav bar background
const Color _darkSurfaceContainerHigh = Color(0xFF1B1B3B);
const Color _darkSurfaceVariant = Color(0xFF1E1E3F); // highest container

const Color _darkPrimary = Color(0xFF8B5CF6); // violet neon
const Color _darkSecondary = Color(0xFF3B82F6); // electric blue
const Color _darkTertiary = Color(0xFF22D3EE); // cyan neon

// `secondaryContainer` is a desaturated tint of the accent, never the accent
// itself (M3 container semantics).
const Color _darkSecondaryContainer = Color(0xFF1E3A6E);
const Color _darkOnSecondaryContainer = Color(0xFFD7E3FF);

const Color _lightBackground = Color(0xFFF4F2FF); // soft lavender
// Light panels are the M3 default (`ColorScheme.light` already uses
// `Colors.white`), so `surface` is not redeclared below. Light
// `surfaceContainerLowest` is likewise left at its `surface` fallback. Both
// are pinned by `test/core/theme/app_theme_test.dart` (ASH-011).

// Light container ladder, Lowest → Highest (monotonic in luminance).
const Color _lightSurfaceContainerLow = Color(0xFFF7F4FD);
const Color _lightSurfaceContainer = Color(0xFFF0ECFA); // nav bar background
const Color _lightSurfaceContainerHigh = Color(0xFFE9E4F6);
const Color _lightSurfaceContainerHighest = Color(0xFFE2DCF2);

const Color _lightPrimary = Color(0xFF6D28D9); // deep violet
const Color _lightSecondary = Color(0xFF2563EB); // strong blue
const Color _lightTertiary = Color(0xFF0891B2); // deep cyan

const Color _lightSecondaryContainer = Color(0xFFBFD2FB);
const Color _lightOnSecondaryContainer = Color(0xFF0B2A6B);

// Foregrounds are polarity-dependent: resolved per brightness, never shared.
const Color _darkOnSurface = Color(0xFFEDE9FE); // pale lavender
const Color _darkOnSurfaceVariant = Color(0xFF9A95C8); // muted lavender
const Color _lightOnSurface = Color(0xFF1A1636); // near-black indigo
const Color _lightOnSurfaceVariant = Color(0xFF5E5A85); // muted indigo

const Color _error = Color(0xFFB91C1C);

final ColorScheme _darkScheme = ColorScheme.dark(
  primary: _darkPrimary,
  secondary: _darkSecondary,
  tertiary: _darkTertiary,
  surface: _darkSurface,
  surfaceContainerLowest: _darkSurfaceContainerLowest,
  surfaceContainerLow: _darkSurfaceContainerLow,
  surfaceContainer: _darkSurfaceContainer,
  surfaceContainerHigh: _darkSurfaceContainerHigh,
  surfaceContainerHighest: _darkSurfaceVariant,
  secondaryContainer: _darkSecondaryContainer,
  onSecondaryContainer: _darkOnSecondaryContainer,
  onSurface: _darkOnSurface,
  onSurfaceVariant: _darkOnSurfaceVariant,
  error: _error,
);

final ColorScheme _lightScheme = ColorScheme.light(
  primary: _lightPrimary,
  secondary: _lightSecondary,
  tertiary: _lightTertiary,
  surfaceContainerLow: _lightSurfaceContainerLow,
  surfaceContainer: _lightSurfaceContainer,
  surfaceContainerHigh: _lightSurfaceContainerHigh,
  surfaceContainerHighest: _lightSurfaceContainerHighest,
  secondaryContainer: _lightSecondaryContainer,
  onSecondaryContainer: _lightOnSecondaryContainer,
  onSurface: _lightOnSurface,
  onSurfaceVariant: _lightOnSurfaceVariant,
  error: _error,
);
