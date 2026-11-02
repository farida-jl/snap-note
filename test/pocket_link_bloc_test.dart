import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/pocket_link/domain/entities/pocket_link_draft.dart';
import 'package:snap_note/features/pocket_link/domain/repositories/pocket_link_repository.dart';
import 'package:snap_note/features/pocket_link/domain/usecases/save_pocket_link.dart';
import 'package:snap_note/features/pocket_link/presentation/bloc/pocket_link_bloc.dart';

class _FakePocketLinkRepository implements PocketLinkRepository {
  PocketLinkDraft? savedDraft;

  @override
  Future<int> save(PocketLinkDraft draft) async {
    savedDraft = draft;
    return 4;
  }
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
}
