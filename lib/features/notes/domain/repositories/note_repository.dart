import '../entities/note_draft.dart';

abstract interface class NoteRepository {
  Future<int> save(NoteDraft draft);

  Future<void> update(int id, NoteDraft draft);

  Future<void> delete(int id);
}
