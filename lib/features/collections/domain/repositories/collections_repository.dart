import '../entities/collection_item.dart';
import '../entities/new_collection.dart';

abstract interface class CollectionsRepository {
  Stream<List<CollectionItem>> watchCollections();

  Future<int> createCollection(NewCollection collection);
}
