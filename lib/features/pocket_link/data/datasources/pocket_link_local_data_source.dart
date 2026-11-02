import '../../../../core/database/app_database.dart';

class PocketLinkLocalDataSource {
  const PocketLinkLocalDataSource(this._database);

  final AppDatabase _database;

  Future<int> save({
    required String url,
    required String title,
    required String description,
    required String sourceHost,
  }) {
    return _database.insertPocketLink(
      url: url,
      title: title,
      description: description,
      sourceHost: sourceHost,
    );
  }
}
