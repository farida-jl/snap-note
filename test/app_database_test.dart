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
}
