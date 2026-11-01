import 'package:drift/drift.dart';

@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get itemCount => integer()();
  IntColumn get colorValue => integer()();
  TextColumn get symbol => text()();
  TextColumn get updatedLabel => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
}
