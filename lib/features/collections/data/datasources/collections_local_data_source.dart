import '../../../../core/database/app_database.dart';
import '../../domain/entities/new_collection.dart';

class CollectionsLocalDataSource {
  const CollectionsLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<CollectionRow>> watchCollections() =>
      _database.watchCollections();

  Future<int> createCollection(NewCollection collection) {
    return _database.insertCollection(
      title: collection.title,
      description: collection.description,
      symbol: collection.symbol,
      isPinned: collection.isPinned,
    );
  }
}
