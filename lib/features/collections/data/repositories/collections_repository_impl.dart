import '../../domain/entities/folio_collection.dart';
import '../../domain/entities/new_collection.dart';
import '../../domain/repositories/collections_repository.dart';
import '../datasources/collections_local_data_source.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  const CollectionsRepositoryImpl(this._localDataSource);

  final CollectionsLocalDataSource _localDataSource;

  @override
  Future<int> createCollection(NewCollection collection) =>
      _localDataSource.createCollection(collection);

  @override
  Stream<List<FolioCollection>> watchCollections() {
    return _localDataSource.watchCollections().map(
      (rows) => rows
          .map(
            (row) => FolioCollection(
              id: row.id,
              title: row.title,
              description: row.description,
              itemCount: row.itemCount,
              colorValue: row.colorValue,
              symbol: row.symbol,
              updatedLabel: row.updatedLabel,
              isPinned: row.isPinned,
            ),
          )
          .toList(growable: false),
    );
  }
}
