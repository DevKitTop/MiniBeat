import 'package:drift/drift.dart';

import 'audio_record.dart';

/// Last playback position (LDB-001).
///
/// Single active row enforced in the app layer; position persisted on
/// pause/close. Either [audioId] (local) or [cloudAudioId] (cloud) identifies
/// the source depending on [space].
@DataClassName('PlaybackStateRecord')
class PlaybackState extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get space => text()();

  IntColumn get audioId => integer()
      .nullable()
      .references(AudioRecords, #id, onDelete: KeyAction.setNull)();

  TextColumn get cloudAudioId => text().nullable()();

  IntColumn get positionMs => integer()();

  BoolColumn get isPlaying => boolean()();

  DateTimeColumn get updatedAt => dateTime()();
}
