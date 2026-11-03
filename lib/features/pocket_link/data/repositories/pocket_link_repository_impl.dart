import '../../domain/entities/pocket_link_draft.dart';
import '../../domain/repositories/pocket_link_repository.dart';
import '../datasources/pocket_link_local_data_source.dart';

class PocketLinkRepositoryImpl implements PocketLinkRepository {
  const PocketLinkRepositoryImpl(this._localDataSource);

  final PocketLinkLocalDataSource _localDataSource;

  @override
  Future<int> save(PocketLinkDraft draft) {
    final uri = Uri.parse(draft.url.trim());
    return _localDataSource.save(
      url: uri.toString(),
      title: draft.title.trim(),
      description: draft.description.trim(),
      sourceHost: uri.host.replaceFirst(RegExp(r'^www\.'), ''),
      collectionId: draft.collectionId,
    );
  }
}
