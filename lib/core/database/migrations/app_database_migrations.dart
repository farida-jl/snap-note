part of '../app_database.dart';

MigrationStrategy _createAppDatabaseMigration(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(database.collections);
      if (from < 5) await _upgradeSavedItems(database, migrator, from);
    },
  );
}

Future<void> _upgradeSavedItems(
  AppDatabase database,
  Migrator migrator,
  int from,
) async {
  final newColumns = <GeneratedColumn>[];
  final columnTransformer = <GeneratedColumn, Expression>{};

  if (from < 3) {
    final fallbackCollectionId = await _findOrCreateFallbackCollection(
      database,
    );
    newColumns.add(database.savedItems.collectionId);
    columnTransformer[database.savedItems.collectionId] = Variable(
      fallbackCollectionId,
    );
  }

  if (from < 4) {
    newColumns.add(database.savedItems.url);
    columnTransformer[database.savedItems.url] = const CustomExpression<String>(
      "CASE WHEN type IN ('link', 'video') "
      "THEN 'https://example.invalid/migrated/' || id "
      'ELSE NULL END',
    );
  }

  if (from < 5) {
    newColumns.add(database.savedItems.markdown);
    columnTransformer[database.savedItems.markdown] =
        const CustomExpression<String>(
          "CASE WHEN type = 'note' "
          'THEN COALESCE(description, title) ELSE NULL END',
        );
  }

  await migrator.alterTable(
    TableMigration(
      database.savedItems,
      newColumns: newColumns,
      columnTransformer: columnTransformer,
    ),
  );
}

Future<int> _findOrCreateFallbackCollection(AppDatabase database) async {
  final existingFallback =
      await (database.select(database.collections)
            ..where((row) => row.title.equals('Uncategorized'))
            ..limit(1))
          .getSingleOrNull();
  return existingFallback?.id ??
      database
          .into(database.collections)
          .insert(
            CollectionsCompanion.insert(
              title: 'Uncategorized',
              description: 'Items saved before collections were assigned',
              itemCount: 0,
              colorValue: 0xFFF0F2F4,
              symbol: 'folder',
              updatedLabel: 'Created during migration',
              updatedAt: DateTime.now(),
            ),
          );
}
