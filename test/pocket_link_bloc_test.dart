import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/pocket_link/domain/entities/pocket_link_draft.dart';
import 'package:snap_note/features/pocket_link/domain/repositories/pocket_link_repository.dart';
import 'package:snap_note/features/pocket_link/domain/usecases/save_pocket_link.dart';
import 'package:snap_note/features/pocket_link/presentation/bloc/pocket_link_bloc.dart';

class _FakePocketLinkRepository implements PocketLinkRepository {
  PocketLinkDraft? savedDraft;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<int> save(PocketLinkDraft draft) async {
    savedDraft = draft;
    return 4;
  }

  @override
  Future<void> update(int id, PocketLinkDraft draft) async {}
}

void main() {
  test('validates edits and saves the pocket link', () async {
    final repository = _FakePocketLinkRepository();
    final bloc = PocketLinkBloc(SavePocketLink(repository));
    addTearDown(bloc.close);

    expect(bloc.state.isValid, isFalse);
    expect(bloc.state.url, isEmpty);
    expect(bloc.state.title, isEmpty);
    expect(bloc.state.description, isEmpty);

    bloc.add(
      const PocketLinkUrlChanged('https://example.com/articles/deep-work'),
    );
    bloc.add(const PocketLinkTitleChanged('Updated title'));
    bloc.add(const PocketLinkDescriptionChanged('Useful context'));
    bloc.add(const PocketLinkCollectionChanged(7));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<PocketLinkState>(),
        isA<PocketLinkState>().having(
          (state) => state.title,
          'title',
          'Updated title',
        ),
        isA<PocketLinkState>().having(
          (state) => state.isValid,
          'isValid',
          isTrue,
        ),
        isA<PocketLinkState>().having(
          (state) => state.collectionId,
          'collectionId',
          7,
        ),
      ]),
    );

    bloc.add(const PocketLinkSubmitted());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<PocketLinkState>().having(
          (state) => state.status,
          'status',
          PocketLinkStatus.saving,
        ),
        isA<PocketLinkState>().having(
          (state) => state.status,
          'status',
          PocketLinkStatus.success,
        ),
      ]),
    );

    expect(repository.savedDraft?.title, 'Updated title');
    expect(repository.savedDraft?.collectionId, 7);
  });

  test('does not save an invalid URL', () async {
    final repository = _FakePocketLinkRepository();
    final bloc = PocketLinkBloc(SavePocketLink(repository));
    addTearDown(bloc.close);

    bloc.add(const PocketLinkUrlChanged('not a url'));
    bloc.add(const PocketLinkTitleChanged('Title'));
    bloc.add(const PocketLinkDescriptionChanged('Description'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<PocketLinkState>(),
        isA<PocketLinkState>(),
        isA<PocketLinkState>(),
      ]),
    );
    bloc.add(const PocketLinkSubmitted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isValid, isFalse);
    expect(repository.savedDraft, isNull);
  });

  test(
    'starts edit mode with existing values and updates the same link',
    () async {
      PocketLinkDraft? updatedDraft;
      final bloc = PocketLinkBloc.edit(
        initialDraft: const PocketLinkDraft(
          url: 'https://todoist.com/deep-work',
          title: 'Deep work guide',
          description: 'Useful context',
          collectionId: 7,
        ),
        onSubmit: (draft) async => updatedDraft = draft,
      );
      addTearDown(bloc.close);

      expect(bloc.state.url, 'https://todoist.com/deep-work');
      expect(bloc.state.title, 'Deep work guide');
      expect(bloc.state.description, 'Useful context');
      expect(bloc.state.collectionId, 7);
      expect(bloc.state.isValid, isTrue);

      bloc.add(const PocketLinkTitleChanged('Updated deep work guide'));
      await expectLater(
        bloc.stream,
        emits(
          isA<PocketLinkState>().having(
            (state) => state.title,
            'title',
            'Updated deep work guide',
          ),
        ),
      );

      bloc.add(const PocketLinkSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PocketLinkState>().having(
            (state) => state.status,
            'status',
            PocketLinkStatus.saving,
          ),
          isA<PocketLinkState>().having(
            (state) => state.status,
            'status',
            PocketLinkStatus.success,
          ),
        ]),
      );

      expect(updatedDraft?.title, 'Updated deep work guide');
      expect(updatedDraft?.collectionId, 7);
    },
  );
}
