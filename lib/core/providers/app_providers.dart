import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../audio/playback_controller_interface.dart';
import '../../data/database/app_database.dart';
import '../config/app_config.dart';
import '../router/app_router.dart';
import 'auth_session_provider.dart';

/// App configuration, injected by `main()` from the loaded environment
/// (CFG-003). Throws until overridden so there is never a silent default.
final configProvider = Provider<AppConfig>(
  (ref) => throw const ConfigException(
    'configProvider must be overridden with the loaded AppConfig in main().',
  ),
);

/// The app database (LDB-002). Tests override this with
/// `AppDatabase.forTesting()` (LDB-003).
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Placeholder playback controller (deferred to the audio feature).
final audioServiceProvider = Provider<PlaybackControllerInterface>(
  (ref) => throw UnimplementedError(
    'PlaybackControllerInterface implementation is deferred to the audio feature.',
  ),
);

/// The single go_router instance (ASH-001/003).
///
/// Re-evaluates the auth redirect whenever [authSessionProvider] changes by
/// bumping an owned [ValueNotifier] wired as GoRouter's `refreshListenable`
/// (ASH-004/005).
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authSessionProvider, (_, _) => refreshNotifier.value++);

  return buildAppRouter(
    refreshListenable: refreshNotifier,
    isAuthenticated: () => ref.read(authSessionProvider).isAuthenticated,
  );
});
