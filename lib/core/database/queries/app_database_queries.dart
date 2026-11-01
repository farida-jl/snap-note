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
}
