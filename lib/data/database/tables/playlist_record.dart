import 'package:drift/drift.dart';

/// A playlist scoped to one content space (LDB-001, BR-008).
///
/// [space] is constrained to `local` or `cloud`: playlists never cross the
/// Local/Cloud boundary (BR-008). Items live in [PlaylistItems] (BR-007).
@DataClassName('PlaylistRecord')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  late final TextColumn space =
      text().check(space.isIn(const ['local', 'cloud']))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
