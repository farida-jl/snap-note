import '../entities/pocket_link_draft.dart';

abstract interface class PocketLinkRepository {
  Future<int> save(PocketLinkDraft draft);
}
