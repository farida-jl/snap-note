import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/features/notes/bloc/notes_bloc.dart';

void main() {
  group('NotesBloc', () {
    test('adds a trimmed note and removes it', () async {
      final bloc = NotesBloc();
      addTearDown(bloc.close);

      bloc.add(const NoteAdded('  First note  '));
      await expectLater(
        bloc.stream,
        emits(
          isA<NotesState>().having(
            (state) => state.notes.single.title,
            'note title',
            'First note',
          ),
        ),
      );

      final id = bloc.state.notes.single.id;
      bloc.add(NoteRemoved(id));
      await expectLater(
        bloc.stream,
        emits(
          isA<NotesState>().having((state) => state.notes, 'notes', isEmpty),
        ),
      );
    });

    test('ignores blank notes', () async {
      final bloc = NotesBloc();
      addTearDown(bloc.close);

      bloc.add(const NoteAdded('   '));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.notes, isEmpty);
    });
  });
}
