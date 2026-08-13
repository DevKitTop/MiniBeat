import 'package:drift/drift.dart';

/// Monitored folder on disk (LDB-001, BR-021 folder monitoring).
@DataClassName('FolderRecord')
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get path => text().unique()();

  BoolColumn get isMonitored => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
