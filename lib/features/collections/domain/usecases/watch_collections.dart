import '../entities/collection_item.dart';
import '../repositories/collections_repository.dart';

class WatchCollections {
  const WatchCollections(this._repository);

  final CollectionsRepository _repository;

  Stream<List<CollectionItem>> call() => _repository.watchCollections();
}
