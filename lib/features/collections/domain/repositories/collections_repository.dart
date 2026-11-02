import '../entities/folio_collection.dart';

abstract interface class CollectionsRepository {
  Stream<List<FolioCollection>> watchCollections();
}
