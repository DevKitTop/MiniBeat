import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_session_provider.dart';

/// Sign-in placeholder (ASH-004, D8).
///
/// Rendered in-screen by the Music screen when the Cloud space is selected
/// without an authenticated session. The real Google OAuth flow is deferred;
/// the demo button flips `authSessionProvider` so the gate swaps to the cloud
/// library reactively — no navigation (D8).
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sign in to access your cloud library'),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('sign-in-demo-button'),
            onPressed: () => ref.read(authSessionProvider.notifier).signIn(),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
