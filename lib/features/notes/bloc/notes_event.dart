import 'package:equatable/equatable.dart';

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
