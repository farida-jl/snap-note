import '../entities/note_draft.dart';
import '../repositories/note_repository.dart';

class SaveNote {
  const SaveNote(this._repository);

  final NoteRepository _repository;

  Future<int> call(NoteDraft draft) => _repository.save(draft);
}
