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
      overrides: [
        configProvider.overrideWithValue(_testConfig),
        ...overrides,
      ],
      child: const App(),
    );

void main() {
  group('App smoke (ASH-001/003/004)', () {
    testWidgets('boots to the local library with the shell (ASH-003)',
        (tester) async {
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

    testWidgets('authenticated override renders the cloud library (ASH-004)',
        (tester) async {
      await tester.pumpWidget(
        _boot(overrides: [
          authSessionProvider.overrideWith(_AuthenticatedController.new),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
      expect(find.text('Sign in to access your cloud library'), findsNothing);
    });
  });
}
