import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/collections/domain/entities/folio_collection.dart';
import 'package:snap_note/features/collections/domain/entities/new_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/create_collection.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';

class _FakeCollectionsRepository implements CollectionsRepository {
  NewCollection? createdCollection;

  @override
  Future<int> createCollection(NewCollection collection) async {
    createdCollection = collection;
    return 2;
  }

  @override
  Stream<List<FolioCollection>> watchCollections() => Stream.value(const [
    FolioCollection(
      id: 1,
      title: 'Deep work',
      description: 'Ideas for better focus',
      itemCount: 18,
      colorValue: 0xFFFCE6AC,
      symbol: 'focus',
      updatedLabel: 'Updated today',
      isPinned: true,
    ),
  ]);
}

void main() {
  test('loads collections from the use case', () async {
    final repository = _FakeCollectionsRepository();
    final bloc = CollectionsBloc(
      WatchCollections(repository),
      CreateCollection(repository),
    );
    addTearDown(bloc.close);

    bloc.add(const CollectionsStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CollectionsState>().having(
          (state) => state.status,
          'status',
          CollectionsStatus.loading,
        ),
        isA<CollectionsState>()
            .having(
              (state) => state.status,
              'status',
              CollectionsStatus.success,
            )
            .having(
              (state) => state.collections.single.title,
              'title',
              'Deep work',
            ),
      ]),
    );
  });

  test('creates a collection once and reports success', () async {
    final repository = _FakeCollectionsRepository();
    final bloc = CollectionsBloc(
      WatchCollections(repository),
      CreateCollection(repository),
    );
    addTearDown(bloc.close);
    const collection = NewCollection(
      title: 'Quiet inspiration',
      description: 'Ideas worth revisiting',
      symbol: '🌿',
      isPinned: true,
    );

    bloc.add(const CollectionCreationRequested(collection));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CollectionsState>().having(
          (state) => state.creationStatus,
          'creation status',
          CollectionCreationStatus.saving,
        ),
        isA<CollectionsState>().having(
          (state) => state.creationStatus,
          'creation status',
          CollectionCreationStatus.success,
        ),
      ]),
    );
    expect(repository.createdCollection, collection);
  });
}
