import 'package:drift/drift.dart';

import 'audio_record.dart';

/// Favorite marker scoped to a content space (LDB-001, BR-009).
@DataClassName('FavoriteRecord')
@TableIndex(
  name: 'index_favorites_unique',
  columns: {#space, #audioId, #cloudAudioId},
  unique: true,
)
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get space => text()();

  IntColumn get audioId => integer()
      .nullable()
      .references(AudioRecords, #id, onDelete: KeyAction.setNull)();

  TextColumn get cloudAudioId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
