import '../../../../core/database/app_database.dart';

class NoteLocalDataSource {
  const NoteLocalDataSource(this._database);

  final AppDatabase _database;

  Future<int> save({
    required String title,
    required String markdown,
    int? collectionId,
  }) {
    return _database.insertNote(
      title: title,
      markdown: markdown,
      collectionId: collectionId,
    );
  }

  Future<void> delete(int id) => _database.deleteNote(id);

  Future<void> update({
    required int id,
    required String title,
    required String markdown,
    int? collectionId,
  }) {
    return _database.updateNote(
      id: id,
      title: title,
      markdown: markdown,
      collectionId: collectionId,
    );
  }
}
