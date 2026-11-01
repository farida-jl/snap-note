import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/note.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

final class NoteAdded extends NotesEvent {
  const NoteAdded(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

final class NoteRemoved extends NotesEvent {
  const NoteRemoved(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class NotesState extends Equatable {
  const NotesState({this.notes = const []});

  final List<Note> notes;

  @override
  List<Object> get props => [notes];
}

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
