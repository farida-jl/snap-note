import '../entities/pocket_link_draft.dart';
import '../repositories/pocket_link_repository.dart';

class SavePocketLink {
  const SavePocketLink(this._repository);

  final PocketLinkRepository _repository;

  Future<int> call(PocketLinkDraft draft) => _repository.save(draft);
}
