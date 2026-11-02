import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/database/app_database.dart';

void main() {
  test('saves a pocket link and updates its collection', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.seedMockData();

    final readLaterBefore = await (database.select(
      database.collections,
    )..where((row) => row.title.equals('Read Later'))).getSingle();

    final id = await database.insertPocketLink(
      url: 'https://todoist.com/productivity-methods/deep-work',
      title: 'A practical guide to deep work',
      description: 'Useful context for future me.',
      sourceHost: 'todoist.com',
    );

    final saved = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(id))).getSingle();
    final readLaterAfter = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(readLaterBefore.id))).getSingle();

    expect(saved.type, 'link');
    expect(saved.url, contains('todoist.com'));
    expect(saved.collectionId, readLaterBefore.id);
    expect(readLaterAfter.itemCount, readLaterBefore.itemCount + 1);
  });

  test('creates Read Later and always stores new pocket links there', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.collections)
        .insert(
          CollectionsCompanion.insert(
            title: 'Personal',
            description: 'User collection',
            itemCount: 0,
            colorValue: 0xFFFFFFFF,
            symbol: 'folder',
            updatedLabel: 'New',
            updatedAt: DateTime(2026, 11, 2),
          ),
        );

    final itemId = await database.insertPocketLink(
      url: 'https://example.com/read-me',
      title: 'Read me',
      description: 'Save this for later.',
      sourceHost: 'example.com',
    );

    final readLater = await (database.select(
      database.collections,
    )..where((row) => row.title.equals('Read Later'))).getSingle();
    final item = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(itemId))).getSingle();

    expect(item.collectionId, readLater.id);
    expect(readLater.itemCount, 1);
  });

  test('mock seeding is safe when features initialize concurrently', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await Future.wait([database.seedMockData(), database.seedMockData()]);

    expect(await database.savedItems.count().getSingle(), 3);
    expect(await database.collections.count().getSingle(), 1);

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
            title: 'Personal research',
            description: 'A user-created collection',
            itemCount: 0,
            colorValue: 0xFFDDECF3,
            symbol: 'folder',
            updatedLabel: 'Updated today',
            updatedAt: DateTime(2026, 11, 1),
          ),
        );
    await database.seedMockData();

    expect(await database.collections.count().getSingle(), 2);
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

  test('migration from version 3 adds url and markdown together', () async {
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
                collection_id INTEGER NOT NULL REFERENCES collections (id),
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
              INSERT INTO collections (
                title, description, item_count, color_value, symbol,
                updated_label, updated_at
              ) VALUES ('Inbox', 'Legacy', 1, 0, 'folder', 'Yesterday', 0)
            ''')
            ..execute('''
              INSERT INTO saved_items (
                collection_id, type, title, description, display_time,
                created_at
              ) VALUES (1, 'note', 'Legacy note', 'Legacy body', 'Yesterday', 0)
            ''')
            ..execute('PRAGMA user_version = 3');
        },
      ),
    );
    addTearDown(database.close);

    final item = await database.select(database.savedItems).getSingle();

    expect(item.collectionId, 1);
    expect(item.url, equals(null));
    expect(item.markdown, 'Legacy body');
  });
}
