import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/theme/app_theme.dart';

void main() {
  group('app theme (ASH-002)', () {
    test('follows Material 3', () {
      final theme = buildAppTheme();

      expect(theme.useMaterial3, isTrue);
    });

    test('uses Roboto as the default font family', () {
      final theme = buildAppTheme();

      // ThemeData applies `fontFamily` to its text theme styles.
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Roboto');
      expect(theme.textTheme.headlineMedium?.fontFamily, 'Roboto');
    });

    test('provides the floating-nav theme tokens (ASH-007 D2)', () {
      final theme = buildAppTheme();

      // The theme is the single source of truth for the nav bar's container
      // radius and elevation: the widget reads these tokens from
      // Theme.of(context) and must never hardcode its own fallbacks.
      expect(
        theme.cardTheme.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );
      expect(theme.navigationBarTheme.elevation, 3);
    });
  });
}
