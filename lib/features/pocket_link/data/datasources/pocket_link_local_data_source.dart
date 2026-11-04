import '../../../../core/database/app_database.dart';

class PocketLinkLocalDataSource {
  const PocketLinkLocalDataSource(this._database);

  final AppDatabase _database;

  Future<int> save({
    required String url,
    required String title,
    required String description,
    required String sourceHost,
    int? collectionId,
  }) {
    return _database.insertPocketLink(
      url: url,
      title: title,
      description: description,
      sourceHost: sourceHost,
      collectionId: collectionId,
    );
  }

  Future<void> delete(int id) => _database.deletePocketLink(id);

  Future<void> update({
    required int id,
    required String url,
    required String title,
    required String description,
    required String sourceHost,
    int? collectionId,
  }) {
    return _database.updatePocketLink(
      id: id,
      url: url,
      title: title,
      description: description,
      sourceHost: sourceHost,
      collectionId: collectionId,
    );
  }
}
