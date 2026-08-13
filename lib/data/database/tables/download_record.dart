import 'package:drift/drift.dart';

import 'audio_record.dart';

/// Permanent, user-controlled copy of a cloud object (LDB-001, LDB-005).
///
/// NEVER targeted by automatic cache cleanup: downloads are explicit user
/// actions (BR-006) and survive on device. [status] mirrors the transfer
/// state machine: queued / downloading / completed / failed.
@DataClassName('DownloadRecord')
class Downloads extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get cloudObjectId => text()();

  IntColumn get audioId => integer()
      .nullable()
      .references(AudioRecords, #id, onDelete: KeyAction.setNull)();

  TextColumn get filePath => text().nullable()();

  IntColumn get sizeBytes => integer().nullable()();

  TextColumn get sha256Hash => text().nullable()();

  TextColumn get status => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
