# Design: Custom Floating Navigation Bar (Music / History / Settings)

## Technical Approach

Replace the standard M3 `NavigationBar` with a pure-presentational floating bar (`FloatingNavBar`) implementing the confirmed IA **History | Music (center, prominent) | Settings**, plus a repository read-layer that verifies the two queries the UI will consume later (`HistoryRepository` BR-011 cap + space scoping, `DownloadsRepository` BR-006 status filter + ordering). Router wiring, AppShell swap, and in-screen auth gating are intentionally OUT of scope (router slice); `app_shell.dart`, `app_router.dart`, `app_providers.dart` stay untouched. All-additive; no schema change (`schemaVersion` stays 1).

## Requirement → Design Element

| Req | Design element |
|-----|----------------|
| ASH-007 | `lib/presentation/widgets/floating_nav_bar.dart` + widget tests |
| LDB-007 | `lib/repositories/history_repository.dart` + in-memory DB tests (BR-011 cap, space filter, tie-break) |
| LDB-008 | `lib/repositories/downloads_repository.dart` + in-memory DB tests (status filter, defined ordering) |
| PRODUCT_SPEC §4 | Wording change to Music / History / Settings (exact text below) |

## Architecture Decisions

### D1 — Widget API: fixed 3-slot layout

**Choice**: `FloatingNavBar({required int selectedIndex, required ValueChanged<int> onDestinationSelected})` — destinations fixed internally (History=0, Music=1 center, Settings=2).
**Alternatives**: configurable `destinations` list + "center index" param.
**Rationale**: ASH-007 pins exactly three destinations in fixed order; a fixed layout makes center prominence structural (the middle slot is always the raised circle) and shrinks the API surface — fewer knobs, zero index-drift risk for the router slice, which only needs the index contract.

### D2 — Theme tokens: derive, don't invent

**Choice**: bar surface = `colorScheme.surfaceContainer`; center circle = `colorScheme.secondaryContainer` + `onSecondaryContainer`; side icons = `onSurfaceVariant` (selected `onSurface` with `secondaryContainer` pill); container radius = `Theme.of(context).cardTheme.shape` (M3 shape token, default 12); bar elevation = `Theme.of(context).navigationBarTheme.elevation` (M3 default 3). **No ThemeExtension this slice.** Layout dimensions (padding, icon/circle sizes) are ordinary `const` — ASH-007's ban covers color and radius constants only.
**Alternatives**: custom `NavBarTheme` ThemeExtension; hardcoded `BorderRadius.circular(12)`.
**Rationale**: one radius does not justify a ThemeExtension surface (repo rule: justify every token); deriving from existing M3 tokens satisfies "no hardcoded color/radius constants" with zero new machinery. Revisit the extension only if a second nav-specific token appears.

### D3 — Center prominence: tonal + size

**Choice**: Music rendered as a raised filled circle (`secondaryContainer`, ~56 dp, larger than flat side destinations) — structurally prominent whether selected or not; selected state adds emphasis via the filled-circle treatment already present plus icon emphasis. No elevation bump: all elevation stays theme-derived.
**Alternatives**: elevation differential, outline ring.
**Rationale**: tonal contrast + size is the M3-conventional prominence mechanism (FAB-like); avoids hardcoded elevation offsets that would violate D2.

### D4 — LDB-008 ordering (OPEN QUESTION RESOLVED)

**Choice**: `updatedAt DESC` primary, `id DESC` tie-break.
**Rationale**: a completed-downloads view means "most recently completed first"; `updatedAt` reflects the transfer state machine's last change (queued → downloading → completed/failed), i.e. completion time for completed rows. `createdAt` would order by transfer start — stale semantics for this view. `id DESC` is a stable deterministic tie-break for identical timestamps. **Recorded decision, not a guess.**

### D5 — LDB-007 tie-break

**Choice**: `playedAt DESC` (spec) with `id DESC` as stable secondary key for identical `playedAt` (the later-recorded entry counts as more recent; deterministic for tests).
**Alternatives**: `id ASC`, no tie-break (non-deterministic SQLite order).
**Rationale**: matches "most recent play first" intent and keeps query results reproducible.

### D6 — Repository structure: two focused repositories

**Choice**: `HistoryRepository` and `DownloadsRepository` (as in proposal).
**Alternatives**: one combined `LibraryReadRepository`.
**Rationale**: distinct product questions (space-scoped cap vs status filter), distinct future screens, distinct cap policy; two single-method classes are not "big architecture", while a combined repo would couple unrelated queries and grow unboundedly.

### D7 — Read contract: drift watch streams

**Choice**: `Stream<List<HistoryRecord>> watchRecent({required String space, int limit = ProductPolicy.historyLimit})` and `Stream<List<DownloadRecord>> watchByStatus(String status)`; cap enforced inside the repo as `min(limit, ProductPolicy.historyLimit)` (BR-011 is a hard ceiling the API cannot exceed; callers may request fewer). Streams via drift `watch()`; **no repository providers this slice** — repos are constructed with the DB in tests, providers land with the UI slice.
**Alternatives**: `Future`/`select` one-shot queries; generic `limit` param without cap.
**Rationale**: drift `watch()` is reactive and maps 1:1 to Riverpod `StreamProvider`s the UI will consume (dart-flutter-patterns §3) — choosing the stream contract now means zero adapter rework later.

## Data Flow

