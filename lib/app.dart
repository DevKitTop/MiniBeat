import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';

/// Root widget: wires the router and theme (ASH-001).
///
/// Configuration is injected through [configProvider] by `main()`; tests
/// override it with a fake [AppConfig].
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'rep_mini',
      // ASH-010: both palettes are reachable, one per platform polarity.
      // `MaterialApp` resolves `theme` when the effective ThemeMode is light
      // and `darkTheme` when it is dark, so the light palette goes in `theme`
      // and the dark one in `darkTheme` — NOT the other way round.
      //
      // `darkTheme` and `themeMode` are left at their Material defaults
      // (`buildAppTheme` already defaults to `Brightness.dark`, and
      // `MaterialApp.themeMode` is already `ThemeMode.system`) per ASH-011 —
      // redeclaring a default only trips `avoid_redundant_argument_values`.
      // Both are pinned by value in `test/widget_test.dart`.
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
