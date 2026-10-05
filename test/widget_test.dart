import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/app.dart';
import 'package:rep_mini/core/config/app_config.dart';
import 'package:rep_mini/core/providers/app_providers.dart';
import 'package:rep_mini/core/providers/auth_session_provider.dart';

/// Placeholder config injected in tests (CFG-003: no real values, no secrets).
const _testConfig = AppConfig(
  supabaseUrl: 'https://placeholder.supabase.co',
  anonKey: 'placeholder-anon-key',
);

/// Controller that starts authenticated (ASH-005 scenario override).
class _AuthenticatedController extends AuthSessionController {
  @override
  AuthSession build() => const AuthSession(isAuthenticated: true);
}

Widget _boot({List<Override> overrides = const []}) => ProviderScope(
  overrides: [configProvider.overrideWithValue(_testConfig), ...overrides],
  child: const App(),
);

/// Reads the RESOLVED [Theme] from inside the `MaterialApp` subtree.
///
/// Reading `MaterialApp.theme`/`darkTheme` only inspects the DECLARED slots; it
/// says nothing about which palette Flutter actually SELECTS once `themeMode`
/// and the platform brightness have been applied. ASH-010 is a contract about
/// the theme that reaches the UI, so the probe has to sit below the `Theme`
/// that `MaterialApp` inserts. `NavigationBar` is inside the router's
/// `AppShell`, so it is well below that insertion point.
ThemeData _resolvedTheme(WidgetTester tester) {
  final probe = find.byType(NavigationBar);
  expect(probe, findsOneWidget, reason: 'the shell must render before probing');
  return Theme.of(tester.element(probe));
}

void main() {
  group('App smoke (ASH-001/003/004)', () {
    testWidgets('boots to the local library with the shell (ASH-003)', (
      tester,
    ) async {
      await tester.pumpWidget(_boot());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('Cloud destination redirects unauthenticated users to '
        'sign-in (ASH-004)', (tester) async {
      await tester.pumpWidget(_boot());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to access your cloud library'), findsOneWidget);
      expect(find.text('Cloud library placeholder'), findsNothing);
    });

    testWidgets('authenticated override renders the cloud library (ASH-004)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _boot(
          overrides: [
            authSessionProvider.overrideWith(_AuthenticatedController.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
      expect(find.text('Sign in to access your cloud library'), findsNothing);
    });
  });

  group('theme wiring (ASH-010)', () {
    // MaterialApp resolves `theme` when the effective ThemeMode is light and
    // `darkTheme` when it is dark. Mapping the dark palette to `theme` would
    // hand the dark palette to light-mode users, so the assignment follows the
    // platform polarity, not the palette's aesthetic intensity.
    testWidgets('theme is the light palette, darkTheme the dark palette, '
        'themeMode system', (tester) async {
      await tester.pumpWidget(_boot());
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(app.theme?.brightness, Brightness.light);
      expect(app.darkTheme?.brightness, Brightness.dark);
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('each slot carries the palette for its own brightness '
        '(ASH-010)', (tester) async {
      await tester.pumpWidget(_boot());
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Literal palette values, not read back off the same theme: a swapped
      // assignment would still satisfy a derivation assertion.
      expect(app.theme?.colorScheme.primary, const Color(0xFF6D28D9));
      expect(app.theme?.colorScheme.surfaceContainer, const Color(0xFFF0ECFA));
      expect(app.darkTheme?.colorScheme.primary, const Color(0xFF8B5CF6));
      expect(
        app.darkTheme?.colorScheme.surfaceContainer,
        const Color(0xFF181833),
      );
    });

    // ASH-010 scenario 2. Without this case the suite only ever read the
    // declared slots, so pinning `themeMode: ThemeMode.light` — or any
    // inversion inside Flutter's own resolution — would leave every test green
    // while handing the dark palette to light-mode users. The two assertions
    // use the same test in both directions so the flip is proven, not just each
    // polarity in isolation.
    testWidgets('platform brightness selects the resolved palette end to end '
        '(ASH-010)', (tester) async {
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpWidget(_boot());
      await tester.pumpAndSettle();

      // Literal palette values, not read back off the theme under test.
      expect(
        _resolvedTheme(tester).colorScheme.surfaceContainer,
        const Color(0xFF181833),
        reason: 'dark platform polarity must resolve the dark palette',
      );
      expect(_resolvedTheme(tester).brightness, Brightness.dark);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();

      expect(
        _resolvedTheme(tester).colorScheme.surfaceContainer,
        const Color(0xFFF0ECFA),
        reason: 'light platform polarity must resolve the light palette',
      );
      expect(_resolvedTheme(tester).brightness, Brightness.light);
    });
  });
}
