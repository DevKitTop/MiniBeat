# Proposal: Cyberpunk Palette + Plus Jakarta Sans

## Intent

Make the already-implemented cyberpunk palette traceable. Review found three defects: a violated `SHALL`, an undeclared light→dark flip, and dropped M3 container tokens the nav bar paints. This change records intent and closes them — it is **not** a redesign.

## Spec Amendment Requested

ASH-002 (`app-shell/spec.md` L21) mandates Roboto. User-approved delta:

> ...use a Google font family; **Plus Jakarta Sans SHALL be the default family**, Roboto SHALL remain registered as a fallback, and Google Sans SHALL NOT be bundled without a license (caveat documented in the theme source).

ASH-001/003–007 unchanged.

## Capabilities

- **Modified `app-shell`** — amend ASH-002 (default family); add requirement pinning every `ColorScheme` token read by presentation widgets, in both brightnesses.
- New: None.

## Defects and Root Cause

| # | Defect | Root cause |
|---|--------|-----------|
| 1 | Font violates ASH-002 | Test oracle rewritten to match the code instead of amending the spec |
| 2 | Undeclared light→dark flip | `buildAppTheme()` gained `brightness = Brightness.dark`; `lib/app.dart:18` passes no argument and HEAD's `fromSeed` defaulted to light |
| 3 | Nav container tokens dropped | Generated scheme replaced by a hand-picked one — a **lossy** migration |

`ColorScheme.dark()/light()` leave container tokens **null** unless passed (Flutter 3.44.9 `color_scheme.dart` L551–558, L575–579); getters then fall back (L1099, L1109, L1266). `FloatingNavBar` paints five tokens; three are unpinned:

| Token read | Falls back to | Effect |
|---|---|---|
| `surfaceContainer` | `surface` | Bar identical to Card; elevation-only separation |
| `secondaryContainer` | `secondary` | Raw `#3B82F6`/`#2563EB` as a container fill |
| `onSecondaryContainer` | `onSecondary` | `Colors.black`, unpinned |

`surfaceContainerLowest`/`Low`/`High` also unpinned (= `surface`); `surfaceContainerHighest` pinned in dark only.

**Why review missed it:** nav-bar tests assert *derivation* (`bar.color == colorScheme.surfaceContainer`) — tautological against a wrong value. Nothing asserts *intent*.

## Scope

**In:** delta spec (ASH-002 + token pinning); full token inventory; declare dark-as-default; preserve D2 contract (`cardTheme.shape` + `navigationBarTheme.elevation` **outside** the brightness ternary, radius 12 / elevation 3); record decision in `architecture-decisions.md`.

**Out:** nav bar visual redesign (separate, unapproved); pre-existing `.env`-as-asset in `pubspec.yaml` — file separately; router/screen/navigation changes; the 2 pre-existing Spanish/English label failures (`Historial`/`Música`/`Ajustes`) — unrelated to theme.

## Open Decisions

| # | Decision | Options |
|---|---|---|
| A | Dark-default wiring | (1) stay pinned to dark; (2) add `darkTheme` + `ThemeMode.system`. Light palette is **unreachable at runtime** today — tests only |
| B | Decision-doc placement | ADR rule enumerates 9 areas (engine, storage, DB, state, nav, indexing, sync, security, cross-platform); **theming is not among them**. Recommend a D-series entry (D2 precedent), not ADR-007 |

## Approach

1. `sdd-spec` — amend ASH-002, add token-pinning requirement.
2. `sdd-design` — record decision, resolve A.
3. `sdd-apply` — declare missing tokens; test **values**, not derivation.

Do not redeclare light `surface: Colors.white`; `avoid_redundant_argument_values` (`analysis_options.yaml:19`) fires.

## Affected Areas

| Area | Impact |
|---|---|
| `lib/core/theme/app_theme.dart` | Missing container tokens; dark default |
| `lib/app.dart` | Only if A = 2 |
| `test/core/theme/app_theme_test.dart` | Pin tokens by value |
| `openspec/specs/app-shell/spec.md` | ASH-002 delta (at archive) |
| `rep_docs/.../architecture-decisions.md` | Decision record |
| `lib/presentation/widgets/floating_nav_bar.dart` | Untouched |

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Nav appearance shifts again | Med | Tokens pinned by value tests |
| Light scheme stays dead code | Med | Resolve A explicitly |
| Spec/oracle drift recurs | Med | Delta spec precedes code |

## Rollback Plan

Revert `app_theme.dart`, `app.dart`, theme test, and the decision row; the delta spec applies only at archive.

## Dependencies

No new packages. Plus Jakarta Sans variable TTF + OFL 1.1 already bundled.

## Success Criteria

- [ ] ASH-002 amended: Plus Jakarta Sans default, Roboto fallback, caveat intact
- [ ] Five nav-bar tokens pinned in both brightnesses, asserted by value
- [ ] Dark-as-default declared in spec + decision record
- [ ] Nav tokens outside the ternary; 3 nav tests green
- [ ] `flutter analyze` clean; `flutter test` 75 pass / 2 pre-existing failures, no new ones