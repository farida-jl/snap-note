import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class SavedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get displayTime => text()();
  TextColumn get duration => text().nullable()();
  TextColumn get imageAsset => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get itemCount => integer()();
  IntColumn get colorValue => integer()();
  TextColumn get symbol => text()();
  TextColumn get updatedLabel => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [SavedItems, Collections])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(collections);
    },
  );

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

  Future<void> seedMockData() {
    return transaction(() async {
      if (await savedItems.count().getSingle() == 0) {
        await batch((batch) {
          batch.insertAll(savedItems, [
            SavedItemsCompanion.insert(
              type: 'note',
              title: 'Make room for deep work',
              description: const Value(
                'Protect the first hour. Make space to think.',
              ),
              displayTime: 'Today, 9:12',
              createdAt: DateTime(2026, 11, 1, 9, 12),
            ),
            SavedItemsCompanion.insert(
              type: 'link',
              title: 'A practical guide to deep work',
              source: const Value('todoist.com · Yesterday'),
              displayTime: 'Yesterday',
              duration: const Value('8 MIN'),
              createdAt: DateTime(2026, 10, 31, 16, 30),
            ),
            SavedItemsCompanion.insert(
              type: 'video',
              title: 'Build a ritual for focus',
              source: const Value('Cal Newport'),
              displayTime: 'Yesterday',
              duration: const Value('12:34'),
              imageAsset: const Value('assets/images/video_still.png'),
              createdAt: DateTime(2026, 10, 31, 11),
            ),
          ]);
        });
      }

      await _removeDuplicateMockCollections();

      if (await collections.count().getSingle() == 0) {
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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(directory.path, 'snap_note.sqlite')),
    );
  });
}
