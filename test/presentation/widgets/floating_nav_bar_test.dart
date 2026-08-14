import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/theme/app_theme.dart';
import 'package:rep_mini/presentation/widgets/floating_nav_bar.dart';

/// Harness: pure widget, no ProviderScope, no router (ASH-007).
Widget _harness({
  required int selectedIndex,
  ValueChanged<int>? onDestinationSelected,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? buildAppTheme(),
    home: Scaffold(
      body: const SizedBox.expand(),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected ?? (_) {},
      ),
    ),
  );
}

Finder _destination(int index) =>
    find.byKey(ValueKey('floating-nav-destination-$index'));

void main() {
  group('FloatingNavBar (ASH-007)', () {
    testWidgets('renders exactly three destinations in order '
        'History, Music, Settings', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      final historyX = tester.getTopLeft(find.text('History')).dx;
      final musicX = tester.getTopLeft(find.text('Music')).dx;
      final settingsX = tester.getTopLeft(find.text('Settings')).dx;
      expect(historyX, lessThan(musicX));
      expect(musicX, lessThan(settingsX));
    });

    testWidgets('center Music destination is visually prominent '
        '(D3: larger filled circle)', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      final center = tester.getSize(_destination(1));
      final history = tester.getSize(_destination(0));
      final settings = tester.getSize(_destination(2));
      expect(center.height, greaterThan(history.height));
      expect(center.height, greaterThan(settings.height));

      // The prominent element is a ~56dp circular slot (D3).
      final circle = tester.getSize(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      expect(circle.width, circle.height);

      // Tonal prominence: the circle uses secondaryContainer (D2/D3).
      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final circleBox = tester.widget<Container>(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      final decoration = circleBox.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, theme.colorScheme.secondaryContainer);
    });

    testWidgets('does not contain a standard NavigationBar', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('tapping a destination reports its index via callback', (
      tester,
    ) async {
      var reported = -1;
      await tester.pumpWidget(
        _harness(selectedIndex: 0, onDestinationSelected: (i) => reported = i),
      );

      await tester.tap(_destination(2)); // Settings
      expect(reported, 2);
      await tester.tap(_destination(0)); // History
      expect(reported, 0);
      await tester.tap(_destination(1)); // Music
      expect(reported, 1);
    });

    testWidgets('bar color, shape, and elevation derive from theme tokens '
        '(D2)', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final bar = tester.widget<Material>(
        find.byKey(const ValueKey('floating-nav-bar')),
      );

      expect(bar.color, theme.colorScheme.surfaceContainer);
      // The app theme (buildAppTheme) provides the M3 tokens — card radius 12
      // and elevation 3 — and the bar reads them directly, with no hardcoded
      // fallback values.
      expect(theme.cardTheme.shape, isNotNull);
      expect(theme.navigationBarTheme.elevation, isNotNull);
      expect(bar.shape, theme.cardTheme.shape);
      expect(bar.elevation, theme.navigationBarTheme.elevation);
    });

    testWidgets('missing theme tokens fail loudly — no hardcoded fallback '
        '(D2)', (tester) async {
      final nullTokensTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      // Premise: ThemeData leaves these tokens null unless explicitly set —
      // the bar must not silently substitute hardcoded 12/3 values.
      expect(nullTokensTheme.cardTheme.shape, isNull);
      expect(nullTokensTheme.navigationBarTheme.elevation, isNull);

      await tester.pumpWidget(
        _harness(selectedIndex: 1, theme: nullTokensTheme),
      );
      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('bar honors explicitly themed shape and elevation '
        '(D2 derivation proof)', (tester) async {
      final customTheme = buildAppTheme().copyWith(
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(elevation: 6),
      );
      await tester.pumpWidget(_harness(selectedIndex: 1, theme: customTheme));

      final bar = tester.widget<Material>(
        find.byKey(const ValueKey('floating-nav-bar')),
      );
      expect(bar.shape, customTheme.cardTheme.shape);
      expect(bar.elevation, customTheme.navigationBarTheme.elevation);
      expect(bar.color, customTheme.colorScheme.surfaceContainer);
    });

    testWidgets('selected destination is visually distinct (ASH-007)', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(selectedIndex: 0));

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));

      Icon iconIn(int index) => tester.widget<Icon>(
        find.descendant(of: _destination(index), matching: find.byType(Icon)),
      );

      // Selected History uses the emphasized onSurface color; unselected
      // Settings stays muted onSurfaceVariant (D2).
      expect(iconIn(0).color, theme.colorScheme.onSurface);
      expect(iconIn(2).color, theme.colorScheme.onSurfaceVariant);
      expect(iconIn(0).color, isNot(iconIn(2).color));

      // Semantics marks the selected destination (a11y contract).
      final historySemantics = tester.getSemantics(
        find.bySemanticsLabel('History'),
      );
      expect(historySemantics.flagsCollection.isSelected, Tristate.isTrue);
      final settingsSemantics = tester.getSemantics(
        find.bySemanticsLabel('Settings'),
      );
      expect(settingsSemantics.flagsCollection.isSelected, Tristate.isFalse);
      semanticsHandle.dispose();
    });
  });
}
