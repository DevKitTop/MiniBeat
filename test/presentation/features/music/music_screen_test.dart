import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/providers/auth_session_provider.dart';
import 'package:rep_mini/presentation/features/music/music_screen.dart';

/// A controller that starts authenticated (ASH-005 scenario override).
class _AuthenticatedController extends AuthSessionController {
  @override
  AuthSession build() => const AuthSession(isAuthenticated: true);
}

Widget _harness({List<Override> overrides = const []}) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(home: MusicScreen()),
);

void main() {
  group('MusicScreen space toggle (ASH-004/005)', () {
    testWidgets('boots on the Local space signed out (BR-003/004)', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Local library placeholder'), findsOneWidget);
    });

    testWidgets('toggling the Cloud segment swaps the body', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();
      expect(find.text('Local library placeholder'), findsOneWidget);

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();
      expect(find.text('Local library placeholder'), findsNothing);

      await tester.tap(find.text('Local'));
      await tester.pumpAndSettle();
      expect(find.text('Local library placeholder'), findsOneWidget);
    });
  });

  group('MusicScreen Cloud gate (ASH-004/005, D8)', () {
    testWidgets('signed-out Cloud segment shows sign-in, not the library', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to access your cloud library'), findsOneWidget);
      expect(find.byKey(const ValueKey('sign-in-demo-button')), findsOneWidget);
      expect(find.text('Cloud library placeholder'), findsNothing);
    });

    testWidgets('authenticated override shows the cloud library (ASH-005)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
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

    testWidgets('demo sign-in button swaps in-screen without navigation (D8)', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cloud'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to access your cloud library'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('sign-in-demo-button')));
      await tester.pumpAndSettle();

      expect(find.text('Cloud library placeholder'), findsOneWidget);
      expect(find.text('Sign in to access your cloud library'), findsNothing);
    });
  });
}
