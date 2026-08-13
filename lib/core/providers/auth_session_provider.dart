import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication state exposed to the router gate (ASH-005).
///
/// Scaffold placeholder: no real auth flow yet, so the session only carries an
/// `isAuthenticated` flag and always starts signed out.
class AuthSession {
  const AuthSession({this.isAuthenticated = false});

  final bool isAuthenticated;
}

/// Manual `Notifier` (ASH-005): no codegen, no legacy StateNotifier imports.
class AuthSessionController extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession();

  void signIn() {
    state = const AuthSession(isAuthenticated: true);
  }

  void signOut() {
    state = const AuthSession();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionController, AuthSession>(
  AuthSessionController.new,
);
