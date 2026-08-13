import 'package:flutter/material.dart';

/// Builds the rep_mini Material 3 theme (ASH-002).
///
/// LICENSING CAVEAT: the default family is Roboto (Apache-2.0 / OFL), bundled
/// under `assets/fonts/Roboto-Variable.ttf` with its OFL license. Google Sans
/// is a proprietary font and SHALL NOT be bundled without an explicit license
/// (ASH-002). Swap `fontFamily` here once a licensed font is available.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    fontFamily: 'Roboto',
  );
}
