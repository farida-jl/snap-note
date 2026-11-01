import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'tables/collections_table.dart';
import 'tables/saved_items_table.dart';

part 'app_database.g.dart';
part 'migrations/app_database_migrations.dart';
part 'queries/app_database_queries.dart';
part 'seed/app_database_seed.dart';

@DriftDatabase(tables: [SavedItems, Collections])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? createDatabaseConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => _createAppDatabaseMigration(this);
}
