import '../entities/note_draft.dart';
import '../repositories/note_repository.dart';

class UpdateNote {
  const UpdateNote(this._repository);

  final NoteRepository _repository;

  Future<void> call(int id, NoteDraft draft) => _repository.update(id, draft);
}
