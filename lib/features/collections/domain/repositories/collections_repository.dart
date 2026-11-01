import '../entities/folio_collection.dart';

abstract interface class CollectionsRepository {
  Future<void> initialize();

  Stream<List<FolioCollection>> watchCollections();
}
