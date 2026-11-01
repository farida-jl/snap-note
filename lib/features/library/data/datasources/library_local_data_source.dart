import '../../../../core/database/app_database.dart';

class LibraryLocalDataSource {
  const LibraryLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> seed() => _database.seedMockData();

  Stream<List<SavedItem>> watchRecentItems() => _database.watchRecentItems();
}
