import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/theme/app_theme.dart';
import 'package:rep_mini/presentation/widgets/floating_nav_bar.dart';

/// Expected cyberpunk palette (ASH-008).
///
/// Duplicated from the design token table on purpose: an expected value read
/// back out of the `ColorScheme` under test is a tautological oracle — it passes
/// against any value the theme builder emits, which is how five container tokens
/// went missing without a single red test.
const _darkSurface = Color(0xFF14142B);
const _darkSurfaceContainer = Color(0xFF181833); // bar background
const _darkSecondary = Color(0xFF3B82F6); // raw accent, not a fill
const _darkSecondaryContainer = Color(0xFF1E3A6E); // center circle fill

const _lightSurface = Color(0xFFFFFFFF);
const _lightSurfaceContainer = Color(0xFFF0ECFA); // bar background
const _lightSecondary = Color(0xFF2563EB); // raw accent, not a fill
const _lightSecondaryContainer = Color(0xFFBFD2FB); // center circle fill

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
        'Historial, Música, Ajustes', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      expect(find.text('Historial'), findsOneWidget);
      expect(find.text('Música'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);

      final historyX = tester.getTopLeft(find.text('Historial')).dx;
      final musicX = tester.getTopLeft(find.text('Música')).dx;
      final settingsX = tester.getTopLeft(find.text('Ajustes')).dx;
      expect(historyX, lessThan(musicX));
      expect(musicX, lessThan(settingsX));
    });

    testWidgets('center Música destination is visually prominent '
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

      // Tonal prominence: the circle uses secondaryContainer (D2/D3), pinned to
      // a literal palette value rather than read back off the ColorScheme.
      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final circleBox = tester.widget<Container>(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      final decoration = circleBox.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, _darkSecondaryContainer);
      // A container tone, never the raw accent.
      expect(decoration.color, isNot(theme.colorScheme.secondary));
      expect(decoration.color, isNot(_darkSecondary));
    });

    testWidgets('center circle uses the light container tone, not the accent '
        '(ASH-008)', (tester) async {
      await tester.pumpWidget(
        _harness(
          selectedIndex: 1,
          theme: buildAppTheme(brightness: Brightness.light),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final circleBox = tester.widget<Container>(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      final decoration = circleBox.decoration! as BoxDecoration;

      expect(decoration.color, _lightSecondaryContainer);
      expect(decoration.color, isNot(theme.colorScheme.secondary));
      expect(decoration.color, isNot(_lightSecondary));
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

      await tester.tap(_destination(2)); // Ajustes
      expect(reported, 2);
      await tester.tap(_destination(0)); // Historial
      expect(reported, 0);
      await tester.tap(_destination(1)); // Música
      expect(reported, 1);
    });

    testWidgets('bar color, shape, and elevation come from the pinned palette '
        'and theme tokens (D2)', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final bar = tester.widget<Material>(
        find.byKey(const ValueKey('floating-nav-bar')),
      );

      // Pinned to the literal palette value, not derived from the scheme: the
      // bar must read surfaceContainer, not an inherited `surface` fallback.
      expect(bar.color, _darkSurfaceContainer);
      // A distinct tonal step from the Card panel, so the bar never reads as
      // Card content (ASH-008).
      expect(bar.color, isNot(theme.colorScheme.surface));
      expect(bar.color, isNot(_darkSurface));
      // The app theme (buildAppTheme) provides the M3 tokens — card radius 12
      // and elevation 3 — and the bar reads them directly, with no hardcoded
      // fallback values.
      expect(theme.cardTheme.shape, isNotNull);
      expect(theme.navigationBarTheme.elevation, isNotNull);
      expect(bar.shape, theme.cardTheme.shape);
      expect(bar.elevation, theme.navigationBarTheme.elevation);
    });

    testWidgets('light bar uses the light container tone, distinct from the '
        'light Card surface (ASH-008)', (tester) async {
      await tester.pumpWidget(
        _harness(
          selectedIndex: 1,
          theme: buildAppTheme(brightness: Brightness.light),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final bar = tester.widget<Material>(
        find.byKey(const ValueKey('floating-nav-bar')),
      );

      expect(bar.color, _lightSurfaceContainer);
      expect(bar.color, isNot(theme.colorScheme.surface));
      expect(bar.color, isNot(_lightSurface));
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
      // Derivation is proven by the pair above, NOT by this line: 24 and 6 are
      // neither the theme's 12 nor its 3, so the bar can only have taken them
      // from `Theme.of(context)`. This assertion pins the colour the scheme
      // resolves to after `copyWith` — on its own it cannot tell a scheme read
      // apart from a widget hardcoding `0xFF181833`, so it is value pinning,
      // not a derivation proof.
      expect(bar.color, _darkSurfaceContainer);
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

      // Selected Historial uses the emphasized onSurface color; unselected
      // Ajustes stays muted onSurfaceVariant (D2).
      expect(iconIn(0).color, theme.colorScheme.onSurface);
      expect(iconIn(2).color, theme.colorScheme.onSurfaceVariant);
      expect(iconIn(0).color, isNot(iconIn(2).color));

      // Semantics marks the selected destination (a11y contract).
      final historySemantics = tester.getSemantics(
        find.bySemanticsLabel('Historial'),
      );
      expect(historySemantics.flagsCollection.isSelected, Tristate.isTrue);
      final settingsSemantics = tester.getSemantics(
        find.bySemanticsLabel('Ajustes'),
      );
      expect(settingsSemantics.flagsCollection.isSelected, Tristate.isFalse);
      semanticsHandle.dispose();
    });
  });
}
