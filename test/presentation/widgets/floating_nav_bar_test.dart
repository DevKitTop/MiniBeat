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
const _darkPrimary = Color(0xFF8B5CF6);
const _darkSecondary = Color(0xFF3B82F6); // raw accent, not a fill
const _darkTertiary = Color(0xFF22D3EE);
const _darkSecondaryContainer = Color(0xFF1E3A6E); // center circle fill

const _lightSurface = Color(0xFFFFFFFF);
const _lightSurfaceContainer = Color(0xFFF0ECFA); // bar background
const _lightPrimary = Color(0xFF6D28D9);
const _lightSecondary = Color(0xFF2563EB); // raw accent, not a fill
const _lightTertiary = Color(0xFF0891B2);
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
      final semanticsHandle = tester.ensureSemantics();
      await tester.pumpWidget(_harness(selectedIndex: 1));

      expect(find.bySemanticsLabel('Historial'), findsOneWidget);
      expect(find.bySemanticsLabel('Música'), findsOneWidget);
      expect(find.bySemanticsLabel('Ajustes'), findsOneWidget);

      final historyX = tester.getTopLeft(_destination(0)).dx;
      final musicX = tester.getTopLeft(_destination(1)).dx;
      final settingsX = tester.getTopLeft(_destination(2)).dx;
      expect(historyX, lessThan(musicX));
      expect(musicX, lessThan(settingsX));

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      semanticsHandle.dispose();
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

      final circleBox = tester.widget<Container>(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      final decoration = circleBox.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, _darkSecondaryContainer);
      // A container tone, never the raw accent.
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

      final circleBox = tester.widget<Container>(
        find.byKey(const ValueKey('floating-nav-center-circle')),
      );
      final decoration = circleBox.decoration! as BoxDecoration;

      expect(decoration.color, _lightSecondaryContainer);
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

    testWidgets('bar uses StadiumBorder shape with pinned palette color '
        'and theme elevation (D2)', (tester) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));
      final bar = tester.widget<Material>(
        find.byKey(const ValueKey('floating-nav-bar')),
      );

      // Pinned to the literal palette value, not derived from the scheme.
      expect(bar.color, _darkSurfaceContainer);
      expect(bar.color, isNot(theme.colorScheme.surface));
      expect(bar.color, isNot(_darkSurface));
      // Bar owns its StadiumBorder shape (no longer from cardTheme).
      expect(bar.shape, isA<StadiumBorder>());
      // Elevation is still derived from the theme.
      expect(theme.navigationBarTheme.elevation, isNotNull);
      expect(bar.elevation, theme.navigationBarTheme.elevation);
    });

    testWidgets(
      'light bar uses StadiumBorder with the light container tone (ASH-008)',
      (tester) async {
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
        expect(bar.shape, isA<StadiumBorder>());
        expect(bar.elevation, theme.navigationBarTheme.elevation);
      },
    );

    testWidgets(
      'missing elevation token fails loudly — no hardcoded fallback (D2)',
      (tester) async {
        final nullTokensTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        );
        expect(nullTokensTheme.navigationBarTheme.elevation, isNull);

        await tester.pumpWidget(
          _harness(selectedIndex: 1, theme: nullTokensTheme),
        );
        expect(tester.takeException(), isA<StateError>());
      },
    );

    testWidgets('bar shape is StadiumBorder regardless of cardTheme, '
        'elevation still derived (D2)', (tester) async {
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
      // Shape is the bar's own StadiumBorder, independent of cardTheme.
      expect(bar.shape, isA<StadiumBorder>());
      expect(bar.shape, isNot(customTheme.cardTheme.shape));
      // Elevation is still derived from the theme.
      expect(bar.elevation, customTheme.navigationBarTheme.elevation);
      expect(bar.color, _darkSurfaceContainer);
    });

    testWidgets(
      'selected side destination is visually distinct with filled circle '
      '(ASH-007)',
      (tester) async {
        final semanticsHandle = tester.ensureSemantics();
        await tester.pumpWidget(_harness(selectedIndex: 0));

        final theme = Theme.of(tester.element(find.byType(FloatingNavBar)));

        Icon iconIn(int index) => tester.widget<Icon>(
          find.descendant(of: _destination(index), matching: find.byType(Icon)),
        );

        // Selected Historial uses onSecondaryContainer (on the filled circle);
        // unselected Ajustes stays muted onSurfaceVariant.
        expect(iconIn(0).color, theme.colorScheme.onSecondaryContainer);
        expect(iconIn(2).color, theme.colorScheme.onSurfaceVariant);
        expect(iconIn(0).color, isNot(iconIn(2).color));

        // Selected side has a filled secondaryContainer circle.
        final selectedCircle = tester.widget<Container>(
          find.byKey(const ValueKey('floating-nav-side-circle-0')),
        );
        final selectedDeco = selectedCircle.decoration! as BoxDecoration;
        expect(selectedDeco.shape, BoxShape.circle);
        expect(selectedDeco.color, _darkSecondaryContainer);

        // Unselected side has a transparent circle.
        final unselectedCircle = tester.widget<Container>(
          find.byKey(const ValueKey('floating-nav-side-circle-2')),
        );
        final unselectedDeco = unselectedCircle.decoration! as BoxDecoration;
        expect(unselectedDeco.shape, BoxShape.circle);
        expect(unselectedDeco.color, Colors.transparent);

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
      },
    );

    testWidgets('gradient border uses dark palette accent colors', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(selectedIndex: 1));

      final gradientBox = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('floating-nav-gradient-border')),
      );
      final decoration = gradientBox.decoration as ShapeDecoration;
      expect(decoration.shape, isA<StadiumBorder>());
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, [_darkPrimary, _darkSecondary, _darkTertiary]);
    });

    testWidgets('gradient border uses light palette accent colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          selectedIndex: 1,
          theme: buildAppTheme(brightness: Brightness.light),
        ),
      );

      final gradientBox = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('floating-nav-gradient-border')),
      );
      final decoration = gradientBox.decoration as ShapeDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, [_lightPrimary, _lightSecondary, _lightTertiary]);
    });

    testWidgets(
      'bar has auto width — narrower than available space (floating)',
      (tester) async {
        await tester.pumpWidget(_harness(selectedIndex: 1));

        final barSize = tester.getSize(
          find.byKey(const ValueKey('floating-nav-bar')),
        );
        // Default test surface is 800dp wide; minus 32dp horizontal padding
        // the bar must be narrower than that to float visually.
        expect(barSize.width, lessThan(800 - 32));
      },
    );
  });
}
