import 'package:flutter/material.dart';

/// Custom floating bottom navigation bar (ASH-007).
///
/// Pure presentational widget: it does NOT import Riverpod, go_router, auth,
/// or repository code. It replaces the standard [NavigationBar] visually while
/// keeping the same index-based contract for the shell.
///
/// Destination contract — do not reorder:
/// | index | branch      | role              |
/// | 0     | /history    | flat side slot    |
/// | 1     | /music      | center, prominent |
/// | 2     | /settings   | flat side slot    |
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Currently selected destination index (0..2).
  final int selectedIndex;

  /// Called with the tapped destination index (0..2).
  final ValueChanged<int> onDestinationSelected;

  /// D3: diameter of the prominent center circle (dp). A layout constant, not
  /// a theme token — ASH-007's ban covers color and radius constants only.
  static const double _centerCircleSize = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // D2: derive, don't invent. The app theme (buildAppTheme) provides the M3
    // tokens — card radius 12 and elevation 3 — and the bar reads them
    // directly. A theme that omits them is a contract violation: fail loudly
    // instead of silently substituting hardcoded constants.
    final shape = theme.cardTheme.shape;
    if (shape == null) {
      throw StateError(
        'FloatingNavBar requires Theme.cardTheme.shape — set it in '
        'buildAppTheme() (ASH-007 D2).',
      );
    }
    final elevation = theme.navigationBarTheme.elevation;
    if (elevation == null) {
      throw StateError(
        'FloatingNavBar requires Theme.navigationBarTheme.elevation — set it '
        'in buildAppTheme() (ASH-007 D2).',
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Material(
          key: const ValueKey('floating-nav-bar'),
          color: colorScheme.surfaceContainer,
          elevation: elevation,
          shape: shape,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSideDestination(
                  context,
                  index: 0,
                  label: 'History',
                  icon: Icons.history,
                ),
                _buildCenterDestination(
                  context,
                  label: 'Music',
                  icon: Icons.music_note,
                ),
                _buildSideDestination(
                  context,
                  index: 2,
                  label: 'Settings',
                  icon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Flat side destination (index 0 or 2): muted when unselected, emphasized
  /// with a secondaryContainer pill when selected (D2).
  Widget _buildSideDestination(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = index == selectedIndex;
    final foreground = selected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        key: ValueKey('floating-nav-destination-$index'),
        customBorder: const StadiumBorder(),
        onTap: () => onDestinationSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: selected
              ? ShapeDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: const StadiumBorder(),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(height: 2),
              // The Semantics wrapper above already provides the label;
              // exclude the visual text so screen readers read it once.
              ExcludeSemantics(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Center destination (index 1): raised filled circle on secondaryContainer,
  /// structurally prominent whether selected or not (D3).
  Widget _buildCenterDestination(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = selectedIndex == 1;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        key: const ValueKey('floating-nav-destination-1'),
        customBorder: const CircleBorder(),
        onTap: () => onDestinationSelected(1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const ValueKey('floating-nav-center-circle'),
              width: _centerCircleSize,
              height: _centerCircleSize,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 2),
            ExcludeSemantics(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
