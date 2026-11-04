import '../entities/pocket_link_draft.dart';

abstract interface class PocketLinkRepository {
  Future<int> save(PocketLinkDraft draft);

  Future<void> update(int id, PocketLinkDraft draft);

  Future<void> delete(int id);
}
