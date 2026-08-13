import 'package:drift/drift.dart';

/// Key-value store for app settings (LDB-001).
@DataClassName('AppSettingsRecord')
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get key => text().unique()();

  TextColumn get value => text()();
}
