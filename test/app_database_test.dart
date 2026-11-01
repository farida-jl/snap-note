import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/database/app_database.dart';

void main() {
  test('mock seeding is safe when features initialize concurrently', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await Future.wait([database.seedMockData(), database.seedMockData()]);

    expect(await database.savedItems.count().getSingle(), 3);
    expect(await database.collections.count().getSingle(), 4);

    final collectionIds = (await database.select(database.collections).get())
        .map((collection) => collection.id)
        .toSet();
    final savedItems = await database.select(database.savedItems).get();
    expect(
      savedItems.every((item) => collectionIds.contains(item.collectionId)),
      isTrue,
    );
    expect(
      savedItems
          .where((item) => item.type == 'link' || item.type == 'video')
          .every((item) => item.url != null),
      isTrue,
    );
    expect(
      savedItems
          .where((item) => item.type == 'note')
          .every((item) => item.markdown != null),
      isTrue,
    );

    await expectLater(
      database
          .into(database.savedItems)
          .insert(
            SavedItemsCompanion.insert(
              collectionId: savedItems.first.collectionId,
              type: 'link',
              title: 'Link without URL',
              displayTime: 'Now',
              createdAt: DateTime(2026, 11, 1),
            ),
          ),
      throwsA(anything),
    );

    await expectLater(
      database
          .into(database.savedItems)
          .insert(
            SavedItemsCompanion.insert(
              collectionId: savedItems.first.collectionId,
              type: 'note',
              title: 'Note without Markdown',
              displayTime: 'Now',
              createdAt: DateTime(2026, 11, 1),
            ),
          ),
      throwsA(anything),
    );

    await database
        .into(database.collections)
        .insert(
          CollectionsCompanion.insert(
            title: 'Deep work',
            description: 'Ideas for better focus',
            itemCount: 18,
            colorValue: 0xFFFCE6AC,
            symbol: 'focus',
            updatedLabel: 'Updated today',
            updatedAt: DateTime(2026, 11, 1),
          ),
        );
    await database.seedMockData();

    expect(await database.collections.count().getSingle(), 4);
  });

  test('migrations preserve valid legacy items', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase
            ..execute('''
              CREATE TABLE collections (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                item_count INTEGER NOT NULL,
                color_value INTEGER NOT NULL,
                symbol TEXT NOT NULL,
                updated_label TEXT NOT NULL,
                is_pinned INTEGER NOT NULL DEFAULT 0,
                updated_at INTEGER NOT NULL
              )
            ''')
            ..execute('''
              CREATE TABLE saved_items (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                type TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT,
                source TEXT,
                display_time TEXT NOT NULL,
                duration TEXT,
                image_asset TEXT,
                created_at INTEGER NOT NULL
              )
            ''')
            ..execute('''
              INSERT INTO saved_items (
                type, title, display_time, created_at
              ) VALUES ('note', 'Legacy note', 'Yesterday', 0)
            ''')
            ..execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(database.close);

    final item = await database.select(database.savedItems).getSingle();
    final collection = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(item.collectionId))).getSingle();

    expect(collection.title, 'Uncategorized');
    expect(item.url, equals(null));
    expect(item.markdown, 'Legacy note');
  });
}