```
[Drift: history]  ──watch──> HistoryRepository.watchRecent(space, limit)
                              └─► Stream<List<HistoryRecord>> ──► (UI slice: StreamProvider)
[Drift: downloads] ──watch──> DownloadsRepository.watchByStatus(status)
                              └─► Stream<List<DownloadRecord>> ──► (UI slice)
AppShell (future) ──selectedIndex / onDestinationSelected──> FloatingNavBar (pure, no riverpod/router/auth imports)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/presentation/widgets/floating_nav_bar.dart` | Create (new `widgets/` dir) | Pure-presentational `FloatingNavBar`; fixed 3-slot layout; floating via `SafeArea(top: false)` + horizontal padding + rounded `Material`; `Semantics(button:true, selected:)` + visible labels per destination |
| `lib/repositories/history_repository.dart` | Create | `watchRecent` — space filter, `playedAt` DESC / `id` DESC, cap `min(limit, historyLimit)` (BR-011) |
| `lib/repositories/downloads_repository.dart` | Create | `watchByStatus` — status filter, `updatedAt` DESC / `id` DESC (LDB-008) |
| `test/presentation/widgets/floating_nav_bar_test.dart` | Create | Widget tests (below) |
| `test/repositories/history_repository_test.dart` | Create | Read-layer tests (below) |
| `test/repositories/downloads_repository_test.dart` | Create | Read-layer tests (below) |
| `rep_docs/music_app_docs/PRODUCT_SPEC.md` §4 | Modify | Exact wording replacement (below) |
| `lib/presentation/app_shell.dart`, `lib/core/router/app_router.dart`, `lib/core/providers/app_providers.dart` | Untouched | Router slice later |

## Interfaces / Contracts

```dart
// lib/presentation/widgets/floating_nav_bar.dart
/// Destination contract (ASH-007) — do not reorder:
/// | index | branch      | role              |
/// | 0     | /history    | flat side slot    |
/// | 1     | /music      | center, prominent |
/// | 2     | /settings   | flat side slot    |
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.selectedIndex, required this.onDestinationSelected});
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
}
```

```dart
// lib/repositories/history_repository.dart
class HistoryRepository {
  HistoryRepository(this._db);
  final AppDatabase _db;
  Stream<List<HistoryRecord>> watchRecent({required String space, int limit = ProductPolicy.historyLimit});
}

// lib/repositories/downloads_repository.dart
class DownloadsRepository {
  DownloadsRepository(this._db);
  final AppDatabase _db;
  Stream<List<DownloadRecord>> watchByStatus(String status); // 'queued'|'downloading'|'completed'|'failed'
}
```

### PRODUCT_SPEC.md §4 — exact replacement (L65-78, rest of file untouched)

Replace:
```markdown
Navegación inferior prevista:

- Música
- Playlist
- Configuración

Dentro de Música existirán dos espacios claramente separados:
```
with:
```markdown
Navegación inferior prevista:

- History
- Music (centro, destacado)
- Settings

Dentro de Music existirán dos espacios claramente separados:
```
Bullets listed in bar order; `Dentro de Music` renamed so the reference stays coherent with the new destination; the `- Local` / `- Cloud` bullets and the L78 sign-in sentence remain unchanged.

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Widget | `FloatingNavBar` — 3 destinations in order (History, Music, Settings), center circle larger than side slots, no `NavigationBar` in tree, tap → callback index, theme-derived visuals (bar color == `colorScheme.surfaceContainer`, radius == `cardTheme.shape`), selected destination distinct | `MaterialApp(theme: buildAppTheme(), home: Scaffold(bottomNavigationBar: ...))` — no `ProviderScope`/router needed (pure widget). Assert via `find.text`, `find.byType(NavigationBar)` findsNothing, geometry (`tester.getTopLeft`/`getSize`), `tester.tap` on destination keys (`floating-nav-destination-<index>`), color/radius compared against theme values |
| Unit | `HistoryRepository` — >20 inserts for one space → ≤20, most recent first; local+cloud rows → space filter; empty space → empty; identical `playedAt` → `id` DESC; `limit: 5` → 5, `limit: 50` → still 20 | `AppDatabase.forTesting()` (LDB-003; same setUp/tearDown as `app_database_test.dart`), `await repo.watchRecent(...).first` for snapshot assertions |
| Unit | `DownloadsRepository` — completed+failed+queued rows → only completed; distinct `updatedAt` → DESC; identical → `id` DESC; none completed → empty | same in-memory DB pattern |
| Regression | Existing suite stays green: `test/app_shell_test.dart` and `test/widget_test.dart` assert `NavigationBar` and router behavior — untouched this slice | no changes |

## Migration / Rollout

No migration (all-additive; no schema/version change). Rollback: delete widget/repos/tests, revert PRODUCT_SPEC §4 — router untouched, no runtime behavior change. Restore point: pre-change commit on `feature/custom-navbar`.

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `cardTheme.shape` / `navigationBarTheme.elevation` defaults differ in Flutter 3.44.9 | Low | Verify defaults at apply; widget tests assert against the live theme values, so a mismatch fails loudly |
| `colorScheme.surfaceContainer` availability | Low | Present since Flutter 3.22; confirm at apply |
| Exact center-circle size/offset needs visual QA | Low | Circle diameter is a layout const in the widget; adjust at apply; geometry test guards the prominence contract |
| LDB-008 `updatedAt` ordering misreads product intent | Low | Decision recorded (D4); revisit via decision doc, never silently |
| Modified `openspec/specs/` deltas uncommitted | Low | Commit specs with this change |

## Open Questions

- [ ] Mirror the LDB-008/LDB-007 ordering decisions into `rep_docs/music_app_docs/decisions/` or a technical doc, or keep them recorded in this design only? (decide at archive)
- [ ] None blocking. Center circle diameter (~56 dp) resolved at apply as a layout constant.
