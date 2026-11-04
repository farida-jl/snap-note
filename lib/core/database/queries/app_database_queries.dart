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

  Future<int> insertCollection({
    required String title,
    required String description,
    required String symbol,
    required bool isPinned,
  }) {
    return into(collections).insert(
      CollectionsCompanion.insert(
        title: title.trim(),
        description: description.trim(),
        itemCount: 0,
        colorValue: 0xFFFCEBCA,
        symbol: symbol,
        updatedLabel: 'Created just now',
        isPinned: Value(isPinned),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<int> insertPocketLink({
    required String url,
    required String title,
    required String description,
    required String sourceHost,
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

  Future<void> deletePocketLink(int id) async {
    await transaction(() async {
      final link =
          await (select(savedItems)
                ..where((row) => row.id.equals(id) & row.type.equals('link')))
              .getSingleOrNull();
      if (link == null) throw StateError('Pocket link $id does not exist.');

      final collection = await (select(
        collections,
      )..where((row) => row.id.equals(link.collectionId))).getSingle();

      await (delete(savedItems)..where((row) => row.id.equals(id))).go();
      await (update(
        collections,
      )..where((row) => row.id.equals(link.collectionId))).write(
        CollectionsCompanion(
          itemCount: Value(
            collection.itemCount > 0 ? collection.itemCount - 1 : 0,
          ),
          updatedLabel: const Value('Updated just now'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> updatePocketLink({
    required int id,
    required String url,
    required String title,
    required String description,
    required String sourceHost,
    int? collectionId,
  }) async {
    await transaction(() async {
      final link =
          await (select(savedItems)
                ..where((row) => row.id.equals(id) & row.type.equals('link')))
              .getSingleOrNull();
      if (link == null) throw StateError('Pocket link $id does not exist.');

      final targetCollectionId = collectionId ?? link.collectionId;
      await (update(savedItems)..where((row) => row.id.equals(id))).write(
        SavedItemsCompanion(
          collectionId: Value(targetCollectionId),
          title: Value(title.trim()),
          description: Value(description.trim()),
          source: Value(sourceHost),
          url: Value(url.trim()),
        ),
      );

      if (targetCollectionId != link.collectionId) {
        final oldCollection = await (select(
          collections,
        )..where((row) => row.id.equals(link.collectionId))).getSingle();
        final newCollection = await (select(
          collections,
        )..where((row) => row.id.equals(targetCollectionId))).getSingle();
        final updatedAt = DateTime.now();

        await (update(
          collections,
        )..where((row) => row.id.equals(link.collectionId))).write(
          CollectionsCompanion(
            itemCount: Value(
              oldCollection.itemCount > 0 ? oldCollection.itemCount - 1 : 0,
            ),
            updatedLabel: const Value('Updated just now'),
            updatedAt: Value(updatedAt),
          ),
        );
        await (update(
          collections,
        )..where((row) => row.id.equals(targetCollectionId))).write(
          CollectionsCompanion(
            itemCount: Value(newCollection.itemCount + 1),
            updatedLabel: const Value('Updated just now'),
            updatedAt: Value(updatedAt),
          ),
        );
      }
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

  Future<void> deleteNote(int id) async {
    await transaction(() async {
      final note =
          await (select(savedItems)
                ..where((row) => row.id.equals(id) & row.type.equals('note')))
              .getSingleOrNull();
      if (note == null) throw StateError('Note $id does not exist.');

      final collection = await (select(
        collections,
      )..where((row) => row.id.equals(note.collectionId))).getSingle();

      await (delete(savedItems)..where((row) => row.id.equals(id))).go();
      await (update(
        collections,
      )..where((row) => row.id.equals(note.collectionId))).write(
        CollectionsCompanion(
          itemCount: Value(
            collection.itemCount > 0 ? collection.itemCount - 1 : 0,
          ),
          updatedLabel: const Value('Updated just now'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String markdown,
    int? collectionId,
  }) async {
    await transaction(() async {
      final note =
          await (select(savedItems)
                ..where((row) => row.id.equals(id) & row.type.equals('note')))
              .getSingleOrNull();
      if (note == null) throw StateError('Note $id does not exist.');

      final targetCollectionId = collectionId ?? note.collectionId;
      await (update(savedItems)..where((row) => row.id.equals(id))).write(
        SavedItemsCompanion(
          collectionId: Value(targetCollectionId),
          title: Value(title.trim()),
          markdown: Value(markdown.trim()),
        ),
      );

      if (targetCollectionId != note.collectionId) {
        final oldCollection = await (select(
          collections,
        )..where((row) => row.id.equals(note.collectionId))).getSingle();
        final newCollection = await (select(
          collections,
        )..where((row) => row.id.equals(targetCollectionId))).getSingle();
        final updatedAt = DateTime.now();

        await (update(
          collections,
        )..where((row) => row.id.equals(note.collectionId))).write(
          CollectionsCompanion(
            itemCount: Value(
              oldCollection.itemCount > 0 ? oldCollection.itemCount - 1 : 0,
            ),
            updatedLabel: const Value('Updated just now'),
            updatedAt: Value(updatedAt),
          ),
        );
        await (update(
          collections,
        )..where((row) => row.id.equals(targetCollectionId))).write(
          CollectionsCompanion(
            itemCount: Value(newCollection.itemCount + 1),
            updatedLabel: const Value('Updated just now'),
            updatedAt: Value(updatedAt),
          ),
        );
      }
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
