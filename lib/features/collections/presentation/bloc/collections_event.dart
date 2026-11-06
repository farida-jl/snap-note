import 'package:equatable/equatable.dart';

import '../../domain/entities/collection_item.dart';
import '../../domain/entities/new_collection.dart';

sealed class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

final class CollectionsStarted extends CollectionsEvent {
  const CollectionsStarted();
}

final class CollectionCreationRequested extends CollectionsEvent {
  const CollectionCreationRequested(this.collection);

  final NewCollection collection;

  @override
  List<Object?> get props => [collection];
}

final class CollectionsChanged extends CollectionsEvent {
  const CollectionsChanged(this.collections);

  final List<CollectionItem> collections;

  @override
  List<Object?> get props => [collections];
}

final class CollectionsFailed extends CollectionsEvent {
  const CollectionsFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
