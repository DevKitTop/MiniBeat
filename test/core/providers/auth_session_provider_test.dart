import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/providers/auth_session_provider.dart';

void main() {
  group('AuthSessionController (ASH-005)', () {
    test('defaults to unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });

    test('signIn() transitions to authenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authSessionProvider.notifier).signIn();

      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('signOut() returns to unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authSessionProvider.notifier);
      controller.signIn();
      controller.signOut();

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });
  });
}
