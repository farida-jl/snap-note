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

  test('deletes a note and updates its collection', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final collectionId = await database.insertCollection(
      title: 'Thoughts',
      description: 'Notes to revisit',
      symbol: '💭',
      isPinned: false,
    );
    final noteId = await database.insertNote(
      title: 'Temporary note',
      markdown: '[{"insert":"Delete me\\n"}]',
      collectionId: collectionId,
    );

    await database.deleteNote(noteId);

    final note = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(noteId))).getSingleOrNull();
    final collection = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(collectionId))).getSingle();
    expect(note, equals(null));
    expect(collection.itemCount, 0);
    expect(collection.updatedLabel, 'Updated just now');
  });

  test('updates a note and moves it between collections', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final sourceId = await database.insertCollection(
      title: 'Inbox',
      description: 'New notes',
      symbol: '📥',
      isPinned: false,
    );
    final targetId = await database.insertCollection(
      title: 'Writing',
      description: 'Drafts in progress',
      symbol: '✍️',
      isPinned: false,
    );
    final noteId = await database.insertNote(
      title: 'First title',
      markdown: '[{"insert":"First draft\\n"}]',
      collectionId: sourceId,
    );

    await database.updateNote(
      id: noteId,
      title: '  Revised title  ',
      markdown: '[{"insert":"Revised draft\\n"}]',
      collectionId: targetId,
    );

    final note = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(noteId))).getSingle();
    final source = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(sourceId))).getSingle();
    final target = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(targetId))).getSingle();
    expect(note.title, 'Revised title');
    expect(note.markdown, contains('Revised draft'));
    expect(note.collectionId, targetId);
    expect(source.itemCount, 0);
    expect(target.itemCount, 1);
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

  test('saves a pocket link to the selected collection', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final collectionId = await database.insertCollection(
      title: 'Research',
      description: 'Useful references',
      symbol: '📚',
      isPinned: false,
    );

    final itemId = await database.insertPocketLink(
      url: 'https://example.com/research',
      title: 'Research link',
      description: 'Save this reference.',
      sourceHost: 'example.com',
      collectionId: collectionId,
    );

    final item = await (database.select(
      database.savedItems,
    )..where((row) => row.id.equals(itemId))).getSingle();
    final collection = await (database.select(
      database.collections,
    )..where((row) => row.id.equals(collectionId))).getSingle();

    expect(item.collectionId, collectionId);
    expect(collection.itemCount, 1);
    expect(collection.updatedLabel, 'Updated just now');
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
