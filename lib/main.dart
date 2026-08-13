import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers/app_providers.dart';

/// Entry point (ASH-001, CFG-001/003).
///
/// Loads `.env`, builds [AppConfig] and injects it through [configProvider].
/// There is no silent default: a missing or empty key throws [ConfigException]
/// with a descriptive message before the first frame.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final config = AppConfig.fromEnv(dotenv.env);

  runApp(
    ProviderScope(
      overrides: [configProvider.overrideWithValue(config)],
      child: const App(),
    ),
  );
}
