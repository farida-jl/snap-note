import '../../domain/entities/note_draft.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl(this._localDataSource);

  final NoteLocalDataSource _localDataSource;

  @override
  Future<int> save(NoteDraft draft) {
    return _localDataSource.save(
      title: draft.title.trim(),
      markdown: draft.markdown.trim(),
      collectionId: draft.collectionId,
    );
  }

  @override
  Future<void> delete(int id) => _localDataSource.delete(id);

  @override
  Future<void> update(int id, NoteDraft draft) {
    return _localDataSource.update(
      id: id,
      title: draft.title.trim(),
      markdown: draft.markdown.trim(),
      collectionId: draft.collectionId,
    );
  }
}
