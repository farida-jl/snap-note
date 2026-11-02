import '../../domain/entities/library_item.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_data_source.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl(this._localDataSource);

  final LibraryLocalDataSource _localDataSource;

  @override
  Stream<List<LibraryItem>> watchRecentItems() {
    return _localDataSource.watchRecentItems().map(
      (rows) => rows
          .map(
            (row) => LibraryItem(
              id: row.id,
              collectionId: row.collectionId,
              type: LibraryItemType.values.byName(row.type),
              title: row.title,
              description: row.description,
              markdown: row.markdown,
              source: row.source,
              url: row.url,
              createdAt: row.createdAt,
              imageAsset: row.imageAsset,
            ),
          )
          .toList(growable: false),
    );
  }
}
