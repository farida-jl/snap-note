part of '../app_database.dart';

extension AppDatabaseQueries on AppDatabase {
  Stream<List<SavedItem>> watchRecentItems() {
    return (select(
      savedItems,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).watch();
  }

  Stream<List<CollectionRow>> watchCollections() {
    return (select(collections)..orderBy([
          (row) => OrderingTerm.desc(row.isPinned),
          (row) => OrderingTerm.desc(row.updatedAt),
        ]))
        .watch();
  }

  Future<int> insertPocketLink({
    required String url,
    required String title,
    required String description,
    required String sourceHost,
  }) async {
    return transaction(() async {
      final readLaterId = await _ensureReadLaterCollection();
      final collection = await (select(
        collections,
      )..where((row) => row.id.equals(readLaterId))).getSingle();

      final id = await into(savedItems).insert(
        SavedItemsCompanion.insert(
          collectionId: collection.id,
          type: 'link',
          title: title,
          description: Value(description),
          source: Value(sourceHost),
          url: Value(url),
          createdAt: DateTime.now(),
        ),
      );

      await (update(
        collections,
      )..where((row) => row.id.equals(collection.id))).write(
        CollectionsCompanion(
          itemCount: Value(collection.itemCount + 1),
          updatedLabel: const Value('Updated just now'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return id;
    });
  }

  Future<int> insertNote({
    required String title,
    required String markdown,
    int? collectionId,
  }) async {
    return transaction(() async {
      final targetCollectionId =
          collectionId ?? await _ensureReadLaterCollection();
      final collection = await (select(
        collections,
      )..where((row) => row.id.equals(targetCollectionId))).getSingle();

      final id = await into(savedItems).insert(
        SavedItemsCompanion.insert(
          collectionId: collection.id,
          type: 'note',
          title: title,
          markdown: Value(markdown),
          createdAt: DateTime.now(),
        ),
      );

      await (update(
        collections,
      )..where((row) => row.id.equals(collection.id))).write(
        CollectionsCompanion(
          itemCount: Value(collection.itemCount + 1),
          updatedLabel: const Value('Updated just now'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return id;
    });
  }

  Future<int> _ensureReadLaterCollection() async {
    final existing =
        await (select(collections)
              ..where((row) => row.title.equals('Read Later'))
              ..orderBy([(row) => OrderingTerm.asc(row.id)])
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) return existing.id;

    return into(collections).insert(
      CollectionsCompanion.insert(
        title: 'Read Later',
        description: 'Links saved for later',
        itemCount: 0,
        colorValue: 0xFFE8EEF4,
        symbol: 'bookmark',
        updatedLabel: 'No links yet',
        isPinned: const Value(true),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
