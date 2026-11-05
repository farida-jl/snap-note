import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'tables/collections_table.dart';
import 'tables/saved_items_table.dart';

part 'app_database.g.dart';
part 'queries/app_database_queries.dart';

@DriftDatabase(tables: [SavedItems, Collections])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? createDatabaseConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await into(collections).insert(
        CollectionsCompanion.insert(
          title: 'Read later',
          description: 'Links saved for later',
          itemCount: 0,
          colorValue: 0xFFE8EEF4,
          symbol: 'bookmark',
          updatedLabel: 'No links yet',
          isPinned: const Value(true),
          updatedAt: DateTime.now(),
        ),
      );
    },
  );
}
