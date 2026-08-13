import 'package:drift/drift.dart';

import 'audio_record.dart';

/// Play history entry scoped to a content space (LDB-001, BR-010).
///
/// The max-20 history cap (BR-011) is enforced in the app layer, not here.
@DataClassName('HistoryRecord')
@TableIndex(
  name: 'index_history_played_at',
  columns: {#playedAt},
)
class History extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get space => text()();

  IntColumn get audioId => integer()
      .nullable()
      .references(AudioRecords, #id, onDelete: KeyAction.setNull)();

  TextColumn get cloudAudioId => text().nullable()();

  DateTimeColumn get playedAt => dateTime()();
}
