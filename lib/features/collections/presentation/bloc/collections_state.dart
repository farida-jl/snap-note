import 'package:equatable/equatable.dart';

import '../../domain/entities/collection_item.dart';

enum CollectionsStatus { initial, loading, success, failure }

enum CollectionCreationStatus { idle, saving, success, failure }

class CollectionsState extends Equatable {
  const CollectionsState({
    this.status = CollectionsStatus.initial,
    this.collections = const [],
    this.message,
    this.creationStatus = CollectionCreationStatus.idle,
    this.creationMessage,
    this.createdCollectionId,
  });

  final CollectionsStatus status;
  final List<CollectionItem> collections;
  final String? message;
  final CollectionCreationStatus creationStatus;
  final String? creationMessage;
  final int? createdCollectionId;

  CollectionsState copyWith({
    CollectionsStatus? status,
    List<CollectionItem>? collections,
    String? message,
    CollectionCreationStatus? creationStatus,
    String? creationMessage,
    int? createdCollectionId,
  }) {
    return CollectionsState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      message: message,
      creationStatus: creationStatus ?? this.creationStatus,
      creationMessage: creationMessage,
      createdCollectionId: createdCollectionId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    collections,
    message,
    creationStatus,
    creationMessage,
    createdCollectionId,
  ];
}
