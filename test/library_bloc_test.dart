import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/library/domain/repositories/library_repository.dart';
import 'package:snap_note/features/library/domain/usecases/watch_library.dart';
import 'package:snap_note/features/library/presentation/bloc/library_bloc.dart';

class _FakeLibraryRepository implements LibraryRepository {
  final items = Stream<List<LibraryItem>>.value([
    LibraryItem(
      id: 1,
      collectionId: 1,
      type: LibraryItemType.note,
      title: 'Deep work',
      markdown: '# Deep work',
      createdAt: DateTime(2026, 11, 2),
    ),
  ]);

  @override
  Stream<List<LibraryItem>> watchRecentItems() => items;
}

void main() {
  test('loads items from the library use case', () async {
    final bloc = LibraryBloc(WatchLibrary(_FakeLibraryRepository()));
    addTearDown(bloc.close);

    bloc.add(const LibraryStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<LibraryState>().having(
          (state) => state.status,
          'status',
          LibraryStatus.loading,
        ),
        isA<LibraryState>()
            .having((state) => state.status, 'status', LibraryStatus.success)
            .having((state) => state.items.single.title, 'title', 'Deep work'),
      ]),
    );
  });
}
