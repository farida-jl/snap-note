part of '../app_database.dart';

MigrationStrategy _createAppDatabaseMigration(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(database.collections);
      if (from < 3) {
        await _addRequiredCollectionReference(database, migrator);
      }
      if (from < 4) await _addUrl(database, migrator);
      if (from < 5) await _addMarkdown(database, migrator);
    },
  );
}

Future<void> _addRequiredCollectionReference(
  AppDatabase database,
  Migrator migrator,
) async {
  final existingFallback =
      await (database.select(database.collections)
            ..where((row) => row.title.equals('Uncategorized'))
            ..limit(1))
          .getSingleOrNull();
  final fallbackCollectionId =
      existingFallback?.id ??
      await database
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

  await migrator.alterTable(
    TableMigration(
      database.savedItems,
      newColumns: [database.savedItems.collectionId],
      columnTransformer: {
        database.savedItems.collectionId: Variable(fallbackCollectionId),
      },
    ),
  );
}

Future<void> _addUrl(AppDatabase database, Migrator migrator) {
  return migrator.alterTable(
    TableMigration(
      database.savedItems,
      newColumns: [database.savedItems.url],
      columnTransformer: {
        database.savedItems.url: const CustomExpression<String>(
          "CASE WHEN type IN ('link', 'video') "
          "THEN 'https://example.invalid/migrated/' || id "
          'ELSE NULL END',
        ),
      },
    ),
  );
}

Future<void> _addMarkdown(AppDatabase database, Migrator migrator) {
  return migrator.alterTable(
    TableMigration(
      database.savedItems,
      newColumns: [database.savedItems.markdown],
      columnTransformer: {
        database.savedItems.markdown: const CustomExpression<String>(
          "CASE WHEN type = 'note' "
          'THEN COALESCE(description, title) ELSE NULL END',
        ),
      },
    ),
  );
}
