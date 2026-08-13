import 'package:flutter/material.dart';

/// Sign-in placeholder (ASH-004).
///
/// Target of the auth-gate redirect for unauthenticated Cloud navigation.
/// The real Google OAuth flow is deferred.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sign in to access your cloud library'),
    );
  }
}
