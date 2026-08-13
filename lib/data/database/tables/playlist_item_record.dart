import 'package:drift/drift.dart';

import 'audio_record.dart';
import 'playlist_record.dart';

/// Positioned reference inside a playlist (LDB-001, BR-007).
///
/// Playlists store references only: deleting an item never deletes the source
/// audio (BR-016). Either [audioId] (local) or [cloudAudioId] (cloud) is set
/// depending on the playlist space.
@DataClassName('PlaylistItemRecord')
@TableIndex(
  name: 'index_playlist_items_position',
  columns: {#playlistId, #position},
  unique: true,
)
class PlaylistItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get playlistId => integer()
      .references(Playlists, #id, onDelete: KeyAction.cascade)();

  IntColumn get audioId => integer()
      .nullable()
      .references(AudioRecords, #id, onDelete: KeyAction.setNull)();

  TextColumn get cloudAudioId => text().nullable()();

  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();
}
