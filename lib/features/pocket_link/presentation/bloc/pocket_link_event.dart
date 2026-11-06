import 'package:equatable/equatable.dart';

sealed class PocketLinkEvent extends Equatable {
  const PocketLinkEvent();

  @override
  List<Object?> get props => [];
}

final class PocketLinkUrlChanged extends PocketLinkEvent {
  const PocketLinkUrlChanged(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

final class PocketLinkTitleChanged extends PocketLinkEvent {
  const PocketLinkTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class PocketLinkDescriptionChanged extends PocketLinkEvent {
  const PocketLinkDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class PocketLinkCollectionChanged extends PocketLinkEvent {
  const PocketLinkCollectionChanged(this.collectionId);

  final int collectionId;

  @override
  List<Object?> get props => [collectionId];
}

final class PocketLinkSubmitted extends PocketLinkEvent {
  const PocketLinkSubmitted();
}
