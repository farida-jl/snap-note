import '../entities/folio_collection.dart';
import '../entities/new_collection.dart';

abstract interface class CollectionsRepository {
  Stream<List<FolioCollection>> watchCollections();

  Future<int> createCollection(NewCollection collection);
}
