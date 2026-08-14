import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

/// Read repository for explicit downloads (LDB-008).
///
/// A completed-downloads view means "most recently completed first", so
/// results order by `updatedAt` descending (the transfer state machine's last
/// change, i.e. completion time for completed rows) with `id` descending as a
/// stable tie-break for identical timestamps (D4).
class DownloadsRepository {
  DownloadsRepository(this._db);

  final AppDatabase _db;

  /// Watches downloads filtered to [status]
  /// (`queued` | `downloading` | `completed` | `failed`), ordered by
  /// `updatedAt` descending then `id` descending (D4).
  Stream<List<DownloadRecord>> watchByStatus(String status) {
    final query = _db.select(_db.downloads)
      ..where((row) => row.status.equals(status))
      ..orderBy([
        (row) => OrderingTerm.desc(row.updatedAt),
        (row) => OrderingTerm.desc(row.id),
      ]);
    return query.watch();
  }
}
