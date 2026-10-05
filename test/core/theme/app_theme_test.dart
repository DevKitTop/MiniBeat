import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/theme/app_theme.dart';

/// Locates the package's `pubspec.yaml` by walking up from the working
/// directory.
///
/// `flutter test` runs with the package root as its CWD, so the first candidate
/// already resolves; the upward walk only keeps the lookup honest if the runner
/// is ever invoked from a subdirectory. Returns `null` when nothing is found so
/// the caller fails with a message that says what went wrong.
File? _findPubspec() {
  var dir = Directory.current;
  while (true) {
    final candidate = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}

/// Returns the top-level `fonts:` block of the `flutter:` section as text.
///
/// Deliberately tolerant rather than a YAML parse: the assertions only need the
/// family declarations. `fonts:` also appears once per family entry, so the
/// shallowest match is the section header and everything from there down is the
/// block. Starting there also keeps the explanatory comment ABOVE the header out
/// of scope, which matters because that comment names Google Sans.
///
/// Returns an empty string when no `fonts:` key exists at all, so the caller's
/// own assertion reports the missing declarations instead of the caller dying on
/// `StateError: No element`.
String _flutterFontsSection(String pubspec) {
  final matches = RegExp(
    r'^([ \t]*)fonts:[ \t]*$',
    multiLine: true,
  ).allMatches(pubspec).toList();

  if (matches.isEmpty) return '';

  final shallowest = matches.reduce(
    (a, b) => a.group(1)!.length <= b.group(1)!.length ? a : b,
  );

  return pubspec.substring(shallowest.end);
}

// ── Expected palette (ASH-008) ──────────────────────────────────────────────
//
// These constants are DUPLICATED from the design token table on purpose. They
// MUST NOT be imported from `lib/core/theme/app_theme.dart`: an expected value
// read back out of the code under test is a tautological oracle — it passes
// against whatever the builder emits, which is exactly the gap ASH-008 closes.

// DARK
const _darkBackground = Color(0xFF0B0B1A);
const _darkSurface = Color(0xFF14142B);
const _darkSurfaceContainerLowest = Color(0xFF0C0C1C);
const _darkSurfaceContainerLow = Color(0xFF101026);
const _darkSurfaceContainer = Color(0xFF181833);
const _darkSurfaceContainerHigh = Color(0xFF1B1B3B);
const _darkSurfaceContainerHighest = Color(0xFF1E1E3F);
const _darkPrimary = Color(0xFF8B5CF6);
const _darkSecondary = Color(0xFF3B82F6);
const _darkTertiary = Color(0xFF22D3EE);
const _darkSecondaryContainer = Color(0xFF1E3A6E);
const _darkOnSecondaryContainer = Color(0xFFD7E3FF);
const _darkOnSurface = Color(0xFFEDE9FE);
const _darkOnSurfaceVariant = Color(0xFF9A95C8);

// LIGHT
const _lightBackground = Color(0xFFF4F2FF);
const _lightSurface = Color(0xFFFFFFFF);
// ASH-011 / design decision C: light `surfaceContainerLowest` is intentionally
// NOT declared in `buildAppTheme()`; its intended value IS the white `surface`
// fallback. Pinned here so the omission stays deliberate rather than accidental.
const _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
const _lightSurfaceContainerLow = Color(0xFFF7F4FD);
const _lightSurfaceContainer = Color(0xFFF0ECFA);
const _lightSurfaceContainerHigh = Color(0xFFE9E4F6);
const _lightSurfaceContainerHighest = Color(0xFFE2DCF2);
const _lightPrimary = Color(0xFF6D28D9);
const _lightSecondary = Color(0xFF2563EB);
const _lightTertiary = Color(0xFF0891B2);
const _lightSecondaryContainer = Color(0xFFBFD2FB);
const _lightOnSecondaryContainer = Color(0xFF0B2A6B);
const _lightOnSurface = Color(0xFF1A1636);
const _lightOnSurfaceVariant = Color(0xFF5E5A85);

// Both brightnesses share the error tone.
const _error = Color(0xFFB91C1C);

/// WCAG 2.1 contrast ratio between two opaque colours.
///
/// Uses [Color.computeLuminance], which is the relative-luminance function the
/// WCAG definition prescribes, so the numbers here are the same ones a contrast
/// checker would report.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Reads the five container roles from a live scheme, in tonal order.
List<double> _ladderLuminances(ColorScheme cs) => <double>[
  cs.surfaceContainerLowest.computeLuminance(),
  cs.surfaceContainerLow.computeLuminance(),
  cs.surfaceContainer.computeLuminance(),
  cs.surfaceContainerHigh.computeLuminance(),
  cs.surfaceContainerHighest.computeLuminance(),
];

void main() {
  group('app theme (ASH-002)', () {
    test('follows Material 3', () {
      final theme = buildAppTheme();

      expect(theme.useMaterial3, isTrue);
    });

    test('uses Plus Jakarta Sans as the default font family', () {
      final theme = buildAppTheme();

      // ThemeData applies `fontFamily` to its text theme styles.
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Plus Jakarta Sans');
      expect(theme.textTheme.headlineMedium?.fontFamily, 'Plus Jakarta Sans');
    });

    test('provides the floating-nav theme tokens (ASH-007 D2)', () {
      final theme = buildAppTheme();

      // The theme is the single source of truth for the nav bar's container
      // radius and elevation: the widget reads these tokens from
      // Theme.of(context) and must never hardcode its own fallbacks.
      expect(
        theme.cardTheme.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );
      expect(theme.navigationBarTheme.elevation, 3);
    });
  });

  group('bundled font families (ASH-002)', () {
    // A widget test never loads fonts, so `TextStyle.fontFamily` can only prove
    // the STRING the theme asks for — it cannot prove the family resolves. The
    // second ASH-002 scenario is about the declarations themselves, so these
    // assertions read the source of truth: the `fonts:` block.
    late Directory packageRoot;
    late String fontsSection;

    setUpAll(() {
      final pubspec = _findPubspec();
      expect(pubspec, isNotNull, reason: 'pubspec.yaml not found from the CWD');
      packageRoot = pubspec!.parent;
      fontsSection = _flutterFontsSection(pubspec.readAsStringSync());
    });

    test('declares Plus Jakarta Sans and ships its asset', () {
      expect(
        fontsSection,
        contains(
          RegExp(r'family:[ \t]*Plus Jakarta Sans[ \t]*$', multiLine: true),
        ),
      );
      // Declared is not the same as bundled: pin the asset so a dangling family
      // entry cannot pass.
      expect(
        fontsSection,
        contains('assets/fonts/PlusJakartaSans-Variable.ttf'),
      );
      expect(
        File(
          packageRoot.uri
              .resolve('assets/fonts/PlusJakartaSans-Variable.ttf')
              .toFilePath(),
        ).existsSync(),
        isTrue,
        reason: 'the declared Plus Jakarta Sans asset must exist on disk',
      );
    });

    test('keeps Roboto registered as a fallback family', () {
      expect(
        fontsSection,
        contains(RegExp(r'family:[ \t]*Roboto[ \t]*$', multiLine: true)),
      );
    });

    test('does not declare Google Sans', () {
      // Scoped to the `fonts:` block on purpose: the pubspec comment that
      // explains the licensing caveat names Google Sans deliberately.
      expect(fontsSection, isNot(contains('Google Sans')));
    });
  });

  group('cyberpunk dark palette (ASH-008)', () {
    final theme = buildAppTheme();

    test('is the default brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('emits every dark token as a literal palette value', () {
      final cs = theme.colorScheme;

      expect(cs.surface, _darkSurface);
      expect(cs.surfaceContainerLowest, _darkSurfaceContainerLowest);
      expect(cs.surfaceContainerLow, _darkSurfaceContainerLow);
      expect(cs.surfaceContainer, _darkSurfaceContainer);
      expect(cs.surfaceContainerHigh, _darkSurfaceContainerHigh);
      expect(cs.surfaceContainerHighest, _darkSurfaceContainerHighest);
      expect(cs.primary, _darkPrimary);
      expect(cs.secondary, _darkSecondary);
      expect(cs.tertiary, _darkTertiary);
      expect(cs.secondaryContainer, _darkSecondaryContainer);
      expect(cs.onSecondaryContainer, _darkOnSecondaryContainer);
      expect(cs.onSurface, _darkOnSurface);
      expect(cs.onSurfaceVariant, _darkOnSurfaceVariant);
      expect(cs.error, _error);
    });

    test('paints the scaffold background with the dark base', () {
      expect(theme.scaffoldBackgroundColor, _darkBackground);
    });

    test('declares the container tokens instead of inheriting them', () {
      final cs = theme.colorScheme;

      // M3 falls back to `surface`, `secondary` and `onSecondary` when these
      // are left null, which silently collapses the bar onto the Card panel.
      expect(cs.surfaceContainer, isNot(cs.surface));
      expect(cs.secondaryContainer, isNot(cs.secondary));
      expect(cs.onSecondaryContainer, isNot(cs.onSecondary));
    });

    test('rises monotonically across the dark container ladder', () {
      final luminances = _ladderLuminances(theme.colorScheme);

      for (var i = 1; i < luminances.length; i++) {
        expect(
          luminances[i],
          greaterThan(luminances[i - 1]),
          reason: 'dark ladder step $i must be lighter than step ${i - 1}',
        );
      }
    });
  });

  group('cyberpunk light palette (ASH-008)', () {
    final theme = buildAppTheme(brightness: Brightness.light);

    test('is the light brightness', () {
      expect(theme.brightness, Brightness.light);
    });

    test('emits every light token as a literal palette value', () {
      final cs = theme.colorScheme;

      expect(cs.surface, _lightSurface);
      expect(cs.surfaceContainerLowest, _lightSurfaceContainerLowest);
      expect(cs.surfaceContainerLow, _lightSurfaceContainerLow);
      expect(cs.surfaceContainer, _lightSurfaceContainer);
      expect(cs.surfaceContainerHigh, _lightSurfaceContainerHigh);
      expect(cs.surfaceContainerHighest, _lightSurfaceContainerHighest);
      expect(cs.primary, _lightPrimary);
      expect(cs.secondary, _lightSecondary);
      expect(cs.tertiary, _lightTertiary);
      expect(cs.secondaryContainer, _lightSecondaryContainer);
      expect(cs.onSecondaryContainer, _lightOnSecondaryContainer);
      expect(cs.onSurface, _lightOnSurface);
      expect(cs.onSurfaceVariant, _lightOnSurfaceVariant);
      expect(cs.error, _error);
    });

    test('paints the scaffold background with the light base', () {
      expect(theme.scaffoldBackgroundColor, _lightBackground);
    });

    test('declares the container tokens instead of inheriting them', () {
      final cs = theme.colorScheme;

      expect(cs.surfaceContainer, isNot(cs.surface));
      expect(cs.secondaryContainer, isNot(cs.secondary));
      expect(cs.onSecondaryContainer, isNot(cs.onSecondary));
    });

    test('falls monotonically across the light container ladder', () {
      final luminances = _ladderLuminances(theme.colorScheme);

      for (var i = 1; i < luminances.length; i++) {
        expect(
          luminances[i],
          lessThan(luminances[i - 1]),
          reason: 'light ladder step $i must be darker than step ${i - 1}',
        );
      }
    });

    test('keeps the nav tokens at 12 and 3, not merely non-null (ASH-009)', () {
      // The light palette must satisfy the FloatingNavBar contract with the
      // same values, not with whatever the dark palette happens to carry.
      expect(
        theme.cardTheme.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );
      expect(theme.navigationBarTheme.elevation, 3);
    });
  });

  group('foreground legibility on the bar surface (ASH-008)', () {
    // WCAG non-text minimum contrast. Icons painted on the bar are non-text
    // content, so 3:1 is the floor the palette has to clear.
    const minContrast = 3.0;

    test('dark onSurface clears the floor on the dark bar', () {
      final cs = buildAppTheme().colorScheme;

      expect(
        _contrastRatio(cs.onSurface, _darkSurfaceContainer),
        greaterThanOrEqualTo(minContrast),
      );
    });

    test('dark onSurfaceVariant clears the floor on the dark bar', () {
      final cs = buildAppTheme().colorScheme;

      expect(
        _contrastRatio(cs.onSurfaceVariant, _darkSurfaceContainer),
        greaterThanOrEqualTo(minContrast),
      );
    });

    test('dark center-circle icon clears the floor on its own fill', () {
      final cs = buildAppTheme().colorScheme;

      expect(
        _contrastRatio(cs.onSecondaryContainer, cs.secondaryContainer),
        greaterThanOrEqualTo(minContrast),
      );
    });

    test('light foregrounds clear the floor on the light bar', () {
      final cs = buildAppTheme(brightness: Brightness.light).colorScheme;

      expect(
        _contrastRatio(cs.onSurface, _lightSurfaceContainer),
        greaterThanOrEqualTo(minContrast),
      );
      expect(
        _contrastRatio(cs.onSurfaceVariant, _lightSurfaceContainer),
        greaterThanOrEqualTo(minContrast),
      );
      expect(
        _contrastRatio(cs.onSecondaryContainer, cs.secondaryContainer),
        greaterThanOrEqualTo(minContrast),
      );
    });
  });

  group('M3 defaults are inherited, not redeclared (ASH-011)', () {
    test('surfaceTint resolves to primary on both palettes', () {
      // `ColorScheme` declares `surfaceTint => _surfaceTint ?? primary`
      // (color_scheme.dart:1338), so passing `surfaceTint: primary` explicitly
      // redeclares the M3 default and ASH-011 forbids it. These assertions pin
      // the RESULTING value so the omission stays deliberate — they prove the
      // resolved tint, not the absence of the argument.
      final dark = buildAppTheme().colorScheme;
      final light = buildAppTheme(brightness: Brightness.light).colorScheme;

      expect(dark.surfaceTint, _darkPrimary);
      expect(dark.surfaceTint, dark.primary);
      expect(light.surfaceTint, _lightPrimary);
      expect(light.surfaceTint, light.primary);
    });
  });

  group('palette polarity', () {
    test('foregrounds are resolved per brightness, never shared', () {
      // Design decision D: one shared foreground pair is forbidden — it makes
      // the dark bar illegible.
      final dark = buildAppTheme().colorScheme;
      final light = buildAppTheme(brightness: Brightness.light).colorScheme;

      expect(dark.onSurface, isNot(light.onSurface));
      expect(dark.onSurfaceVariant, isNot(light.onSurfaceVariant));
    });

    test('light and dark palettes are genuinely different', () {
      // Guards against the previous failure mode: a "light" theme that silently
      // reuses the dark ColorScheme.
      final dark = buildAppTheme().colorScheme;
      final light = buildAppTheme(brightness: Brightness.light).colorScheme;

      expect(dark.primary, isNot(light.primary));
      expect(dark.surface, isNot(light.surface));
      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);
    });
  });
}
