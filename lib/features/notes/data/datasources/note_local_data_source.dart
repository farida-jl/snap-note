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
}
