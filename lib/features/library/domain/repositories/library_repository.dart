import '../entities/library_item.dart';

abstract interface class LibraryRepository {
  Future<void> initialize();

  Stream<List<LibraryItem>> watchRecentItems();
}
