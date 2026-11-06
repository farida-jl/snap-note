import 'package:equatable/equatable.dart';

import '../model/note.dart';

class NotesState extends Equatable {
  const NotesState({this.notes = const []});

  final List<Note> notes;

  @override
  List<Object> get props => [notes];
}
