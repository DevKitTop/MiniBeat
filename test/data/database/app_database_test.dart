import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/data/database/app_database.dart';

const _allTableNames = <String>{
  'audio_records',
  'folders',
  'playlists',
  'playlist_items',
  'favorites',
  'history',
  'downloads',
  'cache',
  'app_settings',
  'playback_state',
};

void main() {
  group('AppDatabase.forTesting() (in-memory, LDB-003)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting();
    });

    tearDown(() async {
      await db.close();
    });

    test('fresh database reaches schema version 1 (LDB-002)', () async {
      final row = await db.customSelect('PRAGMA user_version').getSingle();

      expect(row.data['user_version'], 1);
    });

    test('creates all ten tables (LDB-001)', () async {
      final rows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      ).get();
      final names = rows.map((r) => r.data['name'] as String).toSet();

      expect(names, containsAll(_allTableNames));
    });

    test('every table accepts an insert (LDB-001)', () async {
      final folderId = await db.into(db.folders).insert(
            FoldersCompanion.insert(
              name: 'Music',
              path: '/storage/music',
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      final audioId = await db.into(db.audioRecords).insert(
            AudioRecordsCompanion.insert(
              title: 'Round Trip',
              filePath: '/storage/music/round-trip.mp3',
              fileName: 'round-trip.mp3',
              sizeBytes: 2048,
              durationMs: 60000,
              sha256Hash: 'b' * 64,
              format: 'mp3',
              folderId: Value(folderId),
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      final playlistId = await db.into(db.playlists).insert(
            PlaylistsCompanion.insert(
              name: 'Road',
              space: 'local',
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.playlistItems).insert(
            PlaylistItemsCompanion.insert(
              playlistId: playlistId,
              audioId: Value(audioId),
              position: 0,
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.favorites).insert(
            FavoritesCompanion.insert(
              space: 'local',
              audioId: Value(audioId),
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.history).insert(
            HistoryCompanion.insert(
              space: 'local',
              audioId: Value(audioId),
              playedAt: DateTime.utc(2026, 6, 15, 12),
            ),
          );
      await db.into(db.downloads).insert(
            DownloadsCompanion.insert(
              cloudObjectId: 'object-1',
              audioId: Value(audioId),
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.cache).insert(
            CacheCompanion.insert(
              cloudObjectId: 'object-1',
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(key: 'theme', value: 'dark'),
          );
      await db.into(db.playbackState).insert(
            PlaybackStateCompanion.insert(
              space: 'local',
              audioId: Value(audioId),
              positionMs: 0,
              isPlaying: false,
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );

      expect((await db.select(db.audioRecords).get()), hasLength(1));
      expect((await db.select(db.folders).get()), hasLength(1));
      expect((await db.select(db.playlists).get()), hasLength(1));
      expect((await db.select(db.playlistItems).get()), hasLength(1));
      expect((await db.select(db.favorites).get()), hasLength(1));
      expect((await db.select(db.history).get()), hasLength(1));
      expect((await db.select(db.downloads).get()), hasLength(1));
      expect((await db.select(db.cache).get()), hasLength(1));
      expect((await db.select(db.appSettings).get()), hasLength(1));
      expect((await db.select(db.playbackState).get()), hasLength(1));
    });

    test('AudioRecord round-trips with identity fields (LDB-003/006)', () async {
      final createdAt = DateTime.utc(2026, 8, 12, 10, 30);
      final id = await db.into(db.audioRecords).insert(
            AudioRecordsCompanion.insert(
              title: 'Interstellar Main Theme',
              filePath: '/music/interstellar.mp3',
              fileName: 'interstellar.mp3',
              sizeBytes: 3145728,
              durationMs: 543210,
              sha256Hash: 'a' * 64,
              format: 'mp3',
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          );

      final row = await (db.select(db.audioRecords)
            ..where((r) => r.id.equals(id)))
          .getSingle();

      expect(row.id, id);
      expect(row.title, 'Interstellar Main Theme');
      expect(row.filePath, '/music/interstellar.mp3');
      expect(row.fileName, 'interstellar.mp3');
      expect(row.sizeBytes, 3145728);
      expect(row.durationMs, 543210);
      expect(row.sha256Hash, 'a' * 64);
      expect(row.format, 'mp3');
      expect(row.isMissing, isFalse);
      expect(row.folderId, isNull);
      // Drift stores epoch seconds and reads back in local time; compare the
      // instant, not the UTC flag.
      expect(row.createdAt.toUtc(), createdAt);
      expect(row.updatedAt.toUtc(), createdAt);
    });

    test('cache and downloads are distinct tables (LDB-005)', () async {
      final downloadId = await db.into(db.downloads).insert(
            DownloadsCompanion.insert(
              cloudObjectId: 'object-7',
              status: const Value('completed'),
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      final cacheId = await db.into(db.cache).insert(
            CacheCompanion.insert(
              cloudObjectId: 'object-7',
              lastAccessedAt: Value(DateTime.utc(2026, 6, 16)),
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );

      final download =
          await (db.select(db.downloads)..where((r) => r.id.equals(downloadId)))
              .getSingle();
      final cache =
          await (db.select(db.cache)..where((r) => r.id.equals(cacheId)))
              .getSingle();

      // Same cloud object can exist in both: permanent copy vs temp cache.
      expect(download.cloudObjectId, 'object-7');
      expect(cache.cloudObjectId, 'object-7');
      // Download carries transfer status; cache carries last-access time.
      expect(download.status, 'completed');
      expect(cache.lastAccessedAt?.toUtc(), DateTime.utc(2026, 6, 16));

      // Cleaning the cache never touches the permanent download (LDB-005).
      await db.delete(db.cache).go();
      expect(await db.select(db.cache).get(), isEmpty);
      expect(await db.select(db.downloads).get(), hasLength(1));
    });

    test('playlist space CHECK rejects unsupported values', () async {
      await expectLater(
        db.into(db.playlists).insert(
              PlaylistsCompanion.insert(
                name: 'Streaming',
                space: 'streaming',
                createdAt: DateTime.utc(2026, 6, 15),
                updatedAt: DateTime.utc(2026, 6, 15),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('deleting a playlist cascades to its items', () async {
      final playlistId = await db.into(db.playlists).insert(
            PlaylistsCompanion.insert(
              name: 'Road Trip',
              space: 'local',
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.playlistItems).insert(
            PlaylistItemsCompanion.insert(
              playlistId: playlistId,
              position: 0,
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );
      expect(await db.select(db.playlistItems).get(), hasLength(1));

      await db.delete(db.playlists).go();

      expect(await db.select(db.playlistItems).get(), isEmpty);
    });

    test('deleting an audio record sets playlist item audioId to NULL', () async {
      final audioId = await db.into(db.audioRecords).insert(
            AudioRecordsCompanion.insert(
              title: 'Delete Me',
              filePath: '/music/delete-me.mp3',
              fileName: 'delete-me.mp3',
              sizeBytes: 1024,
              durationMs: 1000,
              sha256Hash: 'c' * 64,
              format: 'mp3',
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      final playlistId = await db.into(db.playlists).insert(
            PlaylistsCompanion.insert(
              name: 'Has Item',
              space: 'local',
              createdAt: DateTime.utc(2026, 6, 15),
              updatedAt: DateTime.utc(2026, 6, 15),
            ),
          );
      await db.into(db.playlistItems).insert(
            PlaylistItemsCompanion.insert(
              playlistId: playlistId,
              audioId: Value(audioId),
              position: 0,
              createdAt: DateTime.utc(2026, 6, 15),
            ),
          );

      await db.delete(db.audioRecords).go();

      final item = await db.select(db.playlistItems).getSingle();
      expect(item.audioId, isNull);
      expect(item.playlistId, playlistId);
    });
  });
}
