import '../../../../core/database/app_database.dart';

class LibraryLocalDataSource {
  const LibraryLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<SavedItem>> watchRecentItems() => _database.watchRecentItems();
}
