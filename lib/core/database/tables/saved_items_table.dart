import 'package:drift/drift.dart';

import 'collections_table.dart';

class SavedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId => integer().references(Collections, #id)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get markdown => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get displayTime => text()();
  TextColumn get duration => text().nullable()();
  TextColumn get imageAsset => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (type = 'note' OR url IS NOT NULL)",
    "CHECK (type != 'note' OR markdown IS NOT NULL)",
  ];
}
