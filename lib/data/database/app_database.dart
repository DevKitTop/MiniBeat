import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/app_settings_record.dart';
import 'tables/audio_record.dart';
import 'tables/cache_record.dart';
import 'tables/download_record.dart';
import 'tables/favorite_record.dart';
import 'tables/folder_record.dart';
import 'tables/history_record.dart';
import 'tables/playback_state_record.dart';
import 'tables/playlist_item_record.dart';
import 'tables/playlist_record.dart';

part 'app_database.g.dart';

/// The rep_mini local database (LDB-002).
///
/// Baseline schema version 1 holding the ten core records (LDB-001). No
/// repositories or sync logic live here: schema only, per the scaffold scope.
@DriftDatabase(
  tables: [
    AudioRecords,
    Folders,
    Playlists,
    PlaylistItems,
    Favorites,
    History,
    Downloads,
    Cache,
    AppSettings,
    PlaybackState,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database via drift_flutter.
  AppDatabase() : super(driftDatabase(name: 'rep_mini'));

  /// Opens a throwaway in-memory database (LDB-003).
  ///
  /// Uses [NativeDatabase.memory] so tests run under plain `flutter test`
  /// without platform channels.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // Foreign keys are OFF by default in SQLite; the schema relies on
          // them (cascades, SET NULL references), so enable per-connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
