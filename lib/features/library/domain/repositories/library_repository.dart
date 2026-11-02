import '../entities/library_item.dart';

abstract interface class LibraryRepository {
  Stream<List<LibraryItem>> watchRecentItems();
}
