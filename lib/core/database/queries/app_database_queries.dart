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
          source: Value('$sourceHost · Just now'),
          url: Value(url),
          displayTime: 'Just now',
          duration: const Value('8 MIN'),
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
}
