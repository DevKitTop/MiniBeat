import 'package:flutter/material.dart';

/// Builds the rep_mini Material 3 theme (ASH-002).
///
/// LICENSING CAVEAT: the default family is Roboto (Apache-2.0 / OFL), bundled
/// under `assets/fonts/Roboto-Variable.ttf` with its OFL license. Google Sans
/// is a proprietary font and SHALL NOT be bundled without an explicit license
/// (ASH-002). Swap `fontFamily` here once a licensed font is available.
ThemeData buildAppTheme() {
  // ASH-007 D2: the theme is the single source of truth for the floating nav
  // bar's container radius and elevation. The widget reads these tokens from
  // Theme.of(context) and must never hardcode its own fallbacks.
  const double cardRadius = 12; // M3 Card default corner radius (dp).
  const double navBarElevation = 3; // M3 NavigationBar default elevation.

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    fontFamily: 'Roboto',
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
