import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

export 'notes_event.dart';
export 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesState()) {
    on<NoteAdded>(_onNoteAdded);
    on<NoteRemoved>(_onNoteRemoved);
  }

  int _nextId = 0;

  void _onNoteAdded(NoteAdded event, Emitter<NotesState> emit) {
    final title = event.title.trim();
    if (title.isEmpty) return;

    emit(
      NotesState(
        notes: [
          ...state.notes,
          Note(id: _nextId++, title: title),
        ],
      ),
    );
  }

  void _onNoteRemoved(NoteRemoved event, Emitter<NotesState> emit) {
    emit(
      NotesState(
        notes: state.notes.where((note) => note.id != event.id).toList(),
      ),
    );
  }
}
