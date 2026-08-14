import 'package:flutter_test/flutter_test.dart';

import 'package:rep_mini/core/policy/product_policy.dart';
import 'package:rep_mini/data/database/app_database.dart';
import 'package:rep_mini/repositories/history_repository.dart';

void main() {
  group('HistoryRepository.watchRecent (LDB-007/BR-011)', () {
    late AppDatabase db;
    late HistoryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting();
      repo = HistoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> insertHistory({
      required String space,
      required DateTime playedAt,
    }) {
      return db
          .into(db.history)
          .insert(HistoryCompanion.insert(space: space, playedAt: playedAt));
    }

    test('most recent first, never exceeding the cap (BR-011)', () async {
      final base = DateTime.utc(2026);
      for (var i = 0; i < 25; i++) {
        await insertHistory(
          space: 'local',
          playedAt: base.add(Duration(minutes: i)),
        );
      }

      final rows = await repo.watchRecent(space: 'local').first;

      expect(rows, hasLength(ProductPolicy.historyLimit)); // 20, not 25
      // Strictly descending playedAt (most recent first).
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i - 1].playedAt.isAfter(rows[i].playedAt), isTrue);
      }
      // The 5 oldest inserts (minutes 0..4) are excluded by the cap, so the
      // oldest kept entry is minute 5. (Drift reads back in local time —
      // compare instants via toUtc.)
      expect(
        rows.last.playedAt.toUtc(),
        base.add(const Duration(minutes: 25 - ProductPolicy.historyLimit)),
      );
    });

    test('filters by content space (local vs cloud)', () async {
      await insertHistory(
        space: 'local',
        playedAt: DateTime.utc(2026, 1, 1, 10),
      );
      await insertHistory(
        space: 'cloud',
        playedAt: DateTime.utc(2026, 1, 1, 11),
      );
      await insertHistory(
        space: 'local',
        playedAt: DateTime.utc(2026, 1, 1, 12),
      );

      final rows = await repo.watchRecent(space: 'local').first;

      expect(rows, hasLength(2));
      expect(rows.every((r) => r.space == 'local'), isTrue);
      expect(rows.map((r) => r.playedAt.toUtc()).toList(), [
        DateTime.utc(2026, 1, 1, 12),
        DateTime.utc(2026, 1, 1, 10),
      ]);
    });

    test('no history for a space returns empty', () async {
      await insertHistory(space: 'local', playedAt: DateTime.utc(2026));

      final rows = await repo.watchRecent(space: 'cloud').first;

      expect(rows, isEmpty);
    });

    test('identical playedAt ties break by id descending (D5)', () async {
      final t = DateTime.utc(2026, 3, 1, 12);
      final id1 = await insertHistory(space: 'local', playedAt: t);
      final id2 = await insertHistory(space: 'local', playedAt: t);
      final id3 = await insertHistory(space: 'local', playedAt: t);

      final rows = await repo.watchRecent(space: 'local').first;

      expect(rows.map((r) => r.id).toList(), [id3, id2, id1]);
    });

    test('limit honored below the cap and clamped above it', () async {
      final base = DateTime.utc(2026, 2);
      for (var i = 0; i < 25; i++) {
        await insertHistory(
          space: 'local',
          playedAt: base.add(Duration(minutes: i)),
        );
      }

      final five = await repo.watchRecent(space: 'local', limit: 5).first;
      expect(five, hasLength(5));

      final fifty = await repo.watchRecent(space: 'local', limit: 50).first;
      expect(fifty, hasLength(ProductPolicy.historyLimit));
    });

    test('watch stream emits updated snapshots after inserts (D7)', () async {
      final t = DateTime.utc(2026, 4);
      final emissions = <List<HistoryRecord>>[];
      final sub = repo.watchRecent(space: 'local').listen(emissions.add);
      await pumpEventQueue();
      expect(emissions, isNotEmpty);
      expect(emissions.first, isEmpty);

      await insertHistory(space: 'local', playedAt: t);
      await pumpEventQueue();
      expect(emissions.last, hasLength(1));

      await insertHistory(
        space: 'local',
        playedAt: t.add(const Duration(minutes: 1)),
      );
      await pumpEventQueue();
      expect(emissions.last, hasLength(2));

      await sub.cancel();
    });
  });

  group('HistoryRepository.watchRecentMerged (LDB-009/BR-011)', () {
    late AppDatabase db;
    late HistoryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting();
      repo = HistoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> insertHistory({
      required String space,
      required DateTime playedAt,
    }) {
      return db
          .into(db.history)
          .insert(HistoryCompanion.insert(space: space, playedAt: playedAt));
    }

    test('merges both spaces ordered playedAt DESC, capped at 20 total '
        '(14 local + 10 cloud)', () async {
      final base = DateTime.utc(2026, 5);
      // 14 local entries at minutes 0..13.
      for (var i = 0; i < 14; i++) {
        await insertHistory(
          space: 'local',
          playedAt: base.add(Duration(minutes: i)),
        );
      }
      // 10 cloud entries at minutes 14..23 (newer than every local row).
      for (var i = 14; i < 24; i++) {
        await insertHistory(
          space: 'cloud',
          playedAt: base.add(Duration(minutes: i)),
        );
      }

      final rows = await repo.watchRecentMerged().first;

      // 24 total rows capped to the 20 newest — the 4 oldest local inserts
      // (minutes 0..3) must be dropped.
      expect(rows, hasLength(ProductPolicy.historyLimit));
      expect(rows.map((r) => r.space).toSet(), {'local', 'cloud'});
      // 10 cloud (minutes 14..23) + 10 local (minutes 4..13) survive the cap.
      expect(rows.where((r) => r.space == 'cloud'), hasLength(10));
      expect(rows.where((r) => r.space == 'local'), hasLength(10));
      // Strictly descending playedAt (most recent first).
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i - 1].playedAt.isAfter(rows[i].playedAt), isTrue);
      }
      // The newest kept entry is the newest cloud row; the oldest kept is the
      // local row at minute 4. (Drift reads back in local time — compare
      // instants via toUtc.)
      expect(
        rows.first.playedAt.toUtc(),
        base.add(const Duration(minutes: 23)),
      );
      expect(rows.last.playedAt.toUtc(), base.add(const Duration(minutes: 4)));
    });

    test(
      'identical playedAt across spaces ties break by id descending (D5)',
      () async {
        final t = DateTime.utc(2026, 5, 10, 12);
        final id1 = await insertHistory(space: 'local', playedAt: t);
        final id2 = await insertHistory(space: 'cloud', playedAt: t);
        final id3 = await insertHistory(space: 'local', playedAt: t);

        final rows = await repo.watchRecentMerged().first;

        expect(rows.map((r) => r.id).toList(), [id3, id2, id1]);
      },
    );

    test('empty history across both spaces returns empty', () async {
      final rows = await repo.watchRecentMerged().first;

      expect(rows, isEmpty);
    });

    test('limit honored below the cap and clamped above it', () async {
      final base = DateTime.utc(2026, 6);
      // 25 entries spread across both spaces.
      for (var i = 0; i < 13; i++) {
        await insertHistory(
          space: 'local',
          playedAt: base.add(Duration(minutes: i)),
        );
      }
      for (var i = 13; i < 25; i++) {
        await insertHistory(
          space: 'cloud',
          playedAt: base.add(Duration(minutes: i)),
        );
      }

      final five = await repo.watchRecentMerged(limit: 5).first;
      expect(five, hasLength(5));
      expect(five.map((r) => r.space).toSet(), {'cloud'}); // minutes 24..20

      final fifty = await repo.watchRecentMerged(limit: 50).first;
      expect(fifty, hasLength(ProductPolicy.historyLimit));
    });
  });
}
