import '../entities/library_item.dart';
import '../repositories/library_repository.dart';

class WatchLibrary {
  const WatchLibrary(this._repository);

  final LibraryRepository _repository;

  Stream<List<LibraryItem>> call() => _repository.watchRecentItems();
}
