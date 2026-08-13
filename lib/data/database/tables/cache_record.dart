import 'package:drift/drift.dart';

/// Temporary, automatically reclaimable streaming cache (LDB-001, LDB-005).
///
/// The only table targeted by automatic cache cleanup. Unlike [Downloads],
/// cache rows hold no audio identity and may be evicted at any time.
@DataClassName('CacheRecord')
class Cache extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get cloudObjectId => text()();

  TextColumn get filePath => text().nullable()();

  IntColumn get sizeBytes => integer().nullable()();

  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
