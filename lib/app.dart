import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';

/// Root widget: wires the router and theme (ASH-001).
///
/// Configuration is injected through [configProvider] by `main()`; tests
/// override it with a fake [AppConfig].
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'rep_mini',
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
