import '../entities/note_draft.dart';

abstract interface class NoteRepository {
  Future<int> save(NoteDraft draft);
}
