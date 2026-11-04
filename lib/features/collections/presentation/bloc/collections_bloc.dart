import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/collection_item.dart';
import '../../domain/entities/new_collection.dart';
import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/watch_collections.dart';

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

final class _CollectionsChanged extends CollectionsEvent {
  const _CollectionsChanged(this.collections);

  final List<CollectionItem> collections;

  @override
  List<Object?> get props => [collections];
}

final class _CollectionsFailed extends CollectionsEvent {
  const _CollectionsFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc(this._watchCollections, this._createCollection)
    : super(const CollectionsState()) {
    on<CollectionsStarted>(_onStarted);
    on<CollectionCreationRequested>(_onCreationRequested);
    on<_CollectionsChanged>(_onChanged);
    on<_CollectionsFailed>(_onFailed);
  }

  final WatchCollections _watchCollections;
  final CreateCollection _createCollection;
  StreamSubscription<List<CollectionItem>>? _subscription;

  Future<void> _onStarted(
    CollectionsStarted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.loading));
    try {
      await _subscription?.cancel();
      _subscription = _watchCollections().listen(
        (collections) => add(_CollectionsChanged(collections)),
        onError: (Object error, StackTrace stackTrace) {
          add(_CollectionsFailed(error.toString()));
        },
      );
    } catch (error) {
      add(_CollectionsFailed(error.toString()));
    }
  }

  void _onChanged(_CollectionsChanged event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(
        status: CollectionsStatus.success,
        collections: event.collections,
      ),
    );
  }

  void _onFailed(_CollectionsFailed event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(status: CollectionsStatus.failure, message: event.message),
    );
  }

  Future<void> _onCreationRequested(
    CollectionCreationRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state.creationStatus == CollectionCreationStatus.saving) return;

    emit(state.copyWith(creationStatus: CollectionCreationStatus.saving));
    try {
      final collectionId = await _createCollection(event.collection);
      emit(
        state.copyWith(
          creationStatus: CollectionCreationStatus.success,
          createdCollectionId: collectionId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          creationStatus: CollectionCreationStatus.failure,
          creationMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
