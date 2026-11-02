part of '../app_database.dart';

extension AppDatabaseSeed on AppDatabase {
  Future<void> seedMockData() {
    return transaction(() async {
      final readLaterId = await _ensureReadLaterCollection();
      await _consolidateLegacyMockCollections(readLaterId);
      await _seedSavedItemsIfEmpty(readLaterId);
      await _syncReadLaterItemCount(readLaterId);
    });
  }

  Future<int> _ensureReadLaterCollection() async {
    final existing =
        await (select(collections)
              ..where(
                (row) =>
                    row.title.equals('Read Later') |
                    row.title.equals('Read later'),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.id)])
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) {
      if (existing.title != 'Read Later') {
        await (update(collections)..where((row) => row.id.equals(existing.id)))
            .write(const CollectionsCompanion(title: Value('Read Later')));
      }
      return existing.id;
    }

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

  Future<void> _seedSavedItemsIfEmpty(int readLaterId) async {
    if (await savedItems.count().getSingle() != 0) return;

    await batch((batch) {
      batch.insertAll(savedItems, [
        SavedItemsCompanion.insert(
          collectionId: readLaterId,
          type: 'note',
          title: 'Make room for deep work',
          description: const Value(
            'Protect the first hour. Make space to think.',
          ),
          markdown: const Value(
            '# Make room for deep work\n\n'
            'Protect the first hour. **Make space to think.**',
          ),
          displayTime: 'Today, 9:12',
          createdAt: DateTime(2026, 11, 1, 9, 12),
        ),
        SavedItemsCompanion.insert(
          collectionId: readLaterId,
          type: 'link',
          title: 'A practical guide to deep work',
          source: const Value('todoist.com · Yesterday'),
          url: const Value('https://example.com/articles/deep-work'),
          displayTime: 'Yesterday',
          duration: const Value('8 MIN'),
          createdAt: DateTime(2026, 10, 31, 16, 30),
        ),
        SavedItemsCompanion.insert(
          collectionId: readLaterId,
          type: 'video',
          title: 'Build a ritual for focus',
          source: const Value('Cal Newport'),
          url: const Value('https://example.com/videos/focus-ritual'),
          displayTime: 'Yesterday',
          duration: const Value('12:34'),
          imageAsset: const Value('assets/images/video_still.png'),
          createdAt: DateTime(2026, 10, 31, 11),
        ),
      ]);
    });
  }

  Future<void> _consolidateLegacyMockCollections(int readLaterId) async {
    const legacyMockKeys = {
      'Deep work|Ideas for better focus|focus',
      'Creative sparks|Inspiration worth keeping|spark',
      'Read later|Articles for quiet moments|bookmark',
      'Watchlist|Videos to revisit|play',
    };
    final rows = await select(collections).get();
    final legacyIds = <int>[];

    for (final row in rows) {
      if (row.id == readLaterId) continue;
      final key = '${row.title}|${row.description}|${row.symbol}';
      if (legacyMockKeys.contains(key) || row.title == 'Read Later') {
        legacyIds.add(row.id);
      }
    }

    if (legacyIds.isNotEmpty) {
      await (update(savedItems)
            ..where((row) => row.collectionId.isIn(legacyIds)))
          .write(SavedItemsCompanion(collectionId: Value(readLaterId)));
      await (delete(collections)..where((row) => row.id.isIn(legacyIds))).go();
    }
  }

  Future<void> _syncReadLaterItemCount(int readLaterId) async {
    final countExpression = savedItems.id.count();
    final count =
        await (selectOnly(savedItems)
              ..addColumns([countExpression])
              ..where(savedItems.collectionId.equals(readLaterId)))
            .map((row) => row.read(countExpression) ?? 0)
            .getSingle();

    await (update(
      collections,
    )..where((row) => row.id.equals(readLaterId))).write(
      CollectionsCompanion(
        itemCount: Value(count),
        updatedLabel: Value(count == 0 ? 'No links yet' : '$count saved items'),
      ),
    );
  }
}
