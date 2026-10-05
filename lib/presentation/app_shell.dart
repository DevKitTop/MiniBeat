import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/floating_nav_bar.dart';

/// Bottom-navigation shell hosting the three StatefulShellBranch stacks
/// (ASH-003). Each branch keeps its own navigation state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Jump to the branch root instead of restoring the deepest page.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
