import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/app_shell.dart';
import '../../presentation/features/cloud-library/cloud_library_screen.dart';
import '../../presentation/features/cloud-library/sign_in_screen.dart';
import '../../presentation/features/local-library/local_library_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';

/// Builds the app router (ASH-003/004).
///
/// Three branches behind a [StatefulShellRoute.indexedStack]:
/// `/local`, `/cloud` (+ `/cloud/sign-in`) and `/settings`. The Cloud branch
/// is gated: unauthenticated users are redirected to the sign-in placeholder
/// and authenticated users are never shown it.
///
/// [refreshListenable] re-evaluates the redirect whenever the auth session
/// changes (the router provider wires it to `authSessionProvider`).
GoRouter buildAppRouter({
  required Listenable refreshListenable,
  required bool Function() isAuthenticated,
}) {
  return GoRouter(
    initialLocation: '/local',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authed = isAuthenticated();

      // Root always lands on the local branch (ASH-001).
      if (location == '/') return '/local';
      // Cloud requires a session (ASH-004).
      if (!authed && location.startsWith('/cloud')) {
        return '/cloud/sign-in';
      }
      // Signed-in users skip the sign-in placeholder.
      if (authed && location == '/cloud/sign-in') return '/cloud';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/local',
                builder: (context, state) => const LocalLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cloud',
                builder: (context, state) => const CloudLibraryScreen(),
              ),
              GoRoute(
                path: '/cloud/sign-in',
                builder: (context, state) => const SignInScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
