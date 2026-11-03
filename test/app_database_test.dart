import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/database/app_database.dart';

void main() {
  test('creates a pinned emoji collection', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final id = await database.insertCollection(
      title: '  Quiet inspiration  ',
      description: '  Ideas worth revisiting  ',
      symbol: '🌿',
      isPinned: true,
    );

    final collection = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(id))).getSingle();
    expect(collection.title, 'Quiet inspiration');
    expect(collection.description, 'Ideas worth revisiting');
    expect(collection.symbol, '🌿');
    expect(collection.isPinned, isTrue);
    expect(collection.itemCount, 0);
  });

  test('saves a Markdown note to Read Later by default', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final id = await database.insertNote(
      title: 'Make room for deep work',
      markdown: '## My ritual\n\n- [x] Clear the desk',
    );

    final saved = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(id))).getSingle();
    final readLater = await (database.select(
      database.collections,
    )..where((row) => row.title.equals('Read Later'))).getSingle();

    expect(saved.type, 'note');
    expect(saved.markdown, contains('- [x]'));
    expect(saved.collectionId, readLater.id);
    expect(readLater.itemCount, 1);
  });

  test('saves a pocket link and updates its collection', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final id = await database.insertPocketLink(
      url: 'https://todoist.com/productivity-methods/deep-work',
      title: 'A practical guide to deep work',
      description: 'Useful context for future me.',
      sourceHost: 'todoist.com',
    );

    final saved = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(id))).getSingle();
    final readLater = await (database.select(
      database.collections,
    )..where((row) => row.title.equals('Read Later'))).getSingle();

    expect(saved.type, 'link');
    expect(saved.url, contains('todoist.com'));
    expect(saved.collectionId, readLater.id);
    expect(readLater.itemCount, 1);
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

  test('fresh database is empty and enforces saved item constraints', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(await database.savedItems.count().getSingle(), 0);
    expect(await database.collections.count().getSingle(), 0);

    final collectionId = await database
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

    await expectLater(
      database
          .into(database.savedItems)
          .insert(
            SavedItemsCompanion.insert(
              collectionId: collectionId,
              type: 'link',
              title: 'Link without URL',
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
              collectionId: collectionId,
              type: 'note',
              title: 'Note without Markdown',
              createdAt: DateTime(2026, 11, 1),
            ),
          ),
      throwsA(anything),
    );
  });
}
