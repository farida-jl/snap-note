part of '../app_database.dart';

extension AppDatabaseSeed on AppDatabase {
  Future<void> seedMockData() {
    return transaction(() async {
      await _removeDuplicateMockCollections();
      await _seedCollectionsIfEmpty();
      await _seedSavedItemsIfEmpty();
    });
  }

  Future<void> _seedCollectionsIfEmpty() async {
    if (await collections.count().getSingle() != 0) return;

    await batch((batch) {
      batch.insertAll(collections, [
        CollectionsCompanion.insert(
          title: 'Deep work',
          description: 'Ideas for better focus',
          itemCount: 18,
          colorValue: 0xFFFCE6AC,
          symbol: 'focus',
          updatedLabel: 'Updated today',
          isPinned: const Value(true),
          updatedAt: DateTime(2026, 11, 1, 10, 30),
        ),
        CollectionsCompanion.insert(
          title: 'Creative sparks',
          description: 'Inspiration worth keeping',
          itemCount: 12,
          colorValue: 0xFFDDECF3,
          symbol: 'spark',
          updatedLabel: 'Updated yesterday',
          updatedAt: DateTime(2026, 10, 31, 18),
        ),
        CollectionsCompanion.insert(
          title: 'Read later',
          description: 'Articles for quiet moments',
          itemCount: 24,
          colorValue: 0xFFE8EEF4,
          symbol: 'bookmark',
          updatedLabel: 'Updated 2 days ago',
          updatedAt: DateTime(2026, 10, 30, 9),
        ),
        CollectionsCompanion.insert(
          title: 'Watchlist',
          description: 'Videos to revisit',
          itemCount: 8,
          colorValue: 0xFFF5DED2,
          symbol: 'play',
          updatedLabel: 'Updated last week',
          updatedAt: DateTime(2026, 10, 25, 14),
        ),
      ]);
    });
  }

  Future<void> _seedSavedItemsIfEmpty() async {
    if (await savedItems.count().getSingle() != 0) return;

    final collectionIds = {
      for (final collection in await select(collections).get())
        collection.title: collection.id,
    };
    final deepWorkId = collectionIds['Deep work']!;
    final readLaterId = collectionIds['Read later']!;

    await batch((batch) {
      batch.insertAll(savedItems, [
        SavedItemsCompanion.insert(
          collectionId: deepWorkId,
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
          collectionId: deepWorkId,
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

  Future<void> _removeDuplicateMockCollections() async {
    const mockKeys = {
      'Deep work|Ideas for better focus|focus',
      'Creative sparks|Inspiration worth keeping|spark',
      'Read later|Articles for quiet moments|bookmark',
      'Watchlist|Videos to revisit|play',
    };
    final rows = await select(collections).get();
    final seen = <String>{};
    final duplicateIds = <int>[];

    for (final row in rows) {
      final key = '${row.title}|${row.description}|${row.symbol}';
      if (mockKeys.contains(key) && !seen.add(key)) duplicateIds.add(row.id);
    }

    if (duplicateIds.isNotEmpty) {
      await (delete(
        collections,
      )..where((row) => row.id.isIn(duplicateIds))).go();
    }
  }
}
