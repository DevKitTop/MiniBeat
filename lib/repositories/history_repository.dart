import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../core/policy/product_policy.dart';
import '../data/database/app_database.dart';

/// Read repository for play-history entries (LDB-007).
///
/// The 20-entry cap (BR-011) is enforced HERE via [ProductPolicy.historyLimit],
/// not in the table definition (LDB-007).
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Watches the most recent play-history entries for [space], ordered by
  /// `playedAt` descending (most recent first) with `id` descending as a
  /// stable tie-break for identical timestamps (D5).
  ///
  /// The result is capped at `min(limit, ProductPolicy.historyLimit)` — the
  /// product cap is a hard ceiling the API cannot exceed (BR-011); callers may
  /// request fewer entries.
  Stream<List<HistoryRecord>> watchRecent({
    required String space,
    int limit = ProductPolicy.historyLimit,
  }) {
    final capped = math.min(math.max(limit, 0), ProductPolicy.historyLimit);
    final query = _db.select(_db.history)
      ..where((row) => row.space.equals(space))
      ..orderBy([
        (row) => OrderingTerm.desc(row.playedAt),
        (row) => OrderingTerm.desc(row.id),
      ])
      ..limit(capped);
    return query.watch();
  }

  /// Watches the most recent play-history entries across BOTH content spaces
  /// in one result, ordered by `playedAt` descending with `id` descending as a
  /// stable tie-break (D5).
  ///
  /// The cap (BR-011) applies to the merged TOTAL: the result holds at most
  /// `min(limit, ProductPolicy.historyLimit)` entries (LDB-009, D6).
  /// Additive: [watchRecent] keeps its space-scoped semantics (LDB-007).
  Stream<List<HistoryRecord>> watchRecentMerged({
    int limit = ProductPolicy.historyLimit,
  }) {
    final capped = math.min(math.max(limit, 0), ProductPolicy.historyLimit);
    final query = _db.select(_db.history)
      ..orderBy([
        (row) => OrderingTerm.desc(row.playedAt),
        (row) => OrderingTerm.desc(row.id),
      ])
      ..limit(capped);
    return query.watch();
  }
}
