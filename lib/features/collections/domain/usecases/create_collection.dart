import '../entities/new_collection.dart';
import '../repositories/collections_repository.dart';

class CreateCollection {
  const CreateCollection(this._repository);

  final CollectionsRepository _repository;

  Future<int> call(NewCollection collection) =>
      _repository.createCollection(collection);
}
