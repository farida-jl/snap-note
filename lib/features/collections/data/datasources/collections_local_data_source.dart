import '../../../../core/database/app_database.dart';

class CollectionsLocalDataSource {
  const CollectionsLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<CollectionRow>> watchCollections() =>
      _database.watchCollections();
}
