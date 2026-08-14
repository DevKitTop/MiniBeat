import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/data/database/app_database.dart';
import 'package:rep_mini/repositories/downloads_repository.dart';

void main() {
  group('DownloadsRepository.watchByStatus (LDB-008)', () {
    late AppDatabase db;
    late DownloadsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting();
      repo = DownloadsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> insertDownload({
      required String cloudObjectId,
      required String status,
      required DateTime updatedAt,
    }) {
      return db
          .into(db.downloads)
          .insert(
            DownloadsCompanion.insert(
              cloudObjectId: cloudObjectId,
              // status is nullable in the schema — pass it explicitly.
              status: Value(status),
              createdAt: updatedAt,
              updatedAt: updatedAt,
            ),
          );
    }

    test('returns only completed downloads (status filter)', () async {
      final t = DateTime.utc(2026, 1, 1, 10);
      await insertDownload(
        cloudObjectId: 'done-1',
        status: 'completed',
        updatedAt: t,
      );
      await insertDownload(
        cloudObjectId: 'failed-1',
        status: 'failed',
        updatedAt: t,
      );
      await insertDownload(
        cloudObjectId: 'queued-1',
        status: 'queued',
        updatedAt: t,
      );

      final rows = await repo.watchByStatus('completed').first;

      expect(rows, hasLength(1));
      expect(rows.single.cloudObjectId, 'done-1');
    });

    test('orders by updatedAt descending (D4)', () async {
      await insertDownload(
        cloudObjectId: 'older',
        status: 'completed',
        updatedAt: DateTime.utc(2026, 1, 1, 10),
      );
      await insertDownload(
        cloudObjectId: 'newer',
        status: 'completed',
        updatedAt: DateTime.utc(2026, 1, 1, 11),
      );

      final rows = await repo.watchByStatus('completed').first;

      expect(rows.map((r) => r.cloudObjectId).toList(), ['newer', 'older']);
    });

    test('identical updatedAt ties break by id descending (D4)', () async {
      final t = DateTime.utc(2026, 2, 1, 12);
      final id1 = await insertDownload(
        cloudObjectId: 'a',
        status: 'completed',
        updatedAt: t,
      );
      final id2 = await insertDownload(
        cloudObjectId: 'b',
        status: 'completed',
        updatedAt: t,
      );
      final id3 = await insertDownload(
        cloudObjectId: 'c',
        status: 'completed',
        updatedAt: t,
      );

      final rows = await repo.watchByStatus('completed').first;

      expect(rows.map((r) => r.id).toList(), [id3, id2, id1]);
    });

    test('no completed downloads returns empty', () async {
      final t = DateTime.utc(2026, 1, 1, 10);
      await insertDownload(
        cloudObjectId: 'failed-1',
        status: 'failed',
        updatedAt: t,
      );
      await insertDownload(
        cloudObjectId: 'queued-1',
        status: 'queued',
        updatedAt: t,
      );

      final rows = await repo.watchByStatus('completed').first;

      expect(rows, isEmpty);
    });

    test('watch stream emits updated snapshots after inserts (D7)', () async {
      final t = DateTime.utc(2026, 3, 1, 12);
      final emissions = <List<DownloadRecord>>[];
      final sub = repo.watchByStatus('completed').listen(emissions.add);
      await pumpEventQueue();
      expect(emissions, isNotEmpty);
      expect(emissions.first, isEmpty);

      await insertDownload(
        cloudObjectId: 'a',
        status: 'completed',
        updatedAt: t,
      );
      await pumpEventQueue();
      expect(emissions.last, hasLength(1));

      // A failed download must not leak into the completed stream.
      await insertDownload(
        cloudObjectId: 'f',
        status: 'failed',
        updatedAt: t.add(const Duration(minutes: 1)),
      );
      await pumpEventQueue();
      expect(emissions.last, hasLength(1));

      await sub.cancel();
    });
  });
}
