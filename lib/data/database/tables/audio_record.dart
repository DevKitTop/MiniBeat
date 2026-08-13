import 'package:drift/drift.dart';

import 'folder_record.dart';

/// Local audio file known to the library (LDB-001).
///
/// Identity trio for layered duplicate detection (LDB-006, ADR-006):
/// [sizeBytes] + [durationMs] form the fast pre-filter and [sha256Hash] is the
/// authoritative signal. [isMissing] marks files that disappeared from disk
/// (BR-015 reconcile).
@DataClassName('AudioRecord')
@TableIndex(
  name: 'index_audio_records_sha256',
  columns: {#sha256Hash},
)
@TableIndex(
  name: 'index_audio_records_size_duration',
  columns: {#sizeBytes, #durationMs},
)
class AudioRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get filePath => text().unique()();

  TextColumn get fileName => text()();

  IntColumn get sizeBytes => integer()();

  IntColumn get durationMs => integer()();

  TextColumn get sha256Hash => text()();

  TextColumn get format => text()();

  IntColumn get folderId => integer()
      .nullable()
      .references(Folders, #id, onDelete: KeyAction.setNull)();

  BoolColumn get isMissing => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
