import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/providers/app_providers.dart';
import 'package:rep_mini/core/providers/auth_session_provider.dart';
import 'package:rep_mini/core/theme/app_theme.dart';
import 'package:rep_mini/presentation/widgets/floating_nav_bar.dart';

/// A controller that starts authenticated (ASH-005 scenario override).
class _AuthenticatedController extends AuthSessionController {
  @override
  AuthSession build() => const AuthSession(isAuthenticated: true);
}

Widget _harness(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    theme: buildAppTheme(),
    routerConfig: container.read(routerProvider),
  ),
);

void main() {
  group('App shell and router (ASH-003/004)', () {
    testWidgets('shell renders three destinations and boots /local', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingNavBar), findsOneWidget);
      expect(find.bySemanticsLabel('Historial'), findsOneWidget);
      expect(find.bySemanticsLabel('Música'), findsOneWidget);
      expect(find.bySemanticsLabel('Ajustes'), findsOneWidget);
      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('branch state survives switching away and back (ASH-003)', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings placeholder'), findsOneWidget);

      router.go('/local');
      await tester.pumpAndSettle();
      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('/cloud redirects unauthenticated users to sign-in (ASH-004)', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/cloud');
      await tester.pumpAndSettle();

      expect(find.text('Sign in to access your cloud library'), findsOneWidget);
      expect(find.text('Cloud library placeholder'), findsNothing);
    });

    testWidgets('/local and /settings render while signed out (ASH-004)', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings placeholder'), findsOneWidget);

      router.go('/local');
      await tester.pumpAndSettle();
      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('root path redirects to /local', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/');
      await tester.pumpAndSettle();

      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('authenticated override permits /cloud (ASH-005)', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(_AuthenticatedController.new),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/cloud');
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
      expect(find.text('Sign in to access your cloud library'), findsNothing);
    });

    testWidgets('authenticated users on /cloud/sign-in redirect to /cloud', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(_AuthenticatedController.new),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/cloud/sign-in');
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
    });

    testWidgets('signing in on sign-in redirects to /cloud (ASH-005)', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      router.go('/cloud');
      await tester.pumpAndSettle();
      expect(find.text('Sign in to access your cloud library'), findsOneWidget);

      container.read(authSessionProvider.notifier).signIn();
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
      expect(find.text('Sign in to access your cloud library'), findsNothing);
    });
  });
}
