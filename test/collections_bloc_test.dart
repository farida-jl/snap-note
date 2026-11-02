import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/collections/domain/entities/folio_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';

class _FakeCollectionsRepository implements CollectionsRepository {
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
    final bloc = CollectionsBloc(
      WatchCollections(_FakeCollectionsRepository()),
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
}
