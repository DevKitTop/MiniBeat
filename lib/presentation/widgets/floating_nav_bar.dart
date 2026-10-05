import 'package:flutter/material.dart';

/// Custom floating bottom navigation bar (ASH-007).
///
/// Pure presentational widget: it does NOT import Riverpod, go_router, auth,
/// or repository code. It replaces the standard [NavigationBar] visually while
/// keeping the same index-based contract for the shell.
///
/// The bar is centered with auto width (pill shape) and wrapped in a gradient
/// border derived from the palette accent colors (primary → secondary →
/// tertiary). All three destinations use circular icon containers; the center
/// slot is structurally larger for visual prominence.
///
/// Destination contract — do not reorder:
/// | index | branch      | role              |
/// | 0     | /history    | circular side     |
/// | 1     | /music      | center, prominent |
/// | 2     | /settings   | circular side     |
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

  /// Diameter of the side destination circles (dp).
  static const double _sideCircleSize = 44;

  /// Width of the gradient border around the bar (dp).
  static const double _gradientBorderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // D2: derive elevation from the theme. The bar's shape is its own
    // StadiumBorder — it no longer reads cardTheme.shape.
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              key: const ValueKey('floating-nav-gradient-border'),
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                  ],
                ),
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_gradientBorderWidth),
                child: Material(
                  key: const ValueKey('floating-nav-bar'),
                  color: colorScheme.surfaceContainer,
                  shape: const StadiumBorder(),
                  elevation: elevation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSideDestination(
                          context,
                          index: 0,
                          label: 'Historial',
                          icon: Icons.history,
                        ),
                        const SizedBox(width: 16),
                        _buildCenterDestination(
                          context,
                          label: 'Música',
                          icon: Icons.play_arrow_rounded,
                        ),
                        const SizedBox(width: 16),
                        _buildSideDestination(
                          context,
                          index: 2,
                          label: 'Ajustes',
                          icon: Icons.settings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Circular side destination (index 0 or 2): filled circle with
  /// secondaryContainer when selected, transparent when not.
  Widget _buildSideDestination(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = index == selectedIndex;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        key: ValueKey('floating-nav-destination-$index'),
        customBorder: const CircleBorder(),
        onTap: () => onDestinationSelected(index),
        child: Container(
          key: ValueKey('floating-nav-side-circle-$index'),
          width: _sideCircleSize,
          height: _sideCircleSize,
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.secondaryContainer
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: selected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final selected = selectedIndex == 1;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        key: const ValueKey('floating-nav-destination-1'),
        customBorder: const CircleBorder(),
        onTap: () => onDestinationSelected(1),
        child: Container(
          key: const ValueKey('floating-nav-center-circle'),
          width: _centerCircleSize,
          height: _centerCircleSize,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
