import '../entities/folio_collection.dart';
import '../repositories/collections_repository.dart';

class WatchCollections {
  const WatchCollections(this._repository);

  final CollectionsRepository _repository;

  Stream<List<FolioCollection>> call() => _repository.watchCollections();
}
