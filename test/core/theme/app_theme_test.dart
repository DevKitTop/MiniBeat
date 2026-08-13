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
  });
}
